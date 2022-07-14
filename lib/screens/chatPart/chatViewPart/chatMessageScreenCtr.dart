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
import '/database/models/userAdvancedModelDb.dart';
import '/managers/chatManager.dart';
import '/managers/userAdvancedManager.dart';
import '/models/dataModels/chatModels/chatMediaModel.dart';
import '/models/dataModels/chatModels/chatMessageModel.dart';
import '/models/dataModels/chatModels/chatModel.dart';
import '/models/dataModels/chatModels/shotModel.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/models/holderModels/chatDownloadUploadHolder.dart';
import '/screens/chatPart/chatViewPart/chatMessageScreen.dart';
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

class ChatMessageScreenCtr implements ViewController {
  late ChatMessageScreenState state;
  late Requester commonRequester;
  late ChatManager chatManager;
  UserModel? user;
  bool isRecordOpen = false;
  late TimerViewController timerViewController;
  var chatTextCtr = TextEditingController();
  String? audioRecPath;
  var pullLoadCtr = pull.RefreshController();
  late FilterRequest filterRequest;
  late StreamSubscription downloadSub;
  late StreamSubscription uploadSub;
  late CacheMap<String, Uint8List> imageCache;
  late UserAdvancedModelDb user1;
  late UserAdvancedModelDb user2;

  @override
  void onInitState<E extends State>(E state){
    this.state = state as ChatMessageScreenState;

    commonRequester = Requester();
    filterRequest = FilterRequest();
    user = Session.getLastLoginUser();
    timerViewController = TimerViewController();
    chatManager = ChatManager.managerFor(user!.userId);
    //state.stateController.mainState = StateXController.state$loading;
    imageCache = CacheMap(20);

    BroadcastCenter.chatMessageUpdateNotifier.addListener(onNewMessageOrUpdate);

    downloadSub = DownloadUpload.downloadManager.addListener(onDownload);
    uploadSub = DownloadUpload.uploadManager.addListener(onUpload);
    user1 = UserAdvancedManager.getById(state.widget.chatModel.members[1])!;
    user2 = UserAdvancedManager.getById(state.widget.chatModel.members[0])!;// leftSide (sender)

    state.addPostOrCall(() {
      downloadAvatars();
      BroadcastCenter.openedChatId = state.chatModel.id;
    });
  }

  @override
  void onBuild(){
  }

  @override
  void onDispose(){
    BroadcastCenter.openedChatId = null;
    PlayerTools.chatAudioPlayer.stop();
    HttpCenter.cancelAndClose(commonRequester.httpRequester);
    downloadSub.cancel();
    uploadSub.cancel();
    BroadcastCenter.chatMessageUpdateNotifier.removeListener(onNewMessageOrUpdate);
  }

  void onNewMessageOrUpdate(){
    state.stateController.updateMain();

    final lastPos = state.itemPositionsListener.itemPositions.value.last;
    final allMessages = state.chatModel.messages.length;

    if(allMessages > 2 && lastPos.index >= allMessages -2) {
      state.itemScrollController.scrollTo(index: state.chatModel.messages.length, duration: Duration(milliseconds: 100));
    }
  }
  ///========================================================================================================
  /*void tryAgain(State state){
    if(state is ChatScreenState) {
      state.stateController.mainStateAndUpdate(StateXController.state$loading);
    }
  }*/

