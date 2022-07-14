import 'package:iris_download_manager/downloadManager/downloadManager.dart';
import 'package:iris_download_manager/uploadManager/uploadManager.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/modules/stateManagers/common_refresh.dart';

import '/managers/chatManager.dart';
import '/managers/ticketManager.dart';
import '/managers/userAdvancedManager.dart';
import '/models/dataModels/ticketModels/ticketMediaModel.dart';
import '/models/dataModels/ticketModels/ticketMessageModel.dart';
import '/models/holderModels/chatAvatarHolder.dart';
import '/models/holderModels/chatDownloadUploadHolder.dart';
import '/models/holderModels/ticketDownloadUploadHolder.dart';
import '/system/keys.dart';
import '/tools/centers/broadcastCenter.dart';

class DownloadUpload {
  DownloadUpload._();

  static late DownloadManager downloadManager;
  static late UploadManager uploadManager;

  static void commonDownloadListener(DownloadItem di) async {

    if(di.isComplete()) {
      /*if(di.isInCategory(DownloadCategory.advertisingUser)){
        Map<String, dynamic> val = {Keys.imagePath: di.savePath};

        await DbCenter.db.update(DbCenter.tbAdvertising, val,
            Conditions().add(Condition()..key = 'id'..value = di.attach));

        AdvertisingTools.prepareCarousel();
      }*/
      //-------------------------------------------------------------------
      if (di.isInCategory(DownloadCategory.ticketAvatar)) {
        final id = MathHelper.clearToInt(di.subCategory);
        final userId = di.attach;
        final ticket = TicketManager.managerFor(userId).getById(id);

        if (ticket != null) {
          final userId = ticket.starterUserId;
          final limitUser = UserAdvancedManager.getById(userId!);

          if (limitUser != null) {
            limitUser.profilePath = di.savePath!;
            //todo: delete last file
            CommonRefresh.refresh(Keys.genCommonRefreshTag_ticketAvatar(ticket), limitUser.profilePath);
          }
        }
      }
      //-------------------------------------------------------------------
      if (di.isInCategory(DownloadCategory.chatAvatar)) {
        final ChatAvatarHolder holder = di.attach;
        var chat = holder.chatModel;

        chat ??= ChatManager.managerFor(holder.userId!).getById(holder.chatId!);

        if (chat != null) {
          var limitUser = holder.userModel;
          limitUser ??= UserAdvancedManager.getById(holder.addresseeId?? 0);

          if (limitUser != null) {
            limitUser.profilePath = di.savePath!;
            //todo: delete last file
            CommonRefresh.refresh(Keys.genCommonRefreshTag_chatAvatar(chat), limitUser.profilePath);
          }
        }
      }
      //-------------------------------------------------------------------
      if (di.isInCategory(DownloadCategory.ticketMedia)) {
        final TicketDownloadUploadHolder holder = di.attach;

        var media = holder.mediaModel;
        media ??= TicketManager.getMediaMessageById(holder.mediaId!);

        media?.isDownloaded = true;
      }
      //-------------------------------------------------------------------
      if (di.isInCategory(DownloadCategory.chatMedia)) {
        final ChatDownloadUploadHolder holder = di.attach;

        var media = holder.mediaModel;
        media ??= ChatManager.getMediaById(holder.mediaId!);

        media?.isDownloaded = true;
      }
      //-------------------------------------------------------------------
    }
  }

  static void commonUploadListener(UploadItem ui) async {

    if(ui.isComplete()) {
      if (ui.isInCategory(DownloadCategory.ticketMedia)) {
        if(ui.response == null){
          return;
        }

        final json = JsonHelper.jsonToMap<String, dynamic>(ui.response!.data)!;

        if(json[Keys.result] != Keys.ok){
          return;
        }

        final TicketDownloadUploadHolder holder = ui.attach;
        final TicketMessageModel tm = holder.messageModel!;
        final media = TicketManager.getMediaMessageById(holder.mediaId!);

        final serverTm = TicketMessageModel.fromMap(json[Keys.mirror]);
        final serverMedia = TicketMediaModel.fromMap(json['media_mirror']);


        // ignore: unawaited_futures
        TicketManager.deleteDraftMessages([tm]);
        // ignore: unawaited_futures
        TicketManager.deleteDraftMedias([media!]);

        tm.matchBy(serverTm);
        media.matchBy(serverMedia);
        tm.isDraft = false;
        media.isDraft = false;
        tm.mediaId = serverMedia.id;
        //todo re id any reply message reference to oldId

        // ignore: unawaited_futures
        TicketManager.sinkTicketMedia([media]);
        // ignore: unawaited_futures
        TicketManager.sinkTicketMessages([tm]);

        BroadcastCenter.ticketMessageUpdateNotifier.value = tm;
      }
      //-------------------------------------------------------------------
    }
  }
}
///==========================================================================
class DownloadCategory {
  static const ticketAvatar = 'ticket_avatar';
  static const chatAvatar = 'chat_avatar';
  static const ticketMedia = 'ticket_media';
  static const chatMedia = 'chat_media';
  static const userProfile = 'user_profile';
  static const advertisingManager = 'advertising_manage';
  static const advertisingUser = 'advertising_manage';
}
