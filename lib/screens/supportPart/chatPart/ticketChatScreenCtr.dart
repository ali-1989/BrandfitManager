import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_audio_recorder2/flutter_audio_recorder2.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iris_download_manager/downloadManager/downloadManager.dart';
import 'package:iris_download_manager/uploadManager/uploadManager.dart';
import 'package:iris_sound_player/iris_sound_player.dart';
import 'package:iris_tools/api/cache/cacheMap.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/imageHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/features/overlayDialog.dart';
import 'package:iris_tools/widgets/buttons/progressButton.dart';
import 'package:iris_tools/modules/stateManagers/common_refresh.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';
import 'package:iris_tools/widgets/timerView.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' as pull;

import '/abstracts/viewController.dart';
import '/managers/ticketManager.dart';
import '/managers/userAdvancedManager.dart';
import '/models/dataModels/chatModels/shotModel.dart';
import '/models/dataModels/ticketModels/ticketMediaModel.dart';
import '/models/dataModels/ticketModels/ticketMessageModel.dart';
import '/models/dataModels/ticketModels/ticketModel.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/models/holderModels/ticketDownloadUploadHolder.dart';
import '/screens/supportPart/chatPart/ticketChatScreen.dart';
import '/screens/supportPart/chatPart/videoViewer.dart';
import '/system/downloadUpload.dart';
import '/system/enums.dart';
import '/system/icons.dart';
import '/system/keys.dart';
import '/system/queryFiltering.dart';
import '/system/requester.dart';
import '/system/session.dart';
import '/tools/app/appManager.dart';
import '/tools/app/appSizes.dart';
import '/tools/app/appThemes.dart';
import '/tools/centers/broadcastCenter.dart';
import '/tools/centers/dialogCenter.dart';
import '/tools/centers/directoriesCenter.dart';
import '/tools/centers/httpCenter.dart';
import '/tools/mediaTools.dart';
import '/tools/permissionTools.dart';
import '/tools/playerTools.dart';
import '/tools/serverTimeTools.dart';

class TicketChatScreenCtr implements ViewController {
  late TicketChatScreenState state;
  var chatTextCtr = TextEditingController();
  Requester? commonRequester;
  UserModel? user;
  bool isRecordOpen = false;
  late TimerViewController timerViewController;
  String? audioRecPath;
  late FilterRequest filterRequest;
  var pullLoadCtr = pull.RefreshController();
  late StreamSubscription downloadSub;
  late StreamSubscription uploadSub;
  late CacheMap<String, Uint8List> imageCache;

  @override
  void onInitState<E extends State>(E state){
    this.state = state as TicketChatScreenState;

    filterRequest = FilterRequest();

    commonRequester = Requester();
    user = Session.getLastLoginUser();
    timerViewController = TimerViewController();
    //state.stateController.mainState = StateXController.state$loading;
    imageCache = CacheMap(20);

    BroadcastCenter.ticketMessageUpdateNotifier.addListener(onNewMessageOrUpdate);
    BroadcastCenter.ticketMessageSeenNotifier.addListener(onPearSeenMessage);

    downloadSub = DownloadUpload.downloadManager.addListener(onDownload);
    uploadSub = DownloadUpload.uploadManager.addListener(onUpload);

    state.addPostOrCall(() {
      BroadcastCenter.openedTicketId = state.ticket.id;

      if(state.ticket.unReadCount() > 0) {
        state.ticket.updateLastSeenDate();

        TicketManager.sendLastSeenToServer(user!.userId, state.ticket.id!, state.ticket.lastSeenMessageTs!);
      }
    });
  }

  @override
  void onBuild(){
  }

  @override
  void onDispose(){
    BroadcastCenter.openedTicketId = null;
    PlayerTools.chatAudioPlayer.stop();
    HttpCenter.cancelAndClose(commonRequester?.httpRequester);
    downloadSub.cancel();
    uploadSub.cancel();
    BroadcastCenter.ticketMessageUpdateNotifier.removeListener(onNewMessageOrUpdate);
    BroadcastCenter.ticketMessageSeenNotifier.removeListener(onPearSeenMessage);
  }

