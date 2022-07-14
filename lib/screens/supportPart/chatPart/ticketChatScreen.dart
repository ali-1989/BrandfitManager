import 'dart:io';

import 'package:flutter/material.dart';

import 'package:filesize/filesize.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_2.dart';
import 'package:iris_sound_player/soundPlayer/audioPlay.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';
import 'package:iris_tools/api/helpers/localeHelper.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/api/helpers/pathHelper.dart';
import 'package:iris_tools/api/helpers/storageHelper.dart';
import 'package:iris_tools/api/helpers/widgetHelper.dart';
import 'package:iris_tools/plugins/launcher.dart';
import 'package:iris_tools/widgets/buttons/progressButton.dart';
import 'package:iris_tools/widgets/irisImageView.dart';
import 'package:iris_tools/modules/stateManagers/common_refresh.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';
import 'package:iris_tools/widgets/timerView.dart';
import 'package:open_file/open_file.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '/abstracts/stateBase.dart';
import '/managers/ticketManager.dart';
import '/models/dataModels/ticketModels/ticketMediaModel.dart';
import '/models/dataModels/ticketModels/ticketMessageModel.dart';
import '/models/dataModels/ticketModels/ticketModel.dart';
import '/screens/commons/imageFullScreen.dart';
import '/screens/commons/videoPlayer.dart';
import '/screens/supportPart/chatPart/chatBar.dart';
import '/screens/supportPart/chatPart/ticketChatScreenCtr.dart';
import '/system/downloadUpload.dart';
import '/system/enums.dart';
import '/system/extensions.dart';
import '/system/icons.dart';
import '/system/keys.dart';
import '/tools/app/appNavigator.dart';
import '/tools/app/appSizes.dart';
import '/tools/app/appThemes.dart';
import '/tools/playerTools.dart';
import '/views/messageViews/notDataFoundView.dart';
import '/views/preWidgets.dart';

class TicketChatScreen extends StatefulWidget {
  static const screenName = 'TicketChatScreen';
  final TicketModel ticket;

  const TicketChatScreen({
    required this.ticket,
    Key? key,
  }) : super(key: key);

  @override
  State createState() => TicketChatScreenState();
}
///======================================================================================
class TicketChatScreenState extends StateBase<TicketChatScreen> {
  StateXController stateController = StateXController();
  TicketChatScreenCtr controller = TicketChatScreenCtr();
  ItemScrollController itemScrollController = ItemScrollController();
  ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  String idChatBar = 'idChatBar';
  String idListView = 'idListView';
  late TicketModel ticket;
  late Color myColor;
  late TextStyle chatTextStyle;
  late TextStyle dateTextStyle;
  BigInt currentAudioId = BigInt.zero;
  late MediaQueryData mediaQuery;

  @override
  void initState() {
    super.initState();

    controller.onInitState(this);
    ticket = widget.ticket;
    myColor = AppThemes.checkPrimaryByWB(AppThemes.currentTheme.primaryColor, AppThemes.currentTheme.differentColor);
    chatTextStyle = AppThemes.chatTextStyle().copyWith(color: Colors.black);
    dateTextStyle = TextStyle(color: Colors.black.withAlpha(120));
    //itemPositionsListener.itemPositions.addListener();
  }

  @override
  Widget build(BuildContext context) {
    controller.onBuild();
    mediaQuery = MediaQuery.of(context);

    return getScaffold();
  }

  @override
  void dispose() {
    stateController.dispose();
    controller.onDispose();

    super.dispose();
  }

  @override
  Future<bool> onWillBack<S extends StateBase>(S state) async {
    if(controller.isRecordOpen){
      return false;
    }

    return true;
  }

