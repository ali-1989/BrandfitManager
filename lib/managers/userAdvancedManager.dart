import 'package:flutter/foundation.dart';

import 'package:iris_tools/api/helpers/jsonHelper.dart';

import '/database/models/userAdvancedModelDb.dart';
import '/system/keys.dart';
import '/system/session.dart';
import '/tools/app/appManager.dart';
import '/tools/centers/httpCenter.dart';

class UserAdvancedManager {
  UserAdvancedManager._();

  static final List<UserAdvancedModelDb> _list = [];

  static List<UserAdvancedModelDb> get limitUsers => _list;
  ///-----------------------------------------------------------------------------------------
  static UserAdvancedModelDb? getById(int id){
    try {
      return _list.firstWhere((element) => element.userId == id);
    }
    catch(e){
      return null;
    }
  }

  static UserAdvancedModelDb addItem(UserAdvancedModelDb item){
    final existItem = getById(item.userId);

    if(existItem == null) {
      _list.add(item);
      return item;
    }
    else {
      existItem.matchBy(item);
      return existItem;
    }
  }

  static List<UserAdvancedModelDb> addItemsFromMap(List? itemList, {String? domain}){
    final res = <UserAdvancedModelDb>[];

    if(itemList != null){
      for(var row in itemList){
        final itm = UserAdvancedModelDb.fromMap(row, domain: domain);
        addItem(itm);

        res.add(itm);
      }
    }

    return res;
  }

  static Future<void> loadByIds(List<int> ids) async {
    final fetchList = await UserAdvancedModelDb.fetchIds(ids);

    for(var row in fetchList){
      final itm = UserAdvancedModelDb.fromMap(row);

      addItem(itm);
    }

    return SynchronousFuture(null);
  }

  static Future sinkItems(List<UserAdvancedModelDb> list) async {
    final maps = <Map>[];

    for(var row in list) {
      maps.add(row.toMap());
    }

    UserAdvancedModelDb.upsertRecords(maps);

    /*final con = Conditions();

    for(var row in list) {
      con.clearConditions();
      con.add(Condition()..key = 'id'..value = row.id);

      await DbCenter.db.insertOrUpdate(DbCenter.tbNotifiers, row.toMap(), con);
    }*/
  }

  static Future removeItem(int id, bool fromDb) async {
    _list.removeWhere((element) => element.userId == id);

    if(fromDb){
      UserAdvancedModelDb.deleteRecords([id]);
    }
  }

  static void sortList(bool asc) async {
    _list.sort((UserAdvancedModelDb p1, UserAdvancedModelDb p2){
      final d1 = p1.lastTouchDate;
      final d2 = p2.lastTouchDate;

      if(d1 == null){
        return asc? 1: 1;
      }

      if(d2 == null){
        return asc? 1: 1;
      }

      return asc? d1.compareTo(d2) : d2.compareTo(d1);
    });
  }

  static Future removeNotMatchByServer(List<int> serverIds) async {
    _list.removeWhere((element) => !serverIds.contains(element.userId));

    await UserAdvancedModelDb.retainRecords(serverIds);
  }
  ///-----------------------------------------------------------------------------------------
  static void loadAllRecords(){
    final list = UserAdvancedModelDb.fetchRecords();
    addItemsFromMap(list);
  }

  static Future<UserAdvancedModelDb?> requestUserLimit(int userId) async {
    final js = <String, dynamic>{};
    js[Keys.request] = 'GetUserLimit';
    js[Keys.userId] = Session.getLastLoginUser()?.userId;
    js[Keys.forUserId] = userId;

    AppManager.addAppInfo(js);

    final http = HttpItem();
    http.setResponseIsPlain();
    http.pathSection = '/get-data';
    http.method = 'POST';
    http.setBody(JsonHelper.mapToJson(js));

    final httpRequester = HttpCenter.send(http);

    var f = httpRequester.responseFuture.catchError((e){
      if (httpRequester.isDioCancelError){
        return httpRequester.emptyError;
      }
    });

    f = f.then((val) async {
      final Map? js = httpRequester.getBodyAsJson();

      if (httpRequester.isOk && js != null) {
        final result = js[Keys.result]?? Keys.error;

        if(result == Keys.ok) {
          final Map<String, dynamic>? map = JsonHelper.reFormat(js[Keys.data]);
          final domain = js[Keys.domain];

          if (map != null) {
            var user = UserAdvancedModelDb.fromMap(map, domain: domain);
            user = addItem(user);
            await sinkItems([user]);

            return user;
          }
        }
      }

      return null;
    });

    return f.then((value) => value);
  }
}