  void downloadAvatars(){
    final t1 = Keys.genDownloadKey_userAvatar(user1.userId);
    final t2 = Keys.genDownloadKey_userAvatar(user2.userId);

    if(user1.profileUri != null) {
      user1.profilePath = user1.genProfilePath();

      final item1 = DownloadUpload.downloadManager.createDownloadItem(
          user1.profileUri!,
          savePath: user1.genProfilePath(),
          tag: t1);
      item1.category = DownloadCategory.userProfile;
      item1.subCategory = t1;

      DownloadUpload.downloadManager.enqueue(item1);
    }

    if(user2.profileUri != null) {
      user2.profilePath = user2.genProfilePath();

      final item1 = DownloadUpload.downloadManager.createDownloadItem(
          user2.profileUri!,
          savePath: user2.genProfilePath(),
          tag: t2);
      item1.category = DownloadCategory.userProfile;
      item1.subCategory = t2;

      DownloadUpload.downloadManager.enqueue(item1);
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

  void onDownload(DownloadItem di){
    if(di.isInCategory(DownloadCategory.chatMedia)) {
      CommonRefresh.refresh(di.subCategory!, di);
    }

    if(di.isInCategory(DownloadCategory.userProfile)) {
      CommonRefresh.refresh(di.subCategory!, di);
    }
  }

  void onUpload(UploadItem up){
    if(up.isInCategory(DownloadCategory.chatMedia)) {
      CommonRefresh.refresh(up.subCategory!, up);

      if(up.isComplete()){
        PlayerTools.playChatMessageSend();
      }
    }
  }

  void startDownload(ChatMessageModel msg, ChatMediaModel media){
    var tag = Keys.genDownloadTag_chatMedia(media);
    var current = DownloadUpload.downloadManager.getByTag(tag);

    if(current != null && current.isInProcess()){
      return;
    }

    PermissionTools.isGrantedStoragePermission().then((status){
      if(status) {
        media.prepareMediaPath(false);

        final holder = ChatDownloadUploadHolder();
        holder.ownerId = msg.senderUserId;
        holder.chatId = msg.chatId;
        holder.messageId = msg.id;
        holder.mediaId = msg.mediaId;
        holder.messageModel = msg;
        holder.mediaModel = media;

        var di = DownloadUpload.downloadManager.createDownloadItem(media.uri!, tag: tag, savePath: media.mediaPath!);
        di.forceCreateNewFile = true;//todo: comment this in ver 2
        di.category = DownloadCategory.chatMedia;
        di.subCategory = Keys.genCommonRefreshTag_chatMessage(msg);
        di.attach = holder;

        DownloadUpload.downloadManager.enqueue(di);
      }
    });
  }

  void startUpload(ChatMessageModel msg, ChatMediaModel media){
    var tag = Keys.genDownloadTag_chatMedia(media);
    var current = DownloadUpload.uploadManager.getByTag(tag);

    if(current != null && current.isInProcess()){
      return;
    }

    ChatManager.sendMessage(msg);
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

  ChatMessageModel createMessage(){
    var tm = ChatMessageModel();
    tm.id = BigInt.from(Generator.generateDateMillWith6Digit());
    tm.isDraft = true;
    tm.chatId = state.chatModel.id;
    tm.senderUserId = user!.userId;
    tm.sendDate = ServerTimeTools.utcTimeMatchServer;
    tm.sendTs = DateHelper.toTimestamp(tm.sendDate!);

    return tm;
  }

  Future<ChatMediaModel> createMedia(ChatMessageModel tm, String filePath) async{
    var m = ChatMediaModel();

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

  Future sinkAndSendMessage(ChatMessageModel tm, ChatMediaModel? media) async{
    if(media != null) {
      if(media.screenshotModel != null && media.screenshotModel!.screenshotBytes != null ){
        /*await*/ FileHelper.writeBytes(media.screenshotPath!, media.screenshotModel!.screenshotBytes!);
      }

      ChatManager.sinkChatMedia([media]);
    }

    ChatManager.sinkChatMessages([tm]);
    return ChatManager.sendMessage(tm);
  }

  Future<ChatMediaModel> _createAudioMessage(ChatMessageModel tm, String path) async{
    tm.type = ChatType.AUDIO.typeNum;
    var media = await createMedia(tm, path);
    ChatManager.addMediaMessage(media);
    tm.mediaId = media.id;

    return media;
  }

  Future<ChatMediaModel> _createImageMessage(ChatMessageModel tm, String path) async{
    //state.showLoading();

    tm.type = ChatType.IMAGE.typeNum;
    var media = await createMedia(tm, path);
    ChatManager.addMediaMessage(media);
    tm.mediaId = media.id;

    //state.hideLoading();
    return media;
  }

  Future<ChatMediaModel> _createVideoMessage(ChatMessageModel tm, String path) async{
    //state.showLoading();

    tm.type = ChatType.VIDEO.typeNum;
    var media = await createMedia(tm, path);
    ChatManager.addMediaMessage(media);
    tm.mediaId = media.id;
    media.screenshotPath = DirectoriesCenter.getScreenshotFile(extension: 'jpg');

    //state.hideLoading();
    return media;
  }

  Future<ChatMediaModel> _createFileMessage(ChatMessageModel tm, String path) async{
    tm.type = ChatType.FILE.typeNum;
    var media = await createMedia(tm, path);
    ChatManager.addMediaMessage(media);
    tm.mediaId = media.id;

    return media;
  }

  void beforeSendMessage(ChatMessageModel tm){
    final add = state.chatModel.addMessage(tm);

    if(add){
      ChatManager.allMessageList.add(tm);
    }

    state.chatModel.updateLastSeenDate(dateTs: tm.sendDate!);
    BroadcastCenter.chatUpdateNotifier.value = state.chatModel;

    state.stateController.update(state.idListView);

    if(state.chatModel.messages.length > 2) {
      state.itemScrollController.scrollTo(index: state.chatModel.messages.length, duration: Duration(milliseconds: 100));
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


  ProgressState getDownloadState(ChatMediaModel media){
    if(media.uri == null){
      return ProgressState.Fail;
    }

    var tag = Keys.genDownloadTag_chatMedia(media);
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

  ProgressState getUploadState(ChatMediaModel model){
    var tag = Keys.genDownloadTag_chatMedia(model);
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
        var tm = createMessage();
        var media = await _createImageMessage(tm, path);
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

  void callDeleteMessage(ChatMessageModel msg) async {
    onYes(){
      requestDeleteMessage(msg);
    }

    DialogCenter().showYesNoDialog(state.context, desc: '${state.t('wantToDeleteThisItem')}', yesFn: onYes);
  }

  void requestDeleteMessage(ChatMessageModel msg) async {
    FocusHelper.hideKeyboardByUnFocusRoot();

    final js = <String, dynamic>{};
    js[Keys.request] = 'DeleteChatMessages';
    js[Keys.userId] = user?.userId;
    js['chat_id'] = msg.chatId;
    js['message_id'] = msg.id;

    commonRequester.bodyJson = js;
    commonRequester.requestPath = RequestPath.SetData;

    commonRequester.httpRequestEvents.onFailState = (req) async {
      StateXController.globalUpdate(Keys.toast, stateData: '${state.t('operationFailed')}');
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      ChatManager.deleteMessage(msg, true);

      BroadcastCenter.chatUpdateNotifier.value = ChatModel();
    };

    commonRequester.request(state.context);
  }

  void requestOldMessage() async {
    //FocusHelper.hideKeyboardByUnFocusRoot();

    filterRequest.lastCase = state.chatModel.findMessageLittleTs();

    final js = <String, dynamic>{};
    js[Keys.request] = 'GetOldChatMessages';
    js[Keys.userId] = user?.userId;
    js['chat_id'] = state.chatModel.id;
    js[Keys.filtering] = filterRequest.toMap();

    commonRequester.bodyJson = js;
    commonRequester.requestPath = RequestPath.GetData;

    commonRequester.httpRequestEvents.onAnyState = (req) async {

    };

    commonRequester.httpRequestEvents.onFailState = (req) async {
      if(pullLoadCtr.isRefresh) {
        pullLoadCtr.refreshFailed();
      }
      else {
        pullLoadCtr.loadFailed();
      }
    };

    commonRequester.httpRequestEvents.onResponseError = (req, isOk) async {
      return true;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
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

      var m2List = ChatManager.addMediaMessagesFromMap(mediaList);
      var mList = ChatManager.addMessagesFromMap(messageList);

      state.chatModel.updateMessageList();
      state.chatModel.sortMessages();
      state.stateController.mainStateAndUpdate(StateXController.state$normal);

      ChatManager.sinkChatMedia(m2List);
      ChatManager.sinkChatMessages(mList);
    };

    commonRequester.request(state.context);
  }
}