  void onNewMessageOrUpdate(){
    //TicketMessageModel? msg = BroadcastCenter.newTicketMessageNotifier.value;
    state.stateController.updateMain();

    final lastPos = state.itemPositionsListener.itemPositions.value.last;
    final allMessages = state.ticket.messages.length;

    if(allMessages > 2 && lastPos.index >= allMessages -2) {
      state.itemScrollController.scrollTo(index: state.ticket.messages.length, duration: Duration(milliseconds: 100));
    }

    state.ticket.updateLastSeenDate();
    TicketManager.sendLastSeenToServer(user!.userId, state.ticket.id!, state.ticket.lastSeenMessageTs!);
  }

  void onPearSeenMessage(){
    Map? m = BroadcastCenter.ticketMessageSeenNotifier.value;

    if(m != null){
      var ticketId = m['ticket_id'];
      var ts = m['seen_ts'];

      if(ticketId == state.ticket.id) {
        state.ticket.setMyMessageSeenByUser(ts, user!.userId);

        state.stateController.updateMain();
      }
    }
  }

  Future prepareBeforeRecorder() async {
    audioRecPath = DirectoriesCenter.getSavePathByPath(SavePathType.VOICE_REC, null);
    File f = File(audioRecPath!);

    Directory dir = f.parent;

    if(!(await dir.exists())){
      await dir.create(recursive: true);
    }

    while(await f.exists()){
      audioRecPath = DirectoriesCenter.getSavePathByPath(SavePathType.VOICE_REC, null);
      f = File(audioRecPath!);
    }

    PlayerTools.audioRecorder = FlutterAudioRecorder2(audioRecPath!, audioFormat: AudioFormat.AAC);
    await PlayerTools.audioRecorder.initialized;
  }
  ///========================================================================================================
  /*void tryAgain(State state){
    if(state is TicketChatScreenState) {
      state.stateController.mainStateAndUpdate(StateXController.state$loading);
    }
  }*/

  void onDownload(DownloadItem di){
    if(di.isInCategory(DownloadCategory.ticketMedia)) {
      CommonRefresh.refresh(di.subCategory!, di);
    }
  }

  void onUpload(UploadItem up){
    if(up.isInCategory(DownloadCategory.ticketMedia)) {
      CommonRefresh.refresh(up.subCategory!, up);

      if(up.isComplete()){
        PlayerTools.playChatMessageSend();
      }
    }
  }

  void startDownload(TicketMessageModel msg, TicketMediaModel media){
    var tag = Keys.genDownloadTag_ticketMedia(media);
    var current = DownloadUpload.downloadManager.getByTag(tag);

    if(current != null && current.isInProcess()){
      return;
    }

    PermissionTools.isGrantedStoragePermission().then((status){
      if(status) {
        media.prepareMediaPath(false);

        final holder = TicketDownloadUploadHolder();
        holder.ownerId = msg.senderUserId;
        holder.ticketId = msg.ticketId;
        holder.messageId = msg.id;
        holder.mediaId = msg.mediaId;
        holder.messageModel = msg;
        holder.mediaModel = media;

        var di = DownloadUpload.downloadManager.createDownloadItem(media.uri!, tag: tag, savePath: media.mediaPath!);
        di.forceCreateNewFile = true;//todo: comment this in ver 2
        di.category = DownloadCategory.ticketMedia;
        di.subCategory = Keys.genCommonRefreshTag_ticketMessage(msg);
        di.attach = holder;

        DownloadUpload.downloadManager.enqueue(di);
      }
    });
  }

  void startUpload(TicketMessageModel msg, TicketMediaModel media){
    var tag = Keys.genDownloadTag_ticketMedia(media);
    var current = DownloadUpload.uploadManager.getByTag(tag);

    if(current != null && current.isInProcess()){
      return;
    }

    TicketManager.sendMessage(msg);
  }

  void onMicClick() async {
    var hasPermission = await PermissionTools.isGrantedMicPermission();

    if(hasPermission) {
      await prepareBeforeRecorder();
      _startRec();
    }
    else {
      PermissionTools.requestMicPermission().then((value) async {
        if(value == PermissionStatus.granted){
          await prepareBeforeRecorder();
          _startRec();
        }
      });
    }
  }

