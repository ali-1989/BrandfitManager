import 'package:flutter/foundation.dart';

import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import '/database/models/requestHybridModelDb.dart';
import '/database/models/userAdvancedModelDb.dart';
import '/managers/userAdvancedManager.dart';
import '/system/extensions.dart';
import '/system/keys.dart';
import '/system/queryFiltering.dart';
import '/system/session.dart';
import '/tools/app/appManager.dart';
import '/tools/centers/dbCenter.dart';
import '/tools/centers/dialogCenter.dart';
import '/tools/centers/httpCenter.dart';
import '/tools/centers/routeCenter.dart';

class UserRequestManager {
  static final Map<int, UserRequestManager> _holderLink = {};

  late int userId;
  final List<RequestHybridModelDb> _list = [];
  DateTime? lastUpdateTime;

  static UserRequestManager managerFor(int userId){
    if(_holderLink.keys.contains(userId)){
      return _holderLink[userId]!;
    }

    return _holderLink[userId] = UserRequestManager._(userId);
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
  UserRequestManager._(this.userId);

  List<RequestHybridModelDb> get requestList => _list;

  RequestHybridModelDb? getById(int id){
    try{
      return _list.firstWhere((element) => element.id == id);
    }
    catch(e){
      return null;
    }
  }

  bool addItem(RequestHybridModelDb item){
    final existItem = getById(item.id);

    if(existItem == null) {
      _list.add(item);
      return true;
    }
    else {
      existItem.matchBy(item);
      return false;
    }
  }

  List<RequestHybridModelDb> addItemsFromMap(List? itemList, {String? domain}){
    final res = <RequestHybridModelDb>[];

    if(itemList != null){
      for(var row in itemList){
        final itm = RequestHybridModelDb.fromMap(row, domain: domain);
        addItem(itm);

        res.add(itm);
      }
    }

    return res;
  }

  Future<int> addByIds(List<int> ids) async {
    final fetchList = await RequestHybridModelDb.fetchIds(ids);
    var c = 0;

    for(var row in fetchList){
      final itm = RequestHybridModelDb.fromMap(row);

      if(addItem(itm)){
        c++;
      }
    }

    return SynchronousFuture(c);
  }

  Future sinkItems(List<RequestHybridModelDb> list) async {
    final maps = <Map>[];

    for(var row in list) {
      maps.add(row.toMap());
    }

    RequestHybridModelDb.upsertRecords(maps);
  }

  Future removeItem(int id, bool fromDb) async {
    _list.removeWhere((element) => element.id == id);

    if(fromDb){
      RequestHybridModelDb.deleteRecords([id]);
    }
  }

  void sortList(bool asc) async {
    _list.sort((RequestHybridModelDb p1, RequestHybridModelDb p2){
      final d1 = p1.requestDate;
      final d2 = p2.requestDate;

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

    await RequestHybridModelDb.retainRecords(serverIds);
  }
  ///-----------------------------------------------------------------------------------------
  void fetchTrainerRequest(FilterRequest? filtering){
    final list = RequestHybridModelDb.fetchRecordsByCreator(userId);

    bool checkFiltering(RequestHybridModelDb m){
      final pending = filtering!.getFilterViewFor(FilterKeys.pendingRequestOp)!.selectedValue != null;
      final accept = filtering.getFilterViewFor(FilterKeys.acceptedRequestOp)!.selectedValue != null;
      final reject = filtering.getFilterViewFor(FilterKeys.rejectedRequestOp)!.selectedValue != null;

      return (accept && m.isAccept) || (reject && m.isReject) || (pending && !m.isAccept && !m.isReject);
    }

    for(final m in list){
      final model = RequestHybridModelDb.fromMap(m);

      if(filtering == null){
        addItem(model);
      }
      else if(checkFiltering(model)) {
        addItem(model);
      }
    }

  }

  Future<bool> requestTrainerRequest(FilterRequest filtering) async {
    final js = <String, dynamic>{};
    js[Keys.request] = 'GetTrainerRequests';
    js[Keys.requesterId] = userId;
    js[Keys.forUserId] = userId;
    js[Keys.filtering] = filtering.toMap();

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
      final ok = js?[Keys.result];

      if (httpRequester.isOk && js != null && ok == Keys.ok) {
        final List? requestList = js[Keys.resultList];
        final List? advUsers = js['advance_users'];
        final domain = js[Keys.domain];

        if(advUsers != null) {
          for(final u in advUsers){
            final user = UserAdvancedModelDb.fromMap(u, domain: domain);
            user.sink();
            UserAdvancedManager.addItem(user);
          }
        }

        if(requestList != null) {
          for(final m in requestList){
            final cr = RequestHybridModelDb.fromMap(m, domain: domain);
            cr.sink();

            addItem(cr);
          }
        }

        return true;
      }

      return false;
    });

    return f.then((value) => value?? false);
  }

  Future<Map?> requestRequestExtraInfo(RequestHybridModelDb requestModel, bool withPrograms) async {
    final js = <String, dynamic>{};
    js[Keys.request] = 'GetRequestExtraInfoForTrainer';
    js[Keys.requesterId] = userId;
    js[Keys.forUserId] = userId;
    js['course_id'] = requestModel.courseId;
    js['request_id'] = requestModel.id;
    js['user_requester_id'] = requestModel.requesterUserId;
    js['with_programs'] = withPrograms;

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
      final ok = js?[Keys.result];

      if (httpRequester.isOk && ok == Keys.ok) {
        return js;
      }

      return null;
    });

