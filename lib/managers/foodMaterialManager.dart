import 'package:flutter/foundation.dart';

import 'package:iris_db/iris_db.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';

import '/models/dataModels/foodModels/materialModel.dart';
import '/system/keys.dart';
import '/system/session.dart';
import '/tools/app/appManager.dart';
import '/tools/centers/dbCenter.dart';
import '/tools/centers/httpCenter.dart';

//*** use for clone [no user holder]

class FoodMaterialManager {
  FoodMaterialManager._();

  static final List<MaterialModel> _list = [];

  static List<MaterialModel> get materialList => _list;
  ///-----------------------------------------------------------------------------------------
  static MaterialModel? getById(int id){
    try {
      return _list.firstWhere((element) => element.id == id);
    }
    catch(e){
      return null;
    }
  }

  static MaterialModel addItem(MaterialModel item){
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

  static List<MaterialModel> addItemsFromMap(List? itemList, {String? domain}){
    final res = <MaterialModel>[];

    if(itemList != null){
      for(var row in itemList){
        final itm = MaterialModel.fromMap(row, domain: domain);
        addItem(itm);

        res.add(itm);
      }
    }

    return res;
  }

  static Future<void> loadByIds(List<int> ids) async {
    final con = Conditions()
      ..add(Condition(ConditionType.IN)..key = Keys.id..value = ids);

    final cursor = DbCenter.db.query(DbCenter.tbMaterials, con);

    if(cursor.isEmpty){
      return SynchronousFuture(null);
    }

    final fetchList = cursor.map((e) => e as Map<String, dynamic>).toList();

    for(var row in fetchList){
      final itm = MaterialModel.fromMap(row);

      addItem(itm);
    }

    return SynchronousFuture(null);
  }

  static Future sinkItems(List<MaterialModel> list) async {
    final con = Conditions();

    for(final row in list) {
      con.clearConditions();
      con.add(Condition()..key = Keys.id..value = row.id);

      await DbCenter.db.insertOrUpdate(DbCenter.tbMaterials, row.toMap(), con);
    }
  }

  static Future removeItem(int id, bool fromDb) async {
    _list.removeWhere((element) => element.id == id);

    if(fromDb){
      final con = Conditions();
      con.add(Condition()..key = Keys.id..value = id);
      DbCenter.db.delete(DbCenter.tbMaterials, con);
    }
  }

  static void sortList(bool asc) async {
    _list.sort((MaterialModel p1, MaterialModel p2){
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

  static Future removeNotMatchByServer(List<int> serverIds) async {
    _list.removeWhere((element) => !serverIds.contains(element.id));

    Conditions con = Conditions();
    con.add(Condition(ConditionType.NotIn)..key = Keys.id..value = serverIds);

    return DbCenter.db.delete(DbCenter.tbMaterials, con);
  }
  ///-----------------------------------------------------------------------------------------
  static Future<void> loadAllRecords(){
    final con = Conditions();
    final list = DbCenter.db.query(DbCenter.tbMaterials, con);

    addItemsFromMap(list);

    return SynchronousFuture(null);
  }

  static Future<MaterialModel?> requestMaterial(int id) async {
    final js = <String, dynamic>{};
    js[Keys.request] = 'GetMaterialModel';
    js[Keys.userId] = Session.getLastLoginUser()?.userId;
    js[Keys.id] = id;

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
          final Map? map = js[Keys.data];
          final domain = js[Keys.domain];

          if (map != null) {
            var model = MaterialModel.fromMap(map, domain: domain);
            model = addItem(model);
            await sinkItems([model]);

            return model;
          }
        }
      }

      return null;
    });

    return f.then((value) => value);
  }
}
