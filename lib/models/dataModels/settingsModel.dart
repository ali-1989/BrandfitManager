import 'dart:ui';

import 'package:iris_tools/dateSection/calendarTools.dart';

import '/system/keys.dart';

class SettingsModel {
  int? lastUserId;
  String? currentRouteScreen;
  Locale appLocale = const Locale('en', 'US');
  CalendarType calendarType = CalendarType.byType(TypeOfCalendar.unKnow);
  String? dateFormat;
  String? languageIso;
  String? countryIso;
  String? colorTheme;
  String? appPatternKey;
  String? lastForegroundTs;
  bool chatNotification = true;
  bool appNotification = true;
  bool autoDownloadImages = true;
  bool autoDownloadVideos = false;
  bool confirmOnExit = true;
  String? httpAddress;
  String? wsAddress;
  String? proxyAddress;
  int? appVersion;

  SettingsModel();

  SettingsModel.fromMap(Map map){
    lastUserId = map['last_user_id'];
    //no need this is in RouteCenter. currentRouteScreen = map['current_route_screen'];
    dateFormat = map['date_format'];
    languageIso = map[Keys.languageIso];
    countryIso = map[Keys.countryIso];
    colorTheme = map[Keys.sk$ColorThemeName];
    calendarType = CalendarType.byName(map['calendar_type_name']);
    httpAddress = map['http_address'];
    wsAddress = map['ws_address'];
    proxyAddress = map['proxy_address'];
    chatNotification = map[Keys.sk$chatNotificationEnable]?? true;
    appNotification = map[Keys.sk$appNotificationEnable]?? true;
    autoDownloadImages = map[Keys.sk$autoDownloadImages]?? true;
    autoDownloadVideos = map[Keys.sk$autoDownloadVideos]?? false;
    confirmOnExit = map[Keys.sk$confirmOnExit]?? true;
    appPatternKey = map[Keys.sk$patternKey];
    appVersion = map[Keys.appVersion];
    lastForegroundTs = map[Keys.sk$lastForegroundTs];
  }

  Map toMap(){
    final map = {};

    map['last_user_id'] = lastUserId;
    map['date_format'] = dateFormat;
    map[Keys.languageIso] = languageIso;
    map[Keys.countryIso] = countryIso;
    map[Keys.sk$ColorThemeName] = colorTheme;
    map['calendar_type_name'] = calendarType.name;
    map['http_address'] = httpAddress;
    map['ws_address'] = wsAddress;
    map['proxy_address'] = proxyAddress;
    map[Keys.sk$chatNotificationEnable] = chatNotification;
    map[Keys.sk$appNotificationEnable] = appNotification;
    map[Keys.sk$autoDownloadImages] = autoDownloadImages;
    map[Keys.sk$autoDownloadVideos] = autoDownloadVideos;
    map[Keys.sk$confirmOnExit] = confirmOnExit;
    map[Keys.sk$patternKey] = appPatternKey;
    map[Keys.appVersion] = appVersion;
    map[Keys.sk$lastForegroundTs] = lastForegroundTs;

    return map;
  }

  void matchBy(SettingsModel other){
    lastUserId = other.lastUserId;
    dateFormat = other.dateFormat;
    languageIso = other.languageIso;
    countryIso = other.countryIso;
    colorTheme = other.colorTheme;
    calendarType = other.calendarType;
    httpAddress = other.httpAddress;
    wsAddress = other.wsAddress;
    proxyAddress = other.proxyAddress;
    chatNotification = other.chatNotification;
    appNotification = other.appNotification;
    autoDownloadImages = other.autoDownloadImages;
    autoDownloadVideos = other.autoDownloadVideos;
    confirmOnExit = other.confirmOnExit;
    appPatternKey = other.appPatternKey;
    appVersion = other.appVersion;
    lastForegroundTs = other.lastForegroundTs;

    if(other.currentRouteScreen != null) {
      currentRouteScreen = other.currentRouteScreen;
    }
  }

  @override
  String toString(){
    return toMap().toString();
  }
}
