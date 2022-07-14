import 'package:flutter/material.dart';

import '/abstracts/stateBase.dart';
import '/models/dataModels/chatModels/chatModel.dart';
import '/screens/chatPart/chatViewPart/chatMessageScreen.dart';
import '/system/extensions.dart';
import '/system/icons.dart';
import '/tools/app/appNavigator.dart';

class ChatListItem extends StatefulWidget {
  final ChatModel chatModel;

  const ChatListItem({
    required this.chatModel,
    Key? key,
  }) : super(key: key);

  @override
  _ChatListItemState createState() => _ChatListItemState();
}
///==================================================================================
class _ChatListItemState extends StateBase<ChatListItem> {
  late ChatModel chatModel;

  @override
  void initState() {
    super.initState();

    chatModel = widget.chatModel;
  }

  @override
  void didUpdateWidget(ChatListItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    chatModel = widget.chatModel;
  }

  @override
  Widget build(BuildContext context) {
    //final unReadCount = chatModel.unReadCount();
    //prepareAvatar();

    return GestureDetector(
      key: ValueKey(chatModel.id),
      onTap: (){
        AppNavigator.pushNextPage(
            context,
            ChatMessageScreen(chatModel: chatModel),
            name: ChatMessageScreen.screenName
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /*CommonRefresh(
                    tag: Keys.genCommonRefreshTag_chatAvatar(chatModel),
                    builder: (ctx, data){
                      if(data == null){
                        return CircleAvatar(
                          backgroundColor: ColorHelper.textToColor('${chatModel.creatorUserId}${chatModel.id}'),
                          child: Text('chatModel.starterUser()?.userName'.substring(0, 2),
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        );
                      }

                      return CircleAvatar(
                        backgroundColor: ColorHelper.textToColor('${chatModel.creatorUserId}${chatModel.id}'),
                        backgroundImage: chatModel.getAvatarProvider(chatModel.receiverUser()?.userId?? 0),
                      );
                    },
                  ),*/

                  SizedBox(height: 4,),

                  if(chatModel.isDelete)
                    Icon(IconList.delete, size: 16,).alpha(),
                ],
              ),

              SizedBox(width: 10,),

              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text('${tInMap('chatPage', 'chatBetween')}',
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                          ).bold().alpha(),
                        ),

                        Text(chatModel.getLastMessageDate()).subAlpha(),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(chatModel.getTitleView(),
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                          ).bold().fsR(2),
                        ),
                      ],
                    ),

                    /*Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text( 'chatModel.starterUser()?.userName??'),
                      ],
                    ),*/

                    /*Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Builder(
                          builder: (ctx){
                            if(chatModel.lastMessage != null && !chatModel.lastMessage!.senderIsUser(chatModel)){
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(chatModel.lastMessage?.getStateIcon(),
                                    size:12,
                                    color: chatModel.lastMessage?.getStateColor(),
                                  ),

                                  SizedBox(width: 8,),
                                ],
                              );
                            }

                            return SizedBox();
                          },
                        ),

                        Expanded(
                          child: Text(getLastMessage(),
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                          ).boldFont().subAlpha(),
                        ),

                        Badge(
                          showBadge: unReadCount > 0,
                          padding: EdgeInsets.all(10),
                          elevation: 0,
                          badgeContent: Text('$unReadCount',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              fontFamily: FontManager.instance.getEnglishFont()?.family
                            ),
                          ),
                          badgeColor: Colors.green,
                          alignment: Alignment.center,
                        ),
                      ],
                    ),*/
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose(){
    super.dispose();
  }

  String getLastMessage(){
    if(chatModel.lastMessage == null){
      return '';
    }

    if(chatModel.lastMessage!.type == 1) {
      return chatModel.lastMessage?.text ?? '';
    }

    final type = chatModel.getChatMessageType(chatModel.lastMessage);
    return context.tInMap('chatData', type)!;
  }

  void prepareAvatar() async {
    /*final path = chatModel.getAvatarPath();

    /// means not exist uri
    if(path == null){
      return;
    }

    final tag = Keys.genCommonRefreshTag_ticketAvatar(chatModel);
    final isDownloading = DownloadUpload.downloadManager.getByTag(tag);

    if(isDownloading == null) {
      final di = DownloadUpload.downloadManager.createDownloadItem(chatModel.getAvatarUri()!, tag: tag, savePath: path);
      di.category = DownloadCategory.ticketAvatar;
      di.subCategory = '${chatModel.id}';
      di.attach = Session.getLastLoginUser()?.userId;

      await DownloadUpload.downloadManager.enqueue(di);
    }
    else {
      if(isDownloading.canReset()){
        await DownloadUpload.downloadManager.enqueue(isDownloading);
      }

      if(chatModel.starterUser()?.profilePath != null){
        return;
      }

      if(await MediaTools.isImage(path)){
        chatModel.starterUser()?.profilePath = path;
        update();
      }
    }*/
  }
}