  void _startRec(){
    isRecordOpen = true;

    AppManager.widgetsBinding.addPostFrameCallback((timeStamp) async {
      await PlayerTools.audioRecorder.start();
      timerViewController.start();
    });

    state.stateController.update(state.idChatBar);
  }

  Future _stopRec() async {
    await PlayerTools.audioRecorder.stop();
    timerViewController.pause();
    isRecordOpen = false;
  }
  
  TicketMessageModel createMessage(){
    var tm = TicketMessageModel();
    tm.id = BigInt.from(Generator.generateDateMillWith6Digit());
    tm.isDraft = true;
    tm.ticketId = state.ticket.id;
    tm.senderUserId = user!.userId;
    tm.sendDate = ServerTimeTools.utcTimeMatchServer;
    tm.sendTs = DateHelper.toTimestamp(tm.sendDate!);

    return tm;
  }

  Future<TicketMediaModel> createMedia(TicketMessageModel tm, String filePath) async{
    var m = TicketMediaModel();

    m.id = BigInt.from(Generator.generateDateMillWith6Digit());
    m.isDraft = true;
    m.isDownloaded = true;
    m.msgType = tm.type;
    m.name = FileHelper.getFileNameWithoutExtension(filePath);
    m.extension = FileHelper.getDotExtension(filePath);
    m.mediaPath = filePath;

    if(m.msgType == ChatType.AUDIO.typeNum){
      m.audioTrack = Track.fromFile(filePath);
      m.duration = await PlayerTools.audioDurationGet.setFilePath(filePath);
      m.volume = await (File(filePath).length());
    }
    else if(m.msgType == ChatType.IMAGE.typeNum){
      var iAtt = await MediaTools.getImageAttribute2(filePath);
      m.width = iAtt.width;
      m.height = iAtt.height;
      m.volume = iAtt.volume!;
      tm.coverData = iAtt.blurHash!;

      m.mediaPath = DirectoriesCenter.getSavePathByPath(SavePathType.CHAT_IMAGE, null);

      await FileHelper.createNewFile(m.mediaPath!);
      await ImageHelper.writeImageBytes(m.mediaPath!, iAtt.newPicture!);
    }
    else if(m.msgType == ChatType.VIDEO.typeNum){
      var vAtt = await MediaTools.getVideoAttribute(filePath);
      m.duration = vAtt.duration;
      m.width = vAtt.width;
      m.height = vAtt.height;
      m.volume = vAtt.volume!;
      tm.coverData = vAtt.blurHash!;
      m.screenshotModel = ChatMediaShotModel();
      m.screenshotModel!.width = vAtt.shotWidth!;
      m.screenshotModel!.height = vAtt.shotHeight!;
      m.screenshotModel!.screenshotBytes = vAtt.shotBytes;
    }
    else {
      m.volume = await (File(filePath).length());
    }

    return m;
  }

  Future sinkAndSendMessage(TicketMessageModel tm, TicketMediaModel? media) async{
    if(media != null) {
      if(media.screenshotModel != null && media.screenshotModel!.screenshotBytes != null ){
        /*await*/ FileHelper.writeBytes(media.screenshotPath!, media.screenshotModel!.screenshotBytes!);
      }

      TicketManager.sinkTicketMedia([media]);
    }

    TicketManager.sinkTicketMessages([tm]);
    return TicketManager.sendMessage(tm);
  }

  Future<TicketMediaModel> _createAudioMessage(TicketMessageModel tm, String path) async{
    tm.type = ChatType.AUDIO.typeNum;
    var media = await createMedia(tm, path);
    TicketManager.addMediaMessage(media);
    tm.mediaId = media.id;

    return media;
  }

  Future<TicketMediaModel> _createImageMessage(TicketMessageModel tm, String path) async{
    //state.showLoading();

    tm.type = ChatType.IMAGE.typeNum;
    var media = await createMedia(tm, path);
    TicketManager.addMediaMessage(media);
    tm.mediaId = media.id;

    //state.hideLoading();
    return media;
  }

  Future<TicketMediaModel> _createVideoMessage(TicketMessageModel tm, String path) async{
    //state.showLoading();

    tm.type = ChatType.VIDEO.typeNum;
    var media = await createMedia(tm, path);
    TicketManager.addMediaMessage(media);
    tm.mediaId = media.id;
    media.screenshotPath = DirectoriesCenter.getScreenshotFile(extension: 'jpg');

    //state.hideLoading();
    return media;
  }

