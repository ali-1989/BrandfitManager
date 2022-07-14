import 'package:iris_db/iris_db.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import '/system/keys.dart';
import '/tools/centers/dbCenter.dart';

class NotifierModelDb {
  int id = 0;
  int userId = 0;
  String title = '-';
  String batch = 'none';
  Map? descriptionJs;
  bool isSeen = false;
  bool isDelete = false;
  DateTime? registerDate;
  //------------------ local
  bool mustSync = false;


  NotifierModelDb();

  NotifierModelDb.fromMap(Map js, {String? domain}){
    id = js[Keys.id];
    userId = js[Keys.userId];
    title = js[Keys.title];
    descriptionJs = js['description_js'];
    batch = js['batch']?? NotifiersBatch.none.name;
    isSeen = js['is_seen']?? false;
    isDelete = js['is_delete']?? false;
    registerDate = DateHelper.tsToSystemDate(js['register_date']);
    //------------------ local
    mustSync = js[Keys.mustSync]?? false;
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};

    map[Keys.id] = id;
    map[Keys.userId] = userId;
    map[Keys.title] = title;
    map['description_js'] = descriptionJs;
    map['batch'] = batch;
    map['is_seen'] = isSeen;
    map['is_delete'] = isDelete;
    map['register_date'] = DateHelper.toTimestampNullable(registerDate);
    //------------------ local
    map[Keys.mustSync] = mustSync;

    return map;
  }

  void matchBy(NotifierModelDb other){
    id = other.id;
    userId = other.userId;
    title = other.title;
    descriptionJs = other.descriptionJs;
    isSeen = other.isSeen;
    isDelete = other.isDelete;
    registerDate = other.registerDate;
    batch = other.batch;
    //-------------------- local
    mustSync = other.mustSync;
  }

  static Future upsertRecords(List<Map> maps) async {
    throw Exception('must use [UserNotifierManager].sinkItems() or upsertRecordsEx()');
    /*Conditions con = Conditions();

    for(var map in maps){
      con.clearConditions();
      con.add(Condition()..key = Keys.id..value = map[Keys.id]);

      return DbCenter.db.insertOrUpdate(DbCenter.tbNotifiers, map, con);
    }*/
  }

  static Future upsertRecordsEx(List<Map> maps, Function(dynamic old, dynamic current) beforeUpdateFn) async {
    Conditions con = Conditions();

    for(var map in maps){
      con.clearConditions();
      con.add(Condition()..key = Keys.id..value = map[Keys.id]);

      return DbCenter.db.insertOrUpdateEx(DbCenter.tbNotifiers, map, con, beforeUpdateFn);
    }
  }

  static Future deleteRecords(List<int> ids) async {
    Conditions con = Conditions();
    con.add(Condition(ConditionType.IN)..key = Keys.id..value = ids);

    return DbCenter.db.delete(DbCenter.tbNotifiers, con);
  }

  static Future retainRecords(List<int> ids) async {
    Conditions con = Conditions();
    con.add(Condition(ConditionType.NotIn)..key = Keys.id..value = ids);

    return DbCenter.db.delete(DbCenter.tbNotifiers, con);
  }

  static Future<List<Map<String, dynamic>>> fetchIds(List<int> ids) async {
    final con = Conditions()
      ..add(Condition(ConditionType.IN)..key = Keys.id..value = ids);

    final cursor = DbCenter.db.query(DbCenter.tbNotifiers, con);

    if(cursor.isEmpty){
      return <Map<String, dynamic>>[];
    }

    return cursor.map((e) => e as Map<String, dynamic>).toList();
  }

  static Future<List<Map<String, dynamic>>> fetchIf(bool Function(dynamic) fn) async {
    final con = Conditions()
      ..add(Condition(ConditionType.TestFn)..testFn = fn);

    final cursor = DbCenter.db.query(DbCenter.tbNotifiers, con);

    if(cursor.isEmpty){
      return <Map<String, dynamic>>[];
    }

    return cursor.map((e) => e as Map<String, dynamic>).toList();
  }

  Future sink() async {
    NotifierModelDb.upsertRecords([toMap()]);
  }
  ///------------------------------------------------------------------------------------
  static List fetchRecords(int userId, {String? batch}) {
    Conditions con = Conditions();
    con.add(Condition()..key = Keys.userId..value = userId);

    if(batch != null){
      con.add(Condition()..key = 'batch'..value = batch);
    }

    con.addOr([
      Condition(ConditionType.NotDefinedKey)..key = 'is_delete',
      Condition(ConditionType.IsFalse)..key = 'is_delete',
    ]);

    return DbCenter.db.query(DbCenter.tbNotifiers, con);
  }

  static List fetchUnSeenRecords(int userId, {String? batch}) {
    Conditions con = Conditions();
    con.add(Condition()..key = 'user_id'..value = userId);
    con.add(Condition()..key = 'is_seen'..value = false);

    if(batch != null){
      con.add(Condition()..key = 'batch'..value = batch);
    }

    con.addOr([
      Condition(ConditionType.NotDefinedKey)..key = 'is_delete',
      Condition(ConditionType.IsFalse)..key = 'is_delete',
    ]);

    return DbCenter.db.query(DbCenter.tbNotifiers, con);
  }

  static Future deleteMustSync(List<int> ids) {
    Conditions con = Conditions();
    con.add(Condition(ConditionType.IN)..key = Keys.id..value = ids);

    return DbCenter.db.deleteKey(DbCenter.tbNotifiers, con, Keys.mustSync);
  }
}
///======================================================================================
enum NotifiersBatch {
  none,
  courseRequest,
  courseAnswer,
  programs,
}
