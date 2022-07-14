import 'package:flutter/material.dart';

import 'package:iris_db/iris_db.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import '/managers/userAdvancedManager.dart';
import '/models/dataModels/countryModel.dart';
import '/system/enums.dart';
import '/system/extensions.dart';
import '/system/keys.dart';
import '/tools/app/appThemes.dart';
import '/tools/centers/dbCenter.dart';
import '/tools/centers/directoriesCenter.dart';
import '/tools/uriTools.dart';

class RequestHybridModelDb {
  int id = 0;
  int courseId = 0;
  int requesterUserId = 0;
  DateTime? requestDate;
  DateTime? payDate;
  DateTime? answerDate;
  DateTime? supportExpireDate;
  Map answerJs = {};
  //---------------- course
  late String title;
  late String price;
  int courseCreatorUserId = 0;
  late CurrencyModel currencyModel;
  bool hasFoodProgram = false;
  bool hasExerciseProgram = false;
  String? creationDate;
  int durationDay = 0;
  String? imageUri;

  RequestHybridModelDb();

  RequestHybridModelDb.fromMap(Map js, {String? domain}){
    id = js[Keys.id];
    courseId = js['course_id'];
    requesterUserId = js['requester_user_id'];
    requestDate = DateHelper.tsToSystemDate(js['request_date']);
    payDate = DateHelper.tsToSystemDate(js['pay_date']);
    answerDate = DateHelper.tsToSystemDate(js['answer_date']);
    supportExpireDate = DateHelper.tsToSystemDate(js['support_expire_date']);
    answerJs = js['answer_js']?? {};
    //-------------------------- course
    title = js[Keys.title];
    price = js['price'];
    currencyModel = CurrencyModel.fromMap(js['currency_js']);
    creationDate = js['creation_date'];
    durationDay = js['duration_day']?? 0;
    imageUri = js[Keys.imageUri];
    courseCreatorUserId = js['creator_user_id']?? 0;
    hasFoodProgram = js['has_food_program']?? false;
    hasExerciseProgram = js['has_exercise_program']?? false;
    //-----------------------------------
    UriTools.correctAppUrl(imageUri, domain: domain);
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};

    map[Keys.id] = id;
    map['course_id'] = courseId;
    map['requester_user_id'] = requesterUserId;
    map['request_date'] = DateHelper.toTimestampNullable(requestDate);
    map['pay_date'] = DateHelper.toTimestampNullable(payDate);
    map['answer_date'] = DateHelper.toTimestampNullable(answerDate);
    map['support_expire_date'] = DateHelper.toTimestampNullable(supportExpireDate);
    map['answer_js'] = answerJs;
    //--------------- course
    map[Keys.title] = title;
    map['price'] = price;
    map['creator_user_id'] = courseCreatorUserId;
    map['currency_js'] = currencyModel.toMap();
    map['has_food_program'] = hasFoodProgram;
    map['has_exercise_program'] = hasExerciseProgram;
    map['creation_date'] = creationDate;
    map['duration_day'] = durationDay;
    map[Keys.imageUri] = imageUri;

