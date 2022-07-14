// ignore_for_file: empty_catches

import 'dart:core';

import 'package:flutter/foundation.dart';

import 'package:iris_db/iris_db.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import '/models/dataModels/programModels/foodProgramModel.dart';
import '/system/keys.dart';
import '/tools/centers/dbCenter.dart';

//*** use for clone [with user holder]

class FoodProgramManager {
  static final Map<int, FoodProgramManager> _holderLink = {};

  final List<FoodProgramModel> _list = [];
  late int userId;
  DateTime? lastUpdateTime;

  static FoodProgramManager managerFor(int userId) {
    if (_holderLink.keys.contains(userId)) {
      return _holderLink[userId]!;
    }

    return _holderLink[userId] = FoodProgramManager._(userId);
  }

  static void removeManager(int userId) {
    _holderLink.removeWhere((key, value) => key == userId);
  }

  bool isUpdated({Duration duration = const Duration(minutes: 10)}) {
    var now = DateTime.now();
    now = now.subtract(duration);

    return lastUpdateTime != null && lastUpdateTime!.isAfter(now);
  }

  void setUpdate() {
    lastUpdateTime = DateTime.now();
  }
  ///-----------------------------------------------------------------------------------------
  FoodProgramManager._(this.userId);

  List<FoodProgramModel> get allModelList => _list;

  FoodProgramModel? getById(int id) {
    try {
      return _list.firstWhere((element) => element.id == id);
    }
    catch (e) {
      return null;
    }
  }

  FoodProgramModel addItem(FoodProgramModel item) {
    final existItem = getById(item.id); //?? 0

    if (existItem == null) {
      _list.add(item);
      return item;
    }
    else {
      existItem.matchBy(item);
      return existItem;
    }
  }

  List<FoodProgramModel> addItemsFromMap(List? itemList, {String? domain}) {
    final res = <FoodProgramModel>[];

    if (itemList != null) {
      for (final row in itemList) {
        final itm = FoodProgramModel.fromMap(row);//, domain: domain
        addItem(itm);

        res.add(itm);
      }
    }

    return res;
  }

  Future<List<int>> loadByIds(List<int> ids) {
    final con = Conditions();
    con.add(Condition(ConditionType.IN)..key = Keys.id..value = ids);

    final cursorList = DbCenter.db.query(DbCenter.tbPrograms, con);

    final caseIds = <int>[];

    for (var itm in cursorList) {
      final r = FoodProgramModel.fromMap(itm);

      caseIds.add(r.id);
      addItem(r);
    }

    return SynchronousFuture(caseIds);
  }

  Future sinkItems(List<FoodProgramModel> list) async {
    for (final row in list) {
      final con = Conditions();
      con.add(Condition()..key = Keys.id..value = row.id);

      await DbCenter.db.insertOrUpdate(DbCenter.tbPrograms, row.toMap(withDays: true), con);
      //await DbCenter.db.insertOrUpdateEx(DbCenter.tbPrograms, row.toMap(), con, before);
    }
  }
  
  Future removeItem(int id, bool fromDb) async {
    _list.removeWhere((element) => element.id == id);

    if (fromDb) {
      final con = Conditions();
      con.add(Condition()..key = Keys.id..value = id);

      await DbCenter.db.delete(DbCenter.tbPrograms, con);
    }
  }

  Future removeNotMatchByServer(List<int> serverIds) async {
    _list.removeWhere((element) => !serverIds.contains(element.id));

    final con = Conditions();
    con.add(Condition(ConditionType.NotIn)..key = Keys.id..value = serverIds);

    return DbCenter.db.delete(DbCenter.tbPrograms, con);
  }

  void sortList(bool asc) async {
    _list.sort((FoodProgramModel p1, FoodProgramModel p2) {
      final d1 = p1.registerDate;
      final d2 = p2.registerDate;

      if (d1 == null) {
        return asc ? 1 : 1;
      }

      if (d2 == null) {
        return asc ? 1 : 1;
      }

      return asc ? d1.compareTo(d2) : d2.compareTo(d1);
    });
  }
  ///-----------------------------------------------------------------------------------------
  Future<List<int>> loadItems({int limit = 100, String? lastTs}) {
    final con = Conditions();
    con.add(Condition()..key = 'writer_id'..value = userId);

    if (lastTs != null) {
      con.add(Condition(ConditionType.IsBeforeTs)..key = 'register_date'..value = lastTs);
    }

    int orderBy(j1, j2) {
      final s1 = j1.value['register_date'];
      final s2 = j2.value['register_date'];

      final d1 = DateHelper.tsToSystemDate(s1);
      final d2 = DateHelper.tsToSystemDate(s2);

      if(d1 == null && d2 == null){
        return 0;
      }

      if(d1 == null){
        return -1;
      }

      if(d2 == null){
        return 1;
      }

      return d2.compareTo(d1);
    }

    final cursorList = DbCenter.db.query(DbCenter.tbPrograms, con, limit: limit, orderBy: orderBy);
    final caseIds = <int>[];

    for (var itm in cursorList) {
      final r = FoodProgramModel.fromMap(itm);

      caseIds.add(r.id);
      addItem(r);
    }

    return SynchronousFuture(caseIds);
  }

  List<FoodProgramModel> getForRequestId(int courseRequestId){
    final res = <FoodProgramModel>[];

    for(final k in _list){
      if(k.requestId == courseRequestId){
        res.add(k);
      }
    }

    return res;
  }

  FoodProgramModel generateModel({
    DateTime? date,
    }){
    final model = FoodProgramModel();
    model.registerDate = date?? DateHelper.getNowToUtc();

    addItem(model);
    sortList(false);
    sinkItems([model]);

    return model;
  }
}
