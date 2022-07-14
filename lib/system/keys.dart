// ignore_for_file: non_constant_identifier_names

import '/database/models/userAdvancedModelDb.dart';
import '/models/dataModels/advertisingModel.dart';
import '/models/dataModels/chatModels/chatMediaModel.dart';
import '/models/dataModels/chatModels/chatMessageModel.dart';
import '/models/dataModels/chatModels/chatModel.dart';
import '/models/dataModels/courseModels/courseModel.dart';
import '/models/dataModels/ticketModels/ticketMediaModel.dart';
import '/models/dataModels/ticketModels/ticketMessageModel.dart';
import '/models/dataModels/ticketModels/ticketModel.dart';
import '/models/dataModels/usersModels/appUserModel.dart';

class Keys {
  Keys._();

  static const ok = 'ok';
  static const request = 'request';
  static const result = 'result';
  static const resultList = 'result_list';
  static const subRequest = 'sub_request';
  static const multiRequest = 'multi_request';
  static const multiResult = 'multi_result';
  static const command = 'command';
  static const section = 'section';
  static const error = 'error';
  static const cause = 'cause';
  static const causeCode = 'cause_code';
  static const adminCommand = 'admin_command';
  static const deviceId = 'device_id';
  static const userId = 'user_id';
  static const forUserId = 'for_user_id';
  static const userName = 'user_name';
  static const userType = 'user_type';
  static const userData = 'user_data';
  static const fileName = 'file_name';
  static const partName = 'part_name';
  static const token = 'token';
  static const appVersion = 'app_version';
  static const appName = 'app_name';
  static const value = 'value';
  static const name = 'name';
  static const key = 'key';
  static const iso = 'iso';
  static const family = 'family';
  static const sex = 'sex';
  static const birthdate = 'birthdate';
  static const title = 'title';
  static const type = 'type';
  static const domain = 'domain';
  static const requesterId = 'requester_id';
  static const count = 'count';
  static const fileUri = 'file_uri';
  static const data = 'data';
  static const subData = 'sub_data';
  static const date = 'date';
  static const state = 'state';
  static const options = 'options';
  static const filtering = 'filtering';
  static const jsonHttpPart = 'json';
  static const mobileNumber = 'mobile_number';
  static const phoneCode = 'phone_code';
  static const languageIso = 'language_iso';
  static const countryIso = 'country_iso';
  static const profileImageUri = 'profile_image_uri';
  static const profileImagePath = 'profile_image_path';
  static const imageUri = 'image_uri';
  static const mirror = 'mirror';
  static const imagePath = 'image_path';
  static const path = 'path';
  static const uri = 'uri';
  static const id = 'id';
  static const description = 'description';
  static const orderNum = 'order_num';
  static const nodeName = 'node_name';
  static const extraJs = 'extra_js';
  static const mustSync = 'must_sync';
  static const mustOpenChat = 'must_open_chat';
  //----- app -----------------------------------------------------------------
  static const lastLoginDate = 'last_login_date';
  static const appSettings = 'AppSettings';
  static const toast = 'toast';
  static const updateAdvertisingCache = 'update_advertising_cache';
  //----- settings key -----------------------------------------------------------------
  static const sk$chatNotificationEnable = 'ChatNotificationEnable';
  static const sk$appNotificationEnable = 'AppNotificationEnable';
  static const sk$autoDownloadImages = 'AutoDownloadImages';
  static const sk$autoDownloadVideos = 'AutoDownloadVideos';
  static const sk$confirmOnExit = 'ConfirmOnExit';
  static const sk$currencySymbol = 'CurrencySymbol';
  static const sk$ColorThemeName = 'ColorThemeName';
  static const sk$patternKey = 'lockPattern';
  static const sk$lastForegroundTs = 'lastForegroundTs';
  static const setting$notificationChanelKey = 'notification_chanel_key';
  static const setting$notificationModel = 'notification_model';
  static const setting$notificationChanelGroup = 'notification_chanel_group';
  
  static final List<String> mainMaterialFundamentals = [
    'calories',
    'protein',
    'carbohydrate',
    'fat',
    //'sugar',
  ];

  static String genDownloadKey_userAvatar(int userId) {
    return 'downloadUserAvatar_$userId';
  }

  static String genCommonRefreshTag_userLimit(UserAdvancedModelDb obj){
    return 'user_${obj.userId}';
  }

  static String genCommonRefreshTag_ticketAvatar(TicketModel obj){
    return 'user_${obj.starterUserId}';
  }

  static String genCommonRefreshTag_chatAvatar(ChatModel obj){
    return 'chatAvatar_${obj.id}';
  }

  static String genCommonRefreshTag_ticketMessage(TicketMessageModel obj){
    return 'ticketMessage${obj.id}';
  }

  static String genCommonRefreshTag_chatMessage(ChatMessageModel obj){
    return 'chatMessage${obj.id}';
  }

  static String genDownloadTag_ticketMedia(TicketMediaModel model){
    return 'tmm_${model.id}';
  }

  static String genDownloadTag_chatMedia(ChatMediaModel model){
    return 'cmm_${model.id}';
  }

  static String genDownloadTag_advertising(AdvertisingModel model){
    return 'adv_${model.id}';
  }

  static String genDownloadTag_serverUser(AppUserModel model){
    return 'su_${model.userId}';
  }

  static String genCacheKey_course(CourseModel model){
    return 'courseModelImage${model.id}';
  }
}