    return map;
  }

  void matchBy(RequestHybridModelDb other){
    courseId = other.courseId;
    title = other.title;
    price = other.price;
    currencyModel = other.currencyModel;
    hasFoodProgram = other.hasFoodProgram;
    hasExerciseProgram = other.hasExerciseProgram;
    creationDate = other.creationDate;
    requestDate = other.requestDate;
    payDate = other.payDate;
    answerDate = other.answerDate;
    requesterUserId = other.requesterUserId;
    courseCreatorUserId = other.courseCreatorUserId;
    imageUri = other.imageUri;
    answerJs = other.answerJs;
    durationDay = other.durationDay;
    supportExpireDate = other.supportExpireDate;
  }

  static Future upsertRecords(List<Map> maps) async {
    Conditions con = Conditions();

    for(var map in maps){
      con.clearConditions();
      con.add(Condition()..key = Keys.id..value = map[Keys.id]);

      return DbCenter.db.insertOrUpdate(DbCenter.tbCourseRequest, map, con);
    }
  }

  static Future upsertRecordsEx(List<Map> maps, Function(dynamic old, dynamic current) beforeUpdateFn) async {
    Conditions con = Conditions();

    for(var map in maps){
      con.clearConditions();
      con.add(Condition()..key = Keys.id..value = map[Keys.id]);

      return DbCenter.db.insertOrUpdateEx(DbCenter.tbCourseRequest, map, con, beforeUpdateFn);
    }
  }

  static Future deleteRecords(List<int> ids) async {
    Conditions con = Conditions();
    con.add(Condition(ConditionType.IN)..key = Keys.id..value = ids);

    return DbCenter.db.delete(DbCenter.tbCourseRequest, con);
  }

  static Future retainRecords(List<int> ids) async {
    Conditions con = Conditions();
    con.add(Condition(ConditionType.NotIn)..key = Keys.id..value = ids);

    return DbCenter.db.delete(DbCenter.tbCourseRequest, con);
  }

  static Future<List<Map<String, dynamic>>> fetchIds(List<int> ids) async {
    final con = Conditions()
      ..add(Condition(ConditionType.IN)..key = Keys.id..value = ids);

    final cursor = DbCenter.db.query(DbCenter.tbCourseRequest, con);

    if(cursor.isEmpty){
      return <Map<String, dynamic>>[];
    }

    return cursor.map((e) => e as Map<String, dynamic>).toList();
  }

  static Future<List<Map<String, dynamic>>> fetchIf(bool Function(dynamic) fn) async {
    final con = Conditions()
      ..add(Condition(ConditionType.TestFn)..testFn = fn);

    final cursor = DbCenter.db.query(DbCenter.tbCourseRequest, con);

    if(cursor.isEmpty){
      return <Map<String, dynamic>>[];
    }

    return cursor.map((e) => e as Map<String, dynamic>).toList();
  }

  Future sink() async {
    RequestHybridModelDb.upsertRecords([toMap()]);
  }
  ///------------------------------------------------------------------------------------
  static List fetchRecordsByRequester(int requesterId) {
    Conditions con = Conditions();
    con.add(Condition()..key = 'requester_user_id'..value = requesterId);

    return DbCenter.db.query(DbCenter.tbCourseRequest, con);
  }

  static List fetchRecordsByCreator(int creatorId) {
    Conditions con = Conditions();
    con.add(Condition()..key = 'creator_user_id'..value = creatorId);

    return DbCenter.db.query(DbCenter.tbCourseRequest, con);
  }

  /*void checkStatus(){
    isAccept = answerJs.containsKey('accept');
    isReject = answerJs.containsKey('reject');

    if(isAccept){
      deadlineDay = answerJs['days'];
    }
  }*/

  String? get imagePath => DirectoriesCenter.getSavePathUri(imageUri?? 'c$courseId.jpg', SavePathType.COURSE_PHOTO);

  bool get hasImage => imageUri != null;

  bool get isAccept => answerJs.containsKey('accept');

  bool get isReject => answerJs.containsKey('reject');

  bool get canResponse => answerDate == null || !(isAccept || isReject);

  bool get canShowSendProgram => answerDate != null && isAccept;

  bool get hasTimeSendProgram => canShowSendProgram && _isInSupportTime();

  int get deadlineDay => answerJs['days']?? 0;

  bool _isInSupportTime(){
    if(supportExpireDate == null){
      return true;
    }

    //final newDate = supportExpireDate!.add(Duration(days: MathHelper.percentInt(durationDay, supportPercent)));

    return supportExpireDate!.compareTo(DateTime.now().toUtc()) > 0;
  }

  DateTime? get sendDeadline {
   if(deadlineDay < 1 || answerDate == null){
     return null;
   }

   return answerDate!.add(Duration(days: deadlineDay));
  }

  String requesterName() => UserAdvancedManager.getById(requesterUserId)?.userName?? '-';

  String trainerName() => UserAdvancedManager.getById(courseCreatorUserId)?.userName?? '-';

  String getStatusText(BuildContext ctx){
    if(isAccept){
      return ctx.t('accepted')!;
    }

    if(isReject){
      return ctx.t('rejected')!;
    }

    return ctx.t('pending')!;
  }

  Color getStatusColor(){
    if(isAccept){
      return AppThemes.currentTheme.successColor;
    }

    if(isReject){
      return AppThemes.currentTheme.errorColor;
    }

    return AppThemes.currentTheme.textColor;
  }

  int isNearToAnswering(){
    if(isAccept){
      final deadlineDate = answerDate!.add(Duration(days: deadlineDay));
      final now = DateHelper.getNowToUtc();
      final dif = deadlineDate.difference(now);

      if(dif.inDays < 2){
        return 2;
      }

      if(dif.inDays < deadlineDay~/2){
        return 1;
      }

      return 0;
    }

    return 0;
  }
}
