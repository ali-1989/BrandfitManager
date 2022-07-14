import 'dart:io';

import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as time_ago;

import '/managers/settingsManager.dart';
import '/system/keys.dart';
import '/tools/serverTimeTools.dart';
import '/tools/uriTools.dart';

class AppUserModel {
  int? type;
  int? userId;
  String? userName;
  String? name;
  String? family;
  int? sexInt;
  String? profileImageUri;
  String? profileImagePath;
  File? profileFile;
  String? birthDateStr;
  DateTime? birthDate;
  String? joinDateStr;
  DateTime? joinDate;
  DateTime? lastTouch;
  DateTime? blockDate;
  String? blockerUserName;
  String? mobileNumber;
  String? countryCode;
  int? blockedId;
  Map? blockJs;
  bool? isLogin;
  bool isBlocked = false;
  bool isDeleted = false;
  bool isExerciseTrainer = false;
  bool isFoodTrainer = false;
  bool broadcastCourse = false;
  String? cardNumber;
  int? rank;

  bool get isTrainer => type != null && type == 2;
  bool get isManager => type != null && type == 3;

  int get age {
    return DateHelper.calculateAge(birthDate);
  }

  bool get isOnline {
    var l = isLogin?? false;
    l = l && lastTouch != null;

    if(!l){
      return false;
    }

    return DateHelper.difference(lastTouch!, ServerTimeTools.utcTimeMatchServer).compareTo(Duration(minutes: 15)) < 0;
  }

  AppUserModel.fromMap(Map map, {String? domain}){
    userId = map[Keys.userId];
    userName = map[Keys.userName];
    type = map[Keys.userType];
    name = map[Keys.name];
    family = map[Keys.family];
    birthDateStr = map[Keys.birthdate];
    joinDateStr = map['register_date'];
    sexInt = map[Keys.sex];
    isDeleted = map['is_deleted'];
    isBlocked = map['blocker_user_id'] != null;
    blockedId = map['blocker_user_id'];
    blockerUserName = map['blocker_user_name'];
    blockJs = map['block_extra_js'];
    countryCode = map[Keys.phoneCode];
    mobileNumber = map[Keys.mobileNumber];
    isLogin = map['is_login']?? false;
    profileImageUri = map[Keys.profileImageUri];
    // for trainer
    isExerciseTrainer = map['is_exercise']?? false;
    isFoodTrainer = map['is_food']?? false;
    broadcastCourse = map['broadcast_course']?? false;
    cardNumber = map['card_number'];
    rank = map['rank']?? 0;

    profileImageUri = UriTools.correctAppUrl(profileImageUri);
    birthDate = DateHelper.tsToSystemDate(birthDateStr);
    joinDate = DateHelper.tsToSystemDate(joinDateStr);
    lastTouch = DateHelper.tsToSystemDate(map['last_touch']);
    blockDate = DateHelper.tsToSystemDate(map['block_date']);
  }

  String get touchTime {
    if(lastTouch == null){
      return '-';
    }

    return time_ago.format(lastTouch!,
        clock: ServerTimeTools.utcTimeMatchServer,
        locale: SettingsManager.settingsModel.appLocale.languageCode,
    );
  }
}
