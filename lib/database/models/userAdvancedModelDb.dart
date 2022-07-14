import 'dart:io';

import 'package:flutter/material.dart';

import 'package:iris_db/iris_db.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as time_ago;

import '/managers/settingsManager.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/system/keys.dart';
import '/tools/centers/dbCenter.dart';
import '/tools/serverTimeTools.dart';

class UserAdvancedModelDb extends UserModel {
  static final List<String> notNullKeys = [Keys.userName, Keys.name, Keys.family];
  int userType = 1;
  String? lastTouchTs;
  String? registerDateTs;
  String? answerDateTs;
  late bool isLogin;
  //----------------------- local
  DateTime? lastTouchDate;

  UserAdvancedModelDb();

  UserAdvancedModelDb.fromMap(Map<String, dynamic> map, {String? domain}): super.fromMap(map, domain: domain) {
    userType = map[Keys.userType]?? 0;
    lastTouchTs = map['last_touch'];
    registerDateTs = map['register_date'];
    answerDateTs = map['answer_date'];
    isLogin = map['is_login']?? false;

    //------------------------ local
    lastTouchDate = DateHelper.tsToSystemDate(lastTouchTs);
  }

  @override
  void matchBy(UserModel other, {String? domain}){
    // no need super.matchBy(other);
    userId = other.userId;
    token = other.token;
    userName = other.userName.isEmpty? userName: other.userName;
    name = other.name?? name;
    family = other.family?? family;
    sex = other.sex;
    mobileNumber = other.mobileNumber;
    birthDate = other.birthDate;
    profileUri = other.profileUri;
    healthConditionModel = other.healthConditionModel;
    jobActivityModel = other.jobActivityModel;
    sportEquipmentModel = other.sportEquipmentModel;
    fitnessDataModel = other.fitnessDataModel;

    countryModel = other.countryModel;

    if(other.currencyModel.countryIso != null) {
      currencyModel = other.currencyModel;
    }

    if(other is UserAdvancedModelDb){
      userType = other.userType;
      isLogin = other.isLogin;
      lastTouchTs = other.lastTouchTs;
      registerDateTs = other.registerDateTs;
      answerDateTs = other.answerDateTs;

      lastTouchDate = other.lastTouchDate;
    }
    //----------------------------------------------
    loginDate = other.loginDate;
    profileProvider = other.profileProvider;
  }

  @override
  Map<String, dynamic> toMap(){
    final map = super.toMap();

    map[Keys.userType] = userType;
    map['last_touch'] = lastTouchTs;
    map['register_date'] = registerDateTs;
    map['answer_date'] = answerDateTs;
    map['is_login'] = isLogin;

    return JsonHelper.removeNullsByKey<String, dynamic>(map, notNullKeys)!;
  }

  static Future upsertRecords(List<Map> maps) async {
    Conditions con = Conditions();

    for(var map in maps){
      con.clearConditions();
      con.add(Condition()..key = Keys.userId..value = map[Keys.userId]);

      await DbCenter.db.insertOrUpdate(DbCenter.tbUserAdvanced, map, con);
    }

    return true;
  }

  static Future upsertRecordsEx(List<Map> maps, Function(dynamic old, dynamic current) beforeUpdateFn) async {
    Conditions con = Conditions();

    for(var map in maps){
      con.clearConditions();
      con.add(Condition()..key = Keys.userId..value = map[Keys.userId]);

      return DbCenter.db.insertOrUpdateEx(DbCenter.tbUserAdvanced, map, con, beforeUpdateFn);
    }
  }

  static Future deleteRecords(List<int> ids) async {
    Conditions con = Conditions();
    con.add(Condition(ConditionType.IN)..key = Keys.userId..value = ids);

    return DbCenter.db.delete(DbCenter.tbUserAdvanced, con);
  }

  static Future retainRecords(List<int> ids) async {
    Conditions con = Conditions();
    con.add(Condition(ConditionType.NotIn)..key = Keys.userId..value = ids);

    return DbCenter.db.delete(DbCenter.tbUserAdvanced, con);
  }

  static Future<List<Map<String, dynamic>>> fetchIds(List<int> ids) async {
    final con = Conditions()
      ..add(Condition(ConditionType.IN)..key = Keys.userId..value = ids);

    final cursor = DbCenter.db.query(DbCenter.tbUserAdvanced, con);

    if(cursor.isEmpty){
      return <Map<String, dynamic>>[];
    }

    return cursor.map((e) => e as Map<String, dynamic>).toList();
  }

  static Future<List<Map<String, dynamic>>> fetchIf(bool Function(dynamic) fn) async {
    final con = Conditions()
      ..add(Condition(ConditionType.TestFn)..testFn = fn);

    final cursor = DbCenter.db.query(DbCenter.tbUserAdvanced, con);

    if(cursor.isEmpty){
      return <Map<String, dynamic>>[];
    }

    return cursor.map((e) => e as Map<String, dynamic>).toList();
  }

  Future sink() async {
    UserAdvancedModelDb.upsertRecords([toMap()]);
  }
  ///------------------------------------------------------------------------------------
  static List fetchRecords() {
    final con = Conditions();

    return DbCenter.db.query(DbCenter.tbUserAdvanced, con);
  }

  String get touchTime {
    if(lastTouchDate == null){
      return '';
    }

    return time_ago.format(lastTouchDate!,
      clock: ServerTimeTools.utcTimeMatchServer,
      locale: SettingsManager.settingsModel.appLocale.languageCode,
    );
  }

  bool isOnline(){
    if(!isLogin || lastTouchDate == null){
      return false;
    }

    final dif = DateTime.now().difference(ServerTimeTools.localTimeMatchServer);
    return dif < Duration(minutes: 10);
  }

  ImageProvider? getProfileProvider(){
    if(profilePath == null){
      return null;
    }

    return FileImage(File(profilePath!));
  }

  @override
  String toString(){
    return '$userId, $userName, $profileUri,';
  }
}
