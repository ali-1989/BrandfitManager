import 'dart:io';

import 'package:flutter/widgets.dart';

import 'package:iris_tools/api/converter.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';
import 'package:iris_tools/api/helpers/imageHelper.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/modules/propertyNotifier/propertyChangeNotifier.dart';

import '/models/dataModels/countryModel.dart';
import '/models/dataModels/usersModels/bankCardModel.dart';
import '/models/dataModels/usersModels/fitnessDataModel.dart';
import '/models/dataModels/usersModels/healthConditionModel.dart';
import '/models/dataModels/usersModels/jobActivityModel.dart';
import '/models/dataModels/usersModels/sportEquipmentModel.dart';
import '/system/enums.dart';
import '/system/keys.dart';
import '/system/session.dart';
import '/tools/centers/directoriesCenter.dart';
import '/tools/countryTools.dart';
import '/tools/mediaTools.dart';
import '/tools/uriTools.dart';

enum UserModelNotifierMode {
  profilePath,
}
///=========================================================================================
// ignore: mixin_inherits_from_not_object
class UserModel with PropertyChangeNotifier<UserModelNotifierMode> { 			// 17 field
  late int userId;
  String? token;
  late String userName;
  String? name;
  String? family;
  int sex = 0; 					//0:unKnow,  1:male,  2:faMale
  String? mobileNumber;
  CountryModel countryModel = CountryModel();
  CurrencyModel currencyModel = CurrencyModel();
  DateTime? birthDate;
  String? profileUri;
  BankCardModel? bankCardModel;
  late JobActivityModel jobActivityModel;
  late HealthConditionModel healthConditionModel;
  late SportEquipmentModel sportEquipmentModel;
  late FitnessDataModel fitnessDataModel;
  //------------------------- local
  DateTime? loginDate;
  String? _profilePath;
  FileImage? profileProvider;

  String? get profilePath => _profilePath;

  UserModel();

  UserModel.fromMap(Map<String, dynamic> map, {String? domain}){
    final brDate = map[Keys.birthdate];
    final tLoginDate = map[Keys.lastLoginDate];
    final sexVal = map[Keys.sex];

    userId = Converter.dynamicToIntNull(map[Keys.userId])!;
    token = map[Keys.token];
    userName = map[Keys.userName]?? '';
    name = map[Keys.name];
    family = map[Keys.family];
    mobileNumber = map[Keys.mobileNumber]?.toString();
    profileUri = map[Keys.profileImageUri];
    countryModel = CountryModel.fromMap(map['user_country_js']);
    currencyModel = CurrencyModel.fromMap(map['user_currency_js']);

    if(sexVal is int) {
      sex = sexVal;
    } else if(sexVal is String) {
      sex = int.parse(sexVal);
    }
    else {
      sex = 0;
    }

    if(brDate is int) {
      birthDate = DateHelper.milToDateTime(brDate);
    }
    else if(brDate is String) {
      birthDate = DateHelper.tsToSystemDate(brDate);
    }

    final bankCardModelJs = JsonHelper.reFormat<String, dynamic>(map['bank_card_js']);
    final sportsEquipmentJs = JsonHelper.reFormat<String, dynamic>(map['sports_equipment_js']);
    final healthConditionJs = JsonHelper.reFormat<String, dynamic>(map['health_condition_js']);
    final jobActivityJs = JsonHelper.reFormat<String, dynamic>(map['job_activity_js']);
    final fitnessStatusJs = JsonHelper.reFormat<String, dynamic>(map['fitness_status_js']);

    if(bankCardModelJs != null) {
      bankCardModel = BankCardModel.fromMap(bankCardModelJs);
    }

    jobActivityModel = JobActivityModel.fromMap(jobActivityJs);
    healthConditionModel = HealthConditionModel.fromMap(healthConditionJs);
    sportEquipmentModel = SportEquipmentModel.fromMap(sportsEquipmentJs);
    fitnessDataModel = FitnessDataModel.fromMap(fitnessStatusJs);

    profileUri = UriTools.correctAppUrl(profileUri, domain: domain);
    //----------------------- local
    _profilePath = map[Keys.profileImagePath];

    if (tLoginDate is int) {
      loginDate = DateHelper.milToDateTime(tLoginDate);
    }
    else if (tLoginDate is String) {
      loginDate = DateHelper.tsToSystemDate(tLoginDate);
    }
  }