  Future<TicketMediaModel> _createFileMessage(TicketMessageModel tm, String path) async{
    tm.type = ChatType.FILE.typeNum;
    var media = await createMedia(tm, path);
    TicketManager.addMediaMessage(media);
    tm.mediaId = media.id;

    return media;
  }

  void beforeSendMessage(TicketMessageModel tm){
    final add = state.ticket.addMessage(tm);

    if(add){
      TicketManager.allTicketMessageList.add(tm);
    }

    state.ticket.updateLastSeenDate(dateTs: tm.sendDate!);
    BroadcastCenter.ticketUpdateNotifier.value = state.ticket;

    state.stateController.update(state.idListView);

    if(state.ticket.messages.length > 2) {
      state.itemScrollController.scrollTo(index: state.ticket.messages.length, duration: Duration(milliseconds: 100));
    }

    if(tm.type == ChatType.TEXT.typeNum){
      PlayerTools.playChatMessageSend();
    }
  }

  void onSendClick() async{
    var txt = chatTextCtr.text.trim();

    if(isRecordOpen){
      await _stopRec();
      state.stateController.update(state.idChatBar);

      var tm = createMessage();
      var media = await _createAudioMessage(tm, audioRecPath!);
      beforeSendMessage(tm);
      sinkAndSendMessage(tm, media);
    }
    else {
      if(txt.isNotEmpty) {
        chatTextCtr.clear();
        FocusHelper.hideKeyboardByUnFocusRoot();

        var tm = createMessage();
        tm.text = txt;
        tm.type = ChatType.TEXT.typeNum;

        beforeSendMessage(tm);
        sinkAndSendMessage(tm, null);
      }
    }
  }

  void onDeleteRecClick(){
    _stopRec();

    state.stateController.update(state.idChatBar);
    FileHelper.deleteSafe(audioRecPath);
  }

  void onRecPauseClick() async{
    if(timerViewController.isStart()) {
      await PlayerTools.audioRecorder.pause();
      timerViewController.pause();
    }
    else {
      await PlayerTools.audioRecorder.resume();
      timerViewController.start();
    }

    state.stateController.update(state.idChatBar);
  }

