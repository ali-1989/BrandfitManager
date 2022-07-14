import 'package:flutter/foundation.dart';

import 'package:iris_tools/api/helpers/jsonHelper.dart';

import '/database/models/notifierModelDb.dart';
import '/system/keys.dart';
import '/tools/app/appManager.dart';
import '/tools/centers/httpCenter.dart';

class UserNotifierManager {
  static final Map<int, UserNotifierManager> _holderLink = {};

  final List<NotifierModelDb> _list = [];
  late int userId;
  DateTime? lastUpdateTime;

  static UserNotifierManager managerFor(int userId){
    if(_holderLink.keys.contains(userId)){
      return _holderLink[userId]!;
    }

    return _holderLink[userId] = UserNotifierManager._(userId);
  }

  static void removeManager(int userId){
    _holderLink.removeWhere((key, value) => key == userId);
  }

  bool isUpdated({Duration duration = const Duration(minutes: 10)}){
    var now = DateTime.now();
    now = now.subtract(duration);

    return lastUpdateTime != null && lastUpdateTime!.isAfter(now);
  }

  void setUpdate(){
    lastUpdateTime = DateTime.now();
  }
  ///-----------------------------------------------------------------------------------------
  UserNotifierManager._(this.userId);

  List<NotifierModelDb> get notifyList => _list;

  NotifierModelDb? getById(int id){
    try{
      return _list.firstWhere((element) => element.id == id);
    }
    catch(e){
      return null;
    }
  }

  NotifierModelDb addItem(NotifierModelDb item){
    final existItem = getById(item.id);

    if(existItem == null) {
      _list.add(item);
      return item;
    }
    else {
      existItem.matchBy(item);
      return existItem;
    }
  }

  List<NotifierModelDb> addItemsFromMap(List? itemList, {String? domain}){
    final res = <NotifierModelDb>[];

    if(itemList != null){
      for(var row in itemList){
        var itm = NotifierModelDb.fromMap(row, domain: domain);
        itm = addItem(itm);

        res.add(itm);
      }
    }

    return res;
  }

  Future<void> fetchByIds(List<int> ids) async {
    final fetchList = await NotifierModelDb.fetchIds(ids);

    for(var row in fetchList){
      final itm = NotifierModelDb.fromMap(row);

      addItem(itm);
    }

    return SynchronousFuture(null);
  }

  Future sinkItems(List<NotifierModelDb> list) async {
    final maps = <Map>[];

    for(var row in list) {
      maps.add(row.toMap());
    }

    NotifierModelDb.upsertRecordsEx(maps, beforeUpdate);

    /*final con = Conditions();

    for(var row in list) {
      con.clearConditions();
      con.add(Condition()..key = 'id'..value = row.id);

      await DbCenter.db.insertOrUpdate(DbCenter.tbNotifiers, row.toMap(), con);
    }*/
  }

  Future removeItem(int id, bool fromDb) async {
    _list.removeWhere((element) => element.id == id);

    if(fromDb){
      NotifierModelDb.deleteRecords([id]);
    }
  }

  void sortList(bool asc) async {
    _list.sort((NotifierModelDb p1, NotifierModelDb p2){
      final d1 = p1.registerDate;
      final d2 = p2.registerDate;

      if(d1 == null){
        return asc? 1: 1;
      }

      if(d2 == null){
        return asc? 1: 1;
      }

      return asc? d1.compareTo(d2) : d2.compareTo(d1);
    });
  }

  Future removeNotMatchByServer(List<int> serverIds) async {
    _list.removeWhere((element) => !serverIds.contains(element.id));

    await NotifierModelDb.retainRecords(serverIds);
  }
  ///-----------------------------------------------------------------------------------------
  beforeUpdate(old, newMap){
    if(old['is_seen']){
      newMap['is_seen'] = true;
    }
    else {
      if(newMap['is_seen'] = true){
        newMap[Keys.mustSync] = true;
      }
    }

    return newMap;
  }

  List<NotifierModelDb> notifyListFor(NotifiersBatch batch){
    return _list.where((element) => element.batch == batch.name).toList();
  }

  void fetchUserNotifiers(){
    final list = NotifierModelDb.fetchRecords(userId);
    addItemsFromMap(list);
  }

  Future<void> seenAndSaveAllNotifiers() async {
    for(var m in _list){
      if(!m.isSeen) {
        m.isSeen = true;
        await NotifierModelDb.upsertRecordsEx([m.toMap()], beforeUpdate);
      }
    }
  }

  Future<void> seenAndSaveNotifiers(NotifiersBatch batch) async {
    for(var m in _list){
      if(!m.isSeen && m.batch == batch.name) {
        m.isSeen = true;
        await NotifierModelDb.upsertRecordsEx([m.toMap()], beforeUpdate);
      }
    }
  }

  Future<bool> requestNotifiers() async {
    final js = <String, dynamic>{};
    js[Keys.request] = 'GetUserNotifiers';
    js[Keys.userId] = userId;

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
          final List? list = js[Keys.resultList];
          //final domain = data[Keys.domain];

          if (list != null) {
            final ids = <int>[];

            for (var m in list) {
              var notify = NotifierModelDb.fromMap(m);

              notify = addItem(notify);
              await sinkItems([notify]);

              ids.add(notify.id);
            }

            removeNotMatchByServer(ids);
            sortList(false);
          }

          return true;
        }
      }

      return false;
    });

    return f.then((value) => value?? false);
  }

  Future<bool> requestDeleteNotifier(NotifierModelDb model) async {
    final js = <String, dynamic>{};
    js[Keys.request] = 'DeleteUserNotifier';
    js[Keys.userId] = userId;
    js[Keys.id] = model.id;

    AppManager.addAppInfo(js);

    final http = HttpItem();
    http.setResponseIsPlain();
    http.pathSection = '/set-data';
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

      if (httpRequester.isOk && js != null){
        final result = js[Keys.result]?? Keys.error;

        if(result == Keys.ok) {
          removeItem(model.id, true);
          return true;
        }
      }

      return false;
    });

    return f.then((value) => value?? false);
  }

  Future<bool> requestSeenNotifier(NotifierModelDb model) async {
    final js = <String, dynamic>{};
    js[Keys.request] = 'SetSeenUserNotifier';
    js[Keys.userId] = userId;
    js[Keys.id] = model.id;

    AppManager.addAppInfo(js);

    final http = HttpItem();
    http.setResponseIsPlain();
    http.pathSection = '/set-data';
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

      if (httpRequester.isOk && js != null){
        final result = js[Keys.result]?? Keys.error;

        if(result == Keys.ok) {
          model.isSeen = true;
          sinkItems([model]);

          return true;
        }
      }

      return false;
    });

    return f.then((value) => value?? false);
  }

  Future<bool> requestSyncSeen() async {
    final idFetch = await NotifierModelDb.fetchIf((map) => map[Keys.mustSync] != null);
    final ids = <int>[];

    for(var m in idFetch){
      ids.add(m[Keys.id]);
    }

    if(ids.isEmpty){
      return true;
    }

    final js = <String, dynamic>{};
    js[Keys.request] = 'SetSeenUserNotifiers';
    js[Keys.userId] = userId;
    js['ids'] = ids;

    AppManager.addAppInfo(js);

    final http = HttpItem();
    http.setResponseIsPlain();
    http.pathSection = '/set-data';
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

      if (httpRequester.isOk && js != null){
        final result = js[Keys.result]?? Keys.error;

        if(result == Keys.ok) {
          NotifierModelDb.deleteMustSync(ids);

          return true;
        }
      }

      return false;
    });

    return f.then((value) => value?? false);
  }
}