  Map<String, dynamic> toMap(){
    final res = <String, dynamic>{};

    res[Keys.userId] = userId;
    res[Keys.token] = token;
    res[Keys.userName] = userName;
    res[Keys.name] = name;
    res[Keys.family] = family;
    res[Keys.sex] = sex;
    res[Keys.birthdate] = birthDate == null? null: DateHelper.toTimestamp(birthDate!);
    res['sports_equipment_js'] = sportEquipmentModel.toMap();
    res['health_condition_js'] = healthConditionModel.toMap();
    res['job_activity_js'] = jobActivityModel.toMap();
    res['fitness_status_js'] = fitnessDataModel.toMap();
    res['bank_card_js'] = bankCardModel?.toMap();

    if(mobileNumber != null) {
      res[Keys.mobileNumber] = mobileNumber;
    }

    if(countryModel.countryIso != null) {
      res['user_country_js'] = countryModel.toMap();
    }

    if(currencyModel.countryIso != null) {
      res['user_currency_js'] = currencyModel.toMap();
    }

    if(profileUri != null) {
      res[Keys.profileImageUri] = profileUri;
    }
    //-------------------------- local
    res[Keys.lastLoginDate] = loginDate == null? null:DateHelper.toTimestamp(loginDate!);
    res[Keys.profileImagePath] = _profilePath;

    return res;
  }

  void matchBy(UserModel other){
    userId = other.userId;
    token = other.token;
    userName = other.userName;
    name = other.name;
    family = other.family;
    sex = other.sex;
    mobileNumber = other.mobileNumber;
    birthDate = other.birthDate;
    profileUri = other.profileUri;
    bankCardModel = other.bankCardModel;
    healthConditionModel = other.healthConditionModel;
    jobActivityModel = other.jobActivityModel;
    sportEquipmentModel = other.sportEquipmentModel;
    fitnessDataModel = other.fitnessDataModel;

    countryModel = other.countryModel;

    if(other.currencyModel.countryIso != null) {
      currencyModel = other.currencyModel;
    }
    //--------------------------------- local
    //_profilePath = read._profilePath;
    loginDate = other.loginDate;
    profileProvider = other.profileProvider;
  }

  set profilePath(String? path) {
    if(_profilePath != null){
      ImageHelper.evictImageFile(FileHelper.getFile(_profilePath!));
    }

    _profilePath = path;

    final f = FileHelper.getFile(_profilePath);
    var fu = _isFileAImage(f);
    FileImage? temp;

    fu.then((isImage){
      if(isImage) {
        final avatar = FileImage(f);
        temp = avatar;
      }
      else {
        temp = null;
      }

      profileProvider = temp;
      Session.sinkUserInfo(this);

      notifyListeners(UserModelNotifierMode.profilePath);
    });
  }

  String get nameFamily {
    return '$name $family';
  }

  String? genProfilePath(){
    if(profileUri == null){
      return null;
    }

    return DirectoriesCenter.getSavePathUri(profileUri, SavePathType.USER_PROFILE);
  }

  bool get existProfileImageFile {
    if(profilePath == null) {
      return false;
    }

    return FileHelper.getFile(profilePath!).existsSync();
  }

  bool get isSetProfileImage {
    return profileUri != null;
  }

  int get age {
    if(birthDate == null) {
      return 0;
    }

    return DateHelper.calculateAge(birthDate!);
  }

  String get countryName {
    return CountryTools.countryShowNameByCountryIso(countryModel.countryIso?? 'US');
  }

  Future<bool> _isFileAImage(File? file) async {
    if(file == null){
      return false;
    }

    if (await file.exists()) {
      return MediaTools.isImage(file.path);
    }

    return false;
  }

  @override
  String toString(){
    return '$userId _ userName: $userName _ name: $name _ family: $family _ mobile: $mobileNumber _ sex: $sex ';
  }
}