  Widget getScaffold() {
    return WillPopScope(
      onWillPop: () => onWillBack(this),
      child: SizedBox(
        width: AppSizes.getScreenWidth(context),
        height: AppSizes.getScreenHeight(context),
        child: Theme(
          data: AppThemes.themeData.copyWith(
              bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.transparent),
              scrollbarTheme: ScrollbarThemeData(
                thumbColor: MaterialStateProperty.all(Colors.black45),
              ),
          ),
          child: Scaffold(
            backgroundColor: Color(0xFFE7E1D4),
            appBar: getAppbar(),
            //bottomSheet: ,
            body: SafeArea(
                child: getMainBuilder()
            ),
          ),
        ),
      ),
    );
  }

  Widget getMainBuilder(){
    return StateX(
        isMain: true,
        controller: stateController,
        builder: (context, ctr, data) {
          return Builder(
            builder: (context) {
              switch(ctr.mainState){
                case StateXController.state$loading:
                  return PreWidgets.flutterLoadingWidget();

                default:
                  if(widget.ticket.messages.isEmpty){
                    return NotDataFoundView();
                  }

                  return getBody();
              }
            },
          );
        }
    );
  }

  PreferredSizeWidget getAppbar(){
    return AppBar(
      title: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            CommonRefresh(
              tag: Keys.genCommonRefreshTag_ticketAvatar(ticket),
              builder: (ctx, data){
                if(data == null){
                  return CircleAvatar(
                    backgroundColor: ColorHelper.textToColor('${ticket.starterUserId}${ticket.id}'),
                    child: Text('${ticket.starterUser()?.userName.substring(0, 2)}',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  );
                }

                return GestureDetector(
                  onTap: (){
                    final view = ImageFullScreen(
                      imageType: ImageType.File,
                      heroTag: '${ticket.starterUserId}${ticket.id}',
                      imageObj: ticket.getProfileFile(),
                    );

                    AppNavigator.pushNextPageExtra(context, view, name: ImageFullScreen.screenName);
                  },
                  child: Hero(
                    tag: '${ticket.starterUserId}${ticket.id}',
                    child: CircleAvatar(
                      backgroundColor: ColorHelper.textToColor('${ticket.starterUserId}${ticket.id}'),
                      backgroundImage: ticket.getAvatarProvider(),
                    ),
                  ),
                );
              },
            ),

            SizedBox(width: 8,),

            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  Text('${widget.ticket.starterUser()?.userName}'),
                  //Text('typing..'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getBody() {
    return Column(
      children: [
        Expanded(
          child: StateX(
            controller: stateController,
            id: idListView,
            builder: (context, ctr, data) {

              return ScrollablePositionedList.builder(
                itemCount: widget.ticket.messages.length,
                initialScrollIndex: widget.ticket.messages.length,
                itemScrollController: itemScrollController,
                itemPositionsListener: itemPositionsListener,
                itemBuilder: (ctx, idx) {
                  return genChatView(idx);
                },
              );
            }
          ),
        ),

        StateX(
            id: idChatBar,
            controller: stateController,
            builder: (context, ctr, data) {
              if(!ticket.isClose){
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  child: ChatBar(
                    recButton: recView(),
                    expandedView: inputView(),
                  ),
                );
              }

              return SizedBox();
            }
        ),
      ],
    );
  }
  ///==========================================================================================================
  Widget recView() {
    final txt = controller.chatTextCtr.text.trim();

    if(!controller.isRecordOpen && txt.isEmpty) {
      return GestureDetector(
        onTap: () {
          controller.onMicClick();
        },
        child: CircleAvatar(
          radius: 26.0,
          backgroundColor: AppThemes.currentTheme.primaryColor,
          child: Icon(
            IconList.mic,
            color: Colors.white,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: (){
        controller.onSendClick();
      },
      child: CircleAvatar(
        radius: 26.0,
        backgroundColor: AppThemes.currentTheme.primaryColor,
        child: Icon(
          IconList.send,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget inputView() {
    return DecoratedBox(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.0),
          color: Colors.white
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: controller.isRecordOpen? getRecordBox(): getInputBox(),
      ),
    );
  }

  Widget getInputBox(){
    return Row(
      children: [
        Expanded(
          child: Scrollbar(
            thickness: 8,
            scrollbarOrientation: ScrollbarOrientation.right,
            child: TextField(
              controller: controller.chatTextCtr,
              textDirection: stateController.stateDataOrDefault('textDirection', AppThemes.textDirection),
              minLines: 1,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              onChanged: (t){
                stateController.setStateData('textDirection', LocaleHelper.autoDirection(t));
                stateController.update(idChatBar);
              },
              style: TextStyle(color: Colors.black, fontSize: 15.0),
              onEditingComplete: () {},
              decoration: InputDecoration(
                hintText: 'Message',
                hintStyle: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
              ),
            ),
          ),
        ),

        if(controller.chatTextCtr.text.isEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 10,),
              IconButton(
                icon: Icon(IconList.attach, color: Colors.black54,),
                onPressed: (){
                  controller.onAttachClick();
                },
              ),
            ],
          ),
      ],
    );
  }

  Widget getRecordBox(){
    return Row(
      children: [

        IconButton(
            onPressed: (){
              controller.onDeleteRecClick();
            },
            icon: Icon(IconList.delete)
        ),

        SizedBox(width: 10,),
        TimerView(
          controller: controller.timerViewController,
        ),

        SizedBox(width: 10,),
        IconButton(
            onPressed: (){
              controller.onRecPauseClick();
            },
            icon: Icon(controller.isRecordOpen? IconList.pause: IconList.record)
        ),

      ],
    );
  }

  Widget wrapByBubble(TicketMessageModel msg, Widget child){
    final userSender = msg.senderIsUser(widget.ticket);

    return ChatBubble(
      clipper: ChatBubbleClipper2(type:userSender? BubbleType.receiverBubble: BubbleType.sendBubble),
      backGroundColor: userSender? Colors.white: myColor.withAlpha(80),
      alignment: userSender? Alignment.topLeft : Alignment.topRight,
      margin: EdgeInsets.only(top: 10),
      defultPadding: 5,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: mediaQuery.size.width * 0.71,
        ),
        child: child,
      ),
    );
  }

  Widget addDateAndState(TicketMessageModel msg, Widget child){
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: msg.senderIsUser(ticket)? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        child,

        SizedBox(height: 8,),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if(!msg.senderIsUser(ticket))
              Icon(msg.getStateIcon(),
                size:12,
                color: msg.getStateColor(),
              ),
            SizedBox(width: 5,),
            Text(msg.getShowDate(),
              style: dateTextStyle,
            ),
          ],
        ),
      ],
    );
  }

  Widget genChatView(int idx){
    final msg = widget.ticket.messages[idx];

    return CommonRefresh(
      key: ValueKey(msg.id),
      tag: Keys.genCommonRefreshTag_ticketMessage(msg),
      builder: (context, data) {
        return GestureDetector(
          onLongPress: () => showPopMenu(msg, context),
          child: getMessageViewByType(msg, context),
        );
      }
    );
  }

  Widget getMessageViewByType(TicketMessageModel msg, BuildContext context) {
    final isSender = msg.senderUserId == widget.ticket.starterUserId;

    if(msg.type == ChatType.TEXT.typeNum){
      return getTextView(msg);
    }

    final media = TicketManager.getMediaMessageById(msg.mediaId!);

    if(media == null){
      return Text('Not found media!');
    }

    media.prepare();

    if(msg.type == ChatType.AUDIO.typeNum){
      return getAudioView(msg, media);
    }

    if(msg.type == ChatType.IMAGE.typeNum){
      return getImageView(msg, media, isSender);
    }

    if(msg.type == ChatType.VIDEO.typeNum){
      return getVideoView(msg, media, isSender);
    }

    if(msg.type == ChatType.FILE.typeNum){
      return getFileView(msg, media, isSender);
    }

    return SizedBox();
  }

  Widget getTextView(TicketMessageModel msg){
    return wrapByBubble(
        msg,
        addDateAndState(msg, Text('${msg.text}', style: chatTextStyle,))
    );
  }

  Widget getDownUploadView(TicketMessageModel msg, TicketMediaModel media){
    if(media.isDraft){
      return getUploadView(msg, media);
    }
    else {
      return getDownloadView(msg, media);
    }
  }

  Widget getDownloadView(TicketMessageModel msg, TicketMediaModel media){
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: CircleBorder(),
        color: Colors.black26,
      ),
      child: ProgressButton(
        color: Colors.white,
        defaultWidget: Padding(
          padding: EdgeInsets.all(6.0),
          child: Icon(Icons.download_rounded, size: 22, color: Colors.white,),
        ),
        onBuild: (ctx, ctr){
          if(media.isBroken){
            return null;
          }

          ctr.changeState(controller.getDownloadState(media));

          if(ctr.isPreparing) {
            return PreWidgets.prepareLoadWidget();
          }

          if(ctr.isProcessing) {
            final tag = Keys.genDownloadTag_ticketMedia(media);
            final num progress = DownloadUpload.downloadManager.getProgressByTag(tag);

            if (progress > 0.0) {
              return PreWidgets.progressLoadView(MathHelper.percentTop1(progress), color: Colors.white);
            } else {
              return PreWidgets.prepareLoadWidget(color: Colors.white);
            }
          }

          return null;
        },
        onPressed: (ctx, ctr){
          if(media.isBroken){
            return;
          }

          final tag = Keys.genDownloadTag_ticketMedia(media);

          if(ctr.isStartProcessing) {
            DownloadUpload.downloadManager.stopDownloadByTag(tag);
            ctr.changeStateAndUpdate(ProgressState.Idle);
            return;
          }

          controller.startDownload(msg, media);
          ctr.changeStateAndUpdate(ProgressState.Preparing);
        },
      ),
    );
  }

  Widget getUploadView(TicketMessageModel msg, TicketMediaModel media){
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: CircleBorder(),
        color: Colors.grey[500],//AppThemes.currentTheme.accentColor,
      ),
      child: ProgressButton(
        color: Colors.white,
        defaultWidget: Padding(
          padding: EdgeInsets.all(6.0),
          child: Icon(Icons.upload_rounded, size: 22, color: Colors.white,),
        ),
        onBuild: (ctx, ctr){
          if(media.isBroken){
            return null;
          }

          ctr.changeState(controller.getUploadState(media));

          if(ctr.isPreparing) {
            return PreWidgets.prepareLoadWidget();
          }

          if(ctr.isProcessing) {
            final tag = Keys.genDownloadTag_ticketMedia(media);
            final num progress = DownloadUpload.uploadManager.getProgressByTag(tag);

            if (progress > 0.0) {
              return PreWidgets.progressLoadView(MathHelper.percentTop1(progress), color: Colors.white);
            } else {
              return PreWidgets.prepareLoadWidget(color: Colors.white);
            }
          }

          return null;
        },
        onPressed: (ctx, ctr){
          if(media.isBroken){
            return;
          }

          if(ctr.isStartProcessing) {
            final tag = Keys.genDownloadTag_ticketMedia(media);
            DownloadUpload.uploadManager.stopUploadByTag(tag);
            ctr.changeStateAndUpdate(ProgressState.Idle);
            return;
          }

          controller.startUpload(msg, media);
          ctr.changeStateAndUpdate(ProgressState.Preparing);
        },
      ),
    );
  }

  Widget getAudioView(TicketMessageModel msg, TicketMediaModel media){
    return wrapByBubble(
      msg,
      addDateAndState(msg, Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SoundPlayerUI(
            player: PlayerTools.chatAudioPlayer,
            sourceType: SourceType.file,
            track: media.audioTrack,
            audioDuration: media.duration,
            oneLine: false,
            enabled: media.isDownloaded,
            getStateFromPlayer: currentAudioId == media.id,
            backgroundColor: AppThemes.currentTheme.primaryColor.withAlpha(50),
            itemColor: AppThemes.currentTheme.textColor,
            useOfReplaceWidget: !media.isDownloaded || media.isDraft,
            replacePlayWidget: Padding(
              padding: const EdgeInsets.all(4.0),
              child: getDownUploadView(msg, media),
            ),
            beforePlay: (ctx, player) async {
              if(PlayerTools.chatAudioPlayer.playing) {
                await PlayerTools.chatAudioPlayer.stop();
              }

              currentAudioId = media.id!;
            },
          ),
        ],
      ))
    );
  }

  Widget getImageView(TicketMessageModel msg, TicketMediaModel media, bool isSender){
    if(!media.isDownloaded && msg.coverImage == null){
      msg.prepareCover().then((value) {
        CommonRefresh.refresh(Keys.genCommonRefreshTag_ticketMessage(msg), null);
      });
    }

    return wrapByBubble(
        msg,
        addDateAndState(msg, Stack(
          alignment: Alignment.center,
          children: [
            Builder(
              builder: (ctx){
                if(media.isDownloaded){
                  return GestureDetector(
                    child: Hero(
                        tag: '${media.id}',
                        child: Image.file(File(media.mediaPath!),
                          width: media.width!.toDouble(),
                          //height: media.height!.toDouble(),
                          fit: BoxFit.contain,
                        )
                    ),
                    onTap: (){
                      final view = ImageFullScreen(
                        heroTag: '${media.id}',
                        imageObj: File(media.mediaPath!),
                        imageType: ImageType.File,
                      );
                      AppNavigator.pushNextPageExtra(context, view, name: ImageFullScreen.screenName);
                    },
                  );
                }

                if(msg.coverImage == null) {
                  return SizedBox(width: media.width!.toDouble(), height: media.height!.toDouble(),);
                }
                else {
                  return Image.memory(msg.coverImage!,
                    width: media.width!.toDouble(),
                    //height: media.height!.toDouble(),
                    fit: BoxFit.contain,
                  );
                }
              },
            ),

            if(!media.isDownloaded || media.isDraft)
              getDownUploadView(msg, media),

            /*Positioned.directional(
              textDirection: isSender? TextDirection.ltr: TextDirection.rtl,
              top: 10,
              start: 10,
              child: Card(
                color: Colors.black45,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Text('${media.volume}', style: TextStyle(color: Colors.white),),
                ),
              ),
            ),*/
          ],
        ))
    );
  }

  Widget getVideoView(TicketMessageModel msg, TicketMediaModel media, bool isSender){
    final w = media.screenshotModel?.width.toDouble()?? 150;
    final h = media.screenshotModel?.height.toDouble()?? 150;

    if(!media.isDownloaded && msg.coverImage == null){
      msg.prepareCover().then((value) {
        CommonRefresh.refresh(Keys.genCommonRefreshTag_ticketMessage(msg), null);
      });
    }

    return wrapByBubble(
        msg,
        addDateAndState(msg, Stack(
          alignment: Alignment.center,
          children: [
              Builder(
                builder: (ctx){
                  if(media.isDownloaded){
                    return GestureDetector(
                      child: Hero(
                          tag: '${media.id}',
                          child: IrisImageView(
                            width: w,
                            height: h,
                            beforeLoadFn: (){
                              if(media.screenshotPath != null){
                                return Image.file(File(media.screenshotPath!),
                                  width: w, height: h, fit: BoxFit.fill);
                              }

                              if(msg.coverImage != null){
                                return Image.memory(msg.coverImage!,
                                    width: w, height: h, fit: BoxFit.fill);
                              }

                              return SizedBox(width: w, height: h,);
                            },
                            bytes: media.screenshotModel?.screenshotBytes,
                            imagePath: media.mediaPath! + '.cov',
                            url: media.screenshotModel?.uri,
                          )
                      ),
                      onTap: (){
                        if(media.isDownloaded) {
                          final view = VideoPlayerView(
                            heroTag: '${media.id}',
                            srcAddress: media.mediaPath!,
                          );

                          AppNavigator.pushNextPageExtra(context, view, name: ImageFullScreen.screenName);
                        }
                      },
                    );
                  }

                  return IrisImageView(
                    width: w,
                    //height: h,
                    beforeLoadWidget: (msg.coverImage != null)?
                    Image.memory(msg.coverImage!, width: w, height: MathHelper.minDouble(w, h), fit: BoxFit.cover,)
                        : SizedBox(width: w, height: MathHelper.minDouble(w, h),),
                    bytes: media.screenshotModel?.screenshotBytes,
                    imagePath: media.mediaPath! + '.cov',
                    url: media.screenshotModel?.uri,
                  );
                },
              ),

            if(!media.isDownloaded || media.isDraft)
              getDownUploadView(msg, media),

            Positioned.directional(
              textDirection: isSender? TextDirection.ltr: TextDirection.rtl,
              top: 6,
              start: 6,
              child: Card(
                color: Colors.black45.withAlpha(120),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Text(filesize(media.volume),
                    style: TextStyle(color: Colors.white),
                    textDirection: TextDirection.ltr,
                  ),
                ),
              ),
            ),
          ],
        ))
    );
  }

  Widget getFileView(TicketMessageModel msg, TicketMediaModel media, bool isSender){
    final isOk = media.isDownloaded && !media.isDraft;

    return wrapByBubble(
        msg,
        addDateAndState(msg,
            Directionality(
              textDirection: TextDirection.ltr,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              GestureDetector(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      isOk? Icon(IconList.file) : getDownUploadView(msg, media),
                      SizedBox(width: 12,),
                      Text('${media.name}'),
                    ],
                  ),
                  onTap: () async {
                    if(media.isDownloaded) {
                      final res = await Launcher.openFileBySystem(media.mediaPath!);

                      if(res.type == ResultType.fileNotFound){
                        StateXController.globalUpdate(Keys.toast, stateData: '${t('thereAreNoResults')}');
                      }
                      else if(res.type != ResultType.done){
                        StateXController.globalUpdate(
                            Keys.toast,
                            stateData: '${t('noAppFoundToOpenThis')}'
                        );
                      }
                    }
                  },
                ),

              SizedBox(height: 10,),
              Text(filesize(media.volume),).boldFont().alpha(),
          ],
        ),
            ))
    );
  }

  void showPopMenu(TicketMessageModel msg, BuildContext context){
    final box = WidgetHelper.getRenderBox(context);
    TicketMediaModel? media;

    if(msg.mediaId != null) {
      media = TicketManager.getMediaMessageById(msg.mediaId!);
    }

    if(box == null){
      return;
    }

    final position = box.localToGlobal(Offset.zero);
    final rect = RelativeRect.fromLTRB(40, position.dy+20, 40, 20);
    final list = <PopupMenuEntry>[];

    final del = PopupMenuItem(
        padding: EdgeInsets.zero,
        value: 'deleteMessage',
        child: ColoredBox(color: Colors.pink,
          child: TextButton.icon(
            icon: Icon(IconList.delete),
            label: Text('${context.t('delete')}'),
            onPressed: (){
              controller.callDeleteMessage(msg);
            },
          ),
        )
    );
    //.....................................................
    final saveDownload = PopupMenuItem(
        padding: EdgeInsets.zero,
        value: 'saveToDownloads',
        child: ColoredBox(color: Colors.pink,
          child: TextButton.icon(
            icon: Icon(IconList.delete),
            label: Text('${context.t('saveToDownloads')}'),
            onPressed: () async {
              final dir = await StorageHelper.getAndroidDownloadsDir();
              final fPath = media!.mediaPath;
              final fName = PathHelper.getFileName(fPath!);
              final newPath = dir! + PathHelper.getSeparator() + fName;

              // ignore: unawaited_futures
              FileHelper.copy(fPath, newPath).then((value){
                StateXController.globalUpdate(Keys.toast, stateData: "The '$fName' file was copied to Download");
              });
            },
          ),
        )
    );
    //.....................................................

    list.add(del);

    if(msg.type == ChatType.IMAGE.typeNum){
      if(media!.isDownloaded) {
        list.add(saveDownload);
      }
    }
    else if(msg.type == ChatType.VIDEO.typeNum){
      if(media!.isDownloaded) {
        list.add(saveDownload);
      }
    }
    else if(msg.type == ChatType.AUDIO.typeNum){
      if(media!.isDownloaded) {
        list.add(saveDownload);
      }
    }

    showMenu(context: context, position: rect, items: list,);
  }
}