    return f.then((value) => value);
  }

  Future<bool> requestCourseReject(RequestHybridModelDb model, String cause) async {
    final js = <String, dynamic>{};
    js[Keys.request] = 'SetRejectCourseBuy';
    js[Keys.userId] = userId;
    js['id'] = model.id;
    js['course_id'] = model.courseId;
    js['cause'] = cause;
    js['requester_user_id'] = model.requesterUserId;
    js['course_name'] = model.title;
    js['trainer_id'] = model.courseCreatorUserId;

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
      final result = js?[Keys.result];

      if (httpRequester.isOk && result == Keys.ok) {
        model.answerJs = {'reject': true, 'cause': cause};
        model.answerDate = DateHelper.getNowToUtc();
        model.sink();

        return true;
      }

      return false;
    });

    return f.then((value) => value?? false);
  }

  Future<bool> requestCourseAccept(RequestHybridModelDb model, int responseDay) async {
    final js = <String, dynamic>{};
    js[Keys.request] = 'SetAcceptCourseBuy';
    js[Keys.userId] = userId;
    js['id'] = model.id;
    js['course_id'] = model.courseId;
    js['days'] = responseDay;
    js['requester_user_id'] = model.requesterUserId;
    js['course_name'] = model.title;
    js['trainer_id'] = model.courseCreatorUserId;

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
      final result = js?[Keys.result];

      if (httpRequester.isOk && result == Keys.ok) {
        model.answerJs = {'accept': true, 'days': responseDay};
        model.answerDate = DateHelper.getNowToUtc();
        model.sink();

        return true;
      }

      return false;
    });

    return f.then((value) => value?? false);
  }

  static checkSendProgramsDeadline() async {
    final curUser = Session.getLastLoginUser();

    if(curUser == null){
      return;
    }

    final manager = UserRequestManager.managerFor(curUser.userId);
    final dListB4 = <RequestHybridModelDb>[];
    final dListL4 = <RequestHybridModelDb>[];

    if(manager.requestList.isEmpty){
      manager.fetchTrainerRequest(null);
    }

    for(var itm in manager.requestList){
      final deadline = itm.sendDeadline;

      if(deadline == null || DateHelper.isBeforeTodayUtc(deadline)){
        continue;
      }

      if(itm.deadlineDay < 4) {
        dListL4.add(itm);
      }
      else {
        dListB4.add(itm);
      }
    }

    int userCount = 0;
    var deadlineDb = DbCenter.fetchKv('deadline_send_programs');

    Map deadlineMap = deadlineDb?? {};
    final todayTs = DateHelper.getNowTimestampToUtc();

    for(var li in dListL4){
      if(!deadlineMap.containsKey('course_${li.id}')){

        if(DateHelper.getTodayDifferentDayUtc(li.sendDeadline!) < 2) {
          userCount++;
          deadlineMap['course_${li.id}'] = {'times': 1, 'date': todayTs};
        }
      }
    }

    for(var li in dListB4){
      var k = deadlineMap['course_${li.id}'];
      var times = k != null? k['times'] : 0;

      if(times == 0){
        var dif = DateHelper.getTodayDifferentDayUtc(li.sendDeadline!);

        if(dif > 0){
          times++;
        }

        if(-dif < li.deadlineDay/2){
          userCount++;
          deadlineMap['course_${li.id}'] = {'times': ++times, 'date': todayTs};
        }
      }
      else if(times == 1){
        //var date = k != null? k['date'] : null;
        final dif = DateHelper.getTodayDifferentDayUtc(li.sendDeadline!);

        if(-dif < 2){
          userCount++;
          deadlineMap['course_${li.id}'] = {'times': ++times, 'date': todayTs};
        }
      }
    }

    await DbCenter.setKv('deadline_send_programs', deadlineMap);

    if(userCount > 0) {
      String msg = RouteCenter.getContext().tInMap('mustSendProgramDialog', 'warning1')!;
      msg = msg.replaceFirst('#', '$userCount');

      DialogCenter().showInfoDialog(RouteCenter.getContext(), null, msg);
    }
  }
}