  void onAttachClick() async{
    FocusHelper.hideKeyboardByUnFocusRoot();

    showModalBottomSheet(
        context: state.context,
        builder: (ctx){
          return Material(
            child: SizedBox(
              //height: 150,
              width: AppSizes.getScreenWidth(state.context),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 23.0,
                              backgroundColor: AppThemes.currentTheme.primaryColor,
                              child: IconButton(
                                  onPressed: () async {
                                    Navigator.of(state.context).pop();

                                    var image = await ImagePicker().pickImage(
                                      source: ImageSource.camera,
                                      imageQuality: 100,
                                    );

                                    if(image != null){
                                      showImageBeforeSend(image.path);
                                    }
                                  },
                                  icon: Icon(IconList.photoCamera, color: Colors.white,)
                              ),
                            ),
                            SizedBox(height: 10,),
                            Text('${state.tInMap('chatData', 'takePhoto')}'),
                          ],
                        ),

                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 23.0,
                              backgroundColor: AppThemes.currentTheme.primaryColor,
                              child: IconButton(
                                  onPressed: () async {
                                    Navigator.of(state.context).pop();

                                    var image = await ImagePicker().pickImage(
                                      source: ImageSource.gallery,
                                      imageQuality: 100,
                                    );

                                    if(image != null){
                                      showImageBeforeSend(image.path);
                                    }
                                  },
                                  icon: Icon(IconList.gallery, color: Colors.white)
                              ),
                            ),
                            SizedBox(height: 10,),
                            Text('${state.tInMap('chatData', 'gallery')}'),
                          ],
                        ),

                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 23.0,
                              backgroundColor: AppThemes.currentTheme.primaryColor,
                              child: IconButton(
                                  onPressed: () async {
                                    Navigator.of(state.context).pop();

                                    var vid = await ImagePicker().pickVideo(
                                      source: ImageSource.camera,
                                    );

                                    if(vid != null){
                                      showVideoBeforeSend(vid.path);
                                    }
                                  },
                                  icon: Icon(IconList.videoCamera,  color: Colors.white)
                              ),
                            ),
                            SizedBox(height: 10,),
                            Text('${state.tInMap('chatData', 'camera')}'),
                          ],
                        ),

                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 23.0,
                              backgroundColor: AppThemes.currentTheme.primaryColor,
                              child: IconButton(
                                  onPressed: () async {
                                    Navigator.of(state.context).pop();

                                    var vid = await ImagePicker().pickVideo(
                                      source: ImageSource.gallery,
                                    );

                                    if(vid != null){
                                      showVideoBeforeSend(vid.path);
                                    }
                                  },
                                  icon: Icon(IconList.fileVideo, color: Colors.white,)
                              ),
                            ),
                            SizedBox(height: 10,),
                            Text('${state.tInMap('chatData', 'videoFile')}'),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 8,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 23.0,
                              backgroundColor: AppThemes.currentTheme.primaryColor,
                              child: IconButton(
                                  onPressed: () async {
                                    Navigator.of(state.context).pop();

                                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                                      //allowedExtensions: ['mp3', 'wav', 'ogg'],
                                        type: FileType.audio
                                    );

                                    if(result != null){
                                      showAudioBeforeSend(result.paths[0]!);
                                    }
                                  },
                                  icon: Icon(IconList.music, color: Colors.white,)
                              ),
                            ),
                            SizedBox(height: 10,),
                            Text('${state.tInMap('chatData', 'audioFile')}'),
                          ],
                        ),

                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 23.0,
                              backgroundColor: AppThemes.currentTheme.primaryColor,
                              child: IconButton(
                                  onPressed: () async {
                                    Navigator.of(state.context).pop();

                                    FilePickerResult? result = await FilePicker.platform.pickFiles();

                                    if(result != null){
                                      showFileBeforeSend(result.paths[0]!);
                                    }
                                  },
                                  icon: Icon(IconList.file, color: Colors.white)
                              ),
                            ),
                            SizedBox(height: 10,),
                            Text('${state.tInMap('chatData', 'file')}'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
    );
  }

  ProgressState getDownloadState(TicketMediaModel media){
    if(media.uri == null){
      return ProgressState.Fail;
    }

    var tag = Keys.genDownloadTag_ticketMedia(media);
    var di = DownloadUpload.downloadManager.getByTag(tag);

    if(di == null) {
      return ProgressState.Idle;
    }

    if(di.isInQueue()) {
      return ProgressState.Preparing;
    }

    if(di.isInProcess()) {
      return ProgressState.Processing;
    }

    if(di.isError()) {
      return ProgressState.Fail;
    }

    if(di.isComplete()) {
      return ProgressState.Success;
    }

    return ProgressState.Idle;
  }

  ProgressState getUploadState(TicketMediaModel model){
    var tag = Keys.genDownloadTag_ticketMedia(model);
    var di = DownloadUpload.uploadManager.getByTag(tag);

    if(di == null) {
      return ProgressState.Idle;
    }

    if(di.isInQueue()) {
      return ProgressState.Preparing;
    }

    if(di.isInProcess()) {
      return ProgressState.Processing;
    }

    if(di.isError()) {
      return ProgressState.Fail;
    }

    if(di.isComplete()) {
      return ProgressState.Success;
    }

    return ProgressState.Idle;
  }

  void showImageBeforeSend(String path){
    var view = OverlayScreenView(
      content: Material(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 50,
                bottom: 50,
                left: 0,
                right: 0,
                child: FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  child: Image.file(File(path)),
                )
            ),

            Positioned(
              bottom: 32,
                right: 40,
                child: GestureDetector(
                  onTap: (){
                    Navigator.of(state.context).pop('ok');
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.lightBlue,
                    child: Icon(IconList.send, color: Colors.white,),
                  ),
                )
            ),
          ],
        ),
      ),
    );

    OverlayDialog().show(state.context, view).then((value) async {
      if(value != null) {
        final tm = createMessage();
        final media = await _createImageMessage(tm, path);
        beforeSendMessage(tm);
        sinkAndSendMessage(tm, media);
      }
    });
  }

  void showVideoBeforeSend(String path){
    var view = OverlayScreenView(
      content: VideoViewer(
        videoSourceType: VideoSourceType.File,
        srcAddress: path,
      ),
    );

    OverlayDialog().show(state.context, view).then((value) async {
      if(value is VideoInformation){
        var tm = createMessage();
        var media = await _createVideoMessage(tm, path);
        beforeSendMessage(tm);
        sinkAndSendMessage(tm, media);
      }
    });
  }

  void showAudioBeforeSend(String path) async {
    var tm = createMessage();
    var media = await _createAudioMessage(tm, path);
    beforeSendMessage(tm);
    sinkAndSendMessage(tm, media);
  }

  void showFileBeforeSend(String path) async {
    var tm = createMessage();
    var media = await _createFileMessage(tm, path);
    beforeSendMessage(tm);
    sinkAndSendMessage(tm, media);
  }

  void callDeleteMessage(TicketMessageModel msg) async {
    onYes(){
      requestDeleteMessage(msg);
    }

    DialogCenter().showYesNoDialog(state.context, desc: '${state.t('wantToDeleteThisItem')}', yesFn: onYes);
  }

  void requestDeleteMessage(TicketMessageModel msg) async {
    FocusHelper.hideKeyboardByUnFocusRoot();

    final js = <String, dynamic>{};
    js[Keys.request] = 'DeleteTicketMessages';
    js[Keys.userId] = user?.userId;
    js['ticket_id'] = msg.ticketId;
    js['message_id'] = msg.id;

    commonRequester?.bodyJson = js;
    commonRequester?.requestPath = RequestPath.SetData;

    commonRequester?.httpRequestEvents.onFailState = (req) async {
      StateXController.globalUpdate(Keys.toast, stateData: '${state.t('operationFailed')}');
    };

    commonRequester?.httpRequestEvents.onResultOk = (req, data) async {
      TicketManager.deleteMessage(msg, true);

      BroadcastCenter.ticketUpdateNotifier.value = TicketModel();
    };

    commonRequester!.request(state.context);
  }

  void requestOldMessage() async {
    //FocusHelper.hideKeyboardByUnFocusRoot();

    filterRequest.lastCase = state.ticket.findMessageLittleTs();

    final js = <String, dynamic>{};
    js[Keys.request] = 'GetOldTicketMessages';
    js[Keys.userId] = user?.userId;
    js['ticket_id'] = state.ticket.id;
    js[Keys.filtering] = filterRequest.toMap();

    commonRequester?.bodyJson = js;
    commonRequester?.requestPath = RequestPath.GetData;

    commonRequester?.httpRequestEvents.onAnyState = (req) async {

    };

    commonRequester?.httpRequestEvents.onFailState = (req) async {
      if(pullLoadCtr.isRefresh) {
        pullLoadCtr.refreshFailed();
      }
      else {
        pullLoadCtr.loadFailed();
      }
    };

    commonRequester?.httpRequestEvents.onResponseError = (req, isOk) async {
      return true;
    };

    commonRequester?.httpRequestEvents.onResultOk = (req, data) async {
      List? messageList = data['message_list'];
      List? mediaList = data['media_list'];
      List? userList = data['user_list'];
      var domain = data[Keys.domain];

      if(pullLoadCtr.isRefresh) {
        pullLoadCtr.refreshToIdle();
      }
      else {
        int l = messageList?.length?? 0;

        if(l < filterRequest.limit) {
          pullLoadCtr.loadNoData();
        }
        else {
          pullLoadCtr.loadComplete();
        }
      }

      var uList = UserAdvancedManager.addItemsFromMap(userList, domain: domain);
      UserAdvancedManager.sinkItems(uList);

      var m2List = TicketManager.addMediaMessagesFromMap(mediaList);
      var mList = TicketManager.addTicketMessagesFromMap(messageList);

      state.ticket.updateMessageList();
      state.ticket.sortMessages();
      state.stateController.mainStateAndUpdate(StateXController.state$normal);

      TicketManager.sinkTicketMedia(m2List);
      TicketManager.sinkTicketMessages(mList);
    };

    commonRequester!.request(state.context);
  }
}
