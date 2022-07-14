// ignore_for_file: empty_catches

import 'dart:async';
import 'dart:core';

import 'package:flutter/foundation.dart';

import 'package:iris_db/iris_db.dart';
import 'package:iris_tools/api/converter.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/helpers/pathHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import '/managers/userAdvancedManager.dart';
import '/models/dataModels/ticketModels/ticketMediaModel.dart';
import '/models/dataModels/ticketModels/ticketMessageModel.dart';
import '/models/dataModels/ticketModels/ticketModel.dart';
import '/models/holderModels/ticketDownloadUploadHolder.dart';
import '/system/downloadUpload.dart';
import '/system/keys.dart';
import '/system/requester.dart';
import '/system/session.dart';
import '/tools/app/appManager.dart';
import '/tools/centers/broadcastCenter.dart';
import '/tools/centers/dbCenter.dart';
import '/tools/centers/httpCenter.dart';

class TicketManager {
  static final Map<int, TicketManager> _holderLink = {};

  final List<TicketModel> _list = [];
  static final List<TicketMessageModel> _allTicketMessageList = [];
  static final List<TicketMediaModel> _allMediaMessageList = [];
  static Timer? _failSendTimer;
  static int _failSendCounter = 0;
  late int userId;
  DateTime? lastUpdateTime;

  static TicketManager managerFor(int userId) {
    if (_holderLink.keys.contains(userId)) {
      return _holderLink[userId]!;
    }

    return _holderLink[userId] = TicketManager._(userId);
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
  TicketManager._(this.userId);

  List<TicketModel> get allTicketList => _list;
  static List<TicketMessageModel> get allTicketMessageList => _allTicketMessageList;
  static List<TicketMediaModel> get allMediaMessageList => _allMediaMessageList;

  TicketModel? getById(int id) {
    try {
      return _list.firstWhere((element) => element.id == id);
    }
    catch (e) {
      return null;
    }
  }

  bool addItem(TicketModel item) {
    final existItem = getById(item.id ?? 0);

    if (existItem == null) {
      _list.add(item);
      return true;
    }
    else {
      existItem.matchBy(item);
      existItem.invalidate();
      return false;
    }
  }

  List<TicketModel> addItemsFromMap(List? itemList, {String? domain}) {
    final res = <TicketModel>[];

    if (itemList != null) {
      for (var row in itemList) {
        final itm = TicketModel.fromMap(row, domain: domain);
        addItem(itm);

        res.add(itm);
      }
    }

    return res;
  }

  Future<int> addByIds(List<int> ids) async {
    return (await fetchTicketsByIds(ids)).length;
  }

  Future sinkItems(List<TicketModel> list) async {
    return sinkTickets(list);
  }

  Future removeItem(int id, bool fromDb) async {
    _list.removeWhere((element) => element.id == id);

    if (fromDb) {
      final con = Conditions();
      con.add(Condition()..key = Keys.id..value = id);

      await DbCenter.db.delete(DbCenter.tbTickets, con);
    }
  }

  void sortList(bool asc) async {
    _list.sort((TicketModel p1, TicketModel p2) {
      final d1 = p1.ticketSortTime;
      final d2 = p2.ticketSortTime;

      if (d1 == null) {
        return asc ? 1 : 1;
      }

      if (d2 == null) {
        return asc ? 1 : 1;
      }

      return asc ? d1.compareTo(d2) : d2.compareTo(d1);
    });
  }

  Future removeNotMatchByServer(List<int> serverIds) async {
    _list.removeWhere((element) => !element.isDraft && !serverIds.contains(element.id));

    final con = Conditions();
    con.add(Condition(ConditionType.NotIn)..key = Keys.userId..value = serverIds);

    //return DbCenter.db.delete(DbCenter.tbTickets, con);
  }
  ///-----------------------------------------------------------------------------------------
  static TicketMessageModel? getTicketMessageById(BigInt id) {
    try {
      return _allTicketMessageList.firstWhere((element) => element.id == id);
    }
    catch (e) {
      return null;
    }
  }

  static TicketMediaModel? getMediaMessageById(BigInt id) {
    try {
      return _allMediaMessageList.firstWhere((element) => element.id == id);
    }
    catch (e) {
      return null;
    }
  }

  static TicketMessageModel addTicketMessage(TicketMessageModel tm) {
    final existItem = getTicketMessageById(tm.id!);

    if (existItem == null) {
      _allTicketMessageList.add(tm);
      return tm;
    }
    else {
      existItem.matchBy(tm);
      return existItem;
    }
  }

  static TicketMediaModel addMediaMessage(TicketMediaModel mm) {
    final existItem = getMediaMessageById(mm.id!);

    if (existItem == null) {
      allMediaMessageList.add(mm);
      return mm;
    }
    else {
      existItem.matchBy(mm);
      return existItem;
    }
  }

  static List<TicketMessageModel> addTicketMessagesFromMap(List? itemList) {
    final res = <TicketMessageModel>[];

    if (itemList != null) {
      for (var row in itemList) {
        var tm = TicketMessageModel.fromMap(row);
        tm = addTicketMessage(tm);

        res.add(tm);
      }
    }

    return res;
  }

  static List<TicketMediaModel> addMediaMessagesFromMap(List? itemList) {
    final res = <TicketMediaModel>[];

    if (itemList != null) {
      for (var row in itemList) {
        var tm = TicketMediaModel.fromMap(row);
        tm = addMediaMessage(tm);

        res.add(tm);
      }
    }

    return res;
  }

  List<TicketModel> getUnSeenList() {
    return allTicketList.where((tm) => tm.unReadCount() > 0).toList();
  }

  static List<BigInt> takeMediaIdsByMessageIds(List<BigInt> ids) {
    final itr = _allTicketMessageList.where((element) => ids.contains(element.id));
    final mediaIds = <BigInt>[];

    for (var msg in itr) {
      if (msg.mediaId != null) {
        mediaIds.add(msg.mediaId!);
      }
    }

    return mediaIds;
  }

  static List<int> takeUserIdsByMessageIds(List<BigInt> ids) {
    final itr = _allTicketMessageList.where((element) => ids.contains(element.id));
    final userIds = <int>[];

    for (var msg in itr) {
      if (!userIds.contains(msg.senderUserId)) {
        userIds.add(msg.senderUserId!);
      }
    }

    return userIds;
  }

  void sortTicketsById(bool asc) {
    allTicketList.sort((e1, e2) {
      if (asc) {
        return e1.id!.compareTo(e2.id!);
      }

      return e2.id!.compareTo(e1.id!);
    });
  }

  Future<List<int>> fetchTicketsByIds(List<int> ids) {
    final con = Conditions()
      ..add(Condition(ConditionType.IN)..key = Keys.id..value = ids);

    final cursorList = DbCenter.db.query(DbCenter.tbTickets, con);

    final ticketIds = <int>[];

    for (var itm in cursorList) {
      final r = TicketModel.fromMap(itm);

      ticketIds.add(r.id!);
      addItem(r);
    }

    return SynchronousFuture(ticketIds);
  }

  Future<List<int>> fetchTickets({int limit = 200, String? lastTs}) {
    final con = Conditions();
    final conForSort1 = Conditions();
    final conForSort2 = Conditions();
    con.add(Condition(ConditionType.IsNotEmpty)
      ..key = 'start_date');

    if (lastTs != null) {
      con.add(Condition(ConditionType.IsBeforeTs)..key = 'start_date'..value = lastTs);
    }

    int orderByServerTs(j1, j2) {
      final s1 = j1.value['server_receive_ts'];
      final s2 = j2.value['server_receive_ts'];

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

    List getServerTs(j1, j2) {
      conForSort1.clearConditions();
      conForSort2.clearConditions();
      conForSort1.add(Condition()..key = 'ticket_id'..value = j1.value['id']);
      conForSort2.add(Condition()..key = 'ticket_id'..value = j2.value['id']);

      final msg1 = DbCenter.db.query(DbCenter.tbTicketMessage, conForSort1, limit: 1, orderBy: orderByServerTs);
      final msg2 = DbCenter.db.query(DbCenter.tbTicketMessage, conForSort2, limit: 1, orderBy: orderByServerTs);

      var v1 = '';
      var v2 = '';

      if (msg1.isNotEmpty) {
        v1 = msg1.first['server_receive_ts'];
      }

      if (msg2.isNotEmpty) {
        v2 = msg2.first['server_receive_ts'];
      }

      return [v1, v2];
    }

    int orderBy(j1, j2) {
      final serverTs = getServerTs(j1, j2);

      String ser1 = serverTs[0];
      String ser2 = serverTs[1];

      final s1 = ser1.isEmpty ? j1.value['start_date'] : ser1;
      final s2 = ser2.isEmpty ? j2.value['start_date'] : ser2;

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

    final cursorList = DbCenter.db.query(DbCenter.tbTickets, con, limit: limit, orderBy: orderBy);
    final ticketIds = <int>[];

    for (var itm in cursorList) {
      final r = TicketModel.fromMap(itm);

      ticketIds.add(r.id!);
      addItem(r);
    }

    return SynchronousFuture(ticketIds);
  }

  Future<List<int>> fetchUnSeenTickets({int limit = 100, String? lastTs}) {
    final innerCon = Conditions();
    final con = Conditions();

    con.add(Condition(ConditionType.TestFn)..testFn = (v){
      innerCon.clearConditions();
      final lastSeenTs = v['last_message_ts'];

      if(lastSeenTs == null){
        innerCon.add(Condition(ConditionType.EQUAL)..key = 'ticket_id'..value = v['id']);

        return DbCenter.db.exist(DbCenter.tbTicketMessage, innerCon);
      }

      innerCon.add(Condition(ConditionType.IsAfterTs)..key = 'server_receive_ts'..value = lastSeenTs);

      return DbCenter.db.exist(DbCenter.tbTicketMessage, innerCon);
    });

    if(lastTs != null){
      con.add(Condition(ConditionType.IsBeforeTs)..key = 'start_date'..value = lastTs);
    }

    int orderBy(j1, j2) {
      final s1 = j1.value['start_date'];
      final s2 = j2.value['start_date'];

      final d1 = DateHelper.tsToSystemDate(s1);
      final d2 = DateHelper.tsToSystemDate(s2);

      return d2!.compareTo(d1!);
    }

    final cursorList = DbCenter.db.query(DbCenter.tbTickets, con, limit: limit, orderBy: orderBy);
    final ticketIds = <int>[];

    for (var itm in cursorList) {
      final r = TicketModel.fromMap(itm);

      ticketIds.add(r.id!);
      addItem(r);
    }

    return SynchronousFuture(ticketIds);
  }

  static Future<List<BigInt>> fetchTicketMessageByTicketIds(List<int> ticketIds) {
    final con = Conditions()
      ..add(Condition(ConditionType.IN)..key = 'ticket_id'..value = ticketIds);

    var fetchList = DbCenter.db.query(DbCenter.tbTicketMessage, con,);

    final ids = <BigInt>[];

    for (var row in fetchList) {
      final tm = TicketMessageModel.fromMap(row);

      addTicketMessage(tm);
      ids.add(tm.id!);
    }

    fetchList = DbCenter.db.query(DbCenter.tbTicketMessageDraft, con, limit: ticketIds.length);
    for (var row in fetchList) {
      final tm = TicketMessageModel.fromMap(row);
      tm.isDraft = true;

      addTicketMessage(tm);
      ids.add(tm.id!);
    }

    return SynchronousFuture(ids);
  }

  static Future<void> fetchMediaMessageByIds(List<BigInt> mediaIds) {
    final con = Conditions();
    con.add(Condition(ConditionType.IN)..key = 'id'..value = mediaIds);

    var fetchList = DbCenter.db.query(DbCenter.tbMediaMessage, con, limit: mediaIds.length);

    for (var row in fetchList) {
      final mm = TicketMediaModel.fromMap(row);
      addMediaMessage(mm);
    }

    fetchList = DbCenter.db.query(DbCenter.tbMediaMessageDraft, con, limit: mediaIds.length);

    for (var row in fetchList) {
      final mm = TicketMediaModel.fromMap(row);
      mm.isDraft = true;

      addMediaMessage(mm);
    }

    return Future.value();
    //return SynchronousFuture(fetchList.length);
  }

  int findTicketLittleId() {
    var res = _list.first.id ?? 0;

    for (var element in allTicketList) {
      if (element.id! < res) {
        res = element.id!;
      }
    }

    return res;
  }

  String findTicketLittleTs() {
    var res = '';
    final ch = _list.first.startDate!;

    for (var element in allTicketList) {
      if (element.startDate!.compareTo(ch) < 0) {
        res = element.startDateTs!;
      }
    }

    return res;
  }

  static Future sinkTickets(List<TicketModel> list) async {
    before(oldVal, newVal) {
      final o = oldVal['last_message_ts'];
      final n = oldVal['last_message_ts'];
      final oo = DateHelper.tsToSystemDate(o);
      final nn = DateHelper.tsToSystemDate(n);

      if (DateHelper.compareDates(oo, nn) > 0) {
        newVal['last_message_ts'] = o;
      }

      return newVal;
    }

    for (var row in list) {
      final con = Conditions();
      con.add(Condition()..key = Keys.id..value = row.id);

      //await DbCenter.db.insertOrUpdate(DbCenter.tbTickets, row.toMap(), con);
      await DbCenter.db.insertOrUpdateEx(DbCenter.tbTickets, row.toMap(), con, before);
    }
  }

  static Future sinkTicketMessages(List<TicketMessageModel> list) async {
    for (var row in list) {
      final con = Conditions();
      con.add(Condition()..key = Keys.id..value = row.id);

      if (row.isDraft) {
        await DbCenter.db.insertOrUpdate(DbCenter.tbTicketMessageDraft, row.toMap(), con);
      }
      else {
        await DbCenter.db.insertOrUpdate(DbCenter.tbTicketMessage, row.toMap(), con);
      }
    }
  }

  static Future deleteMessages(List<TicketMessageModel> list) async {
    for (var row in list) {
      final con = Conditions();
      con.add(Condition()..key = Keys.id..value = row.id);

      await DbCenter.db.delete(DbCenter.tbTicketMessage, con);
    }
  }

  static Future deleteDraftMessages(List<TicketMessageModel> list) async {
    for (var row in list) {
      final con = Conditions();
      con.add(Condition()..key = Keys.id..value = row.id);

      await DbCenter.db.delete(DbCenter.tbTicketMessageDraft, con);
    }
  }

  static Future deleteDraftMedias(List<TicketMediaModel> list) async {
    for (var row in list) {
      final con = Conditions();
      con.add(Condition()..key = Keys.id..value = row.id);

      await DbCenter.db.delete(DbCenter.tbMediaMessageDraft, con);
    }
  }

  static Future deleteMedias(List<TicketMediaModel> list) async {
    for (var row in list) {
      final con = Conditions();
      con.add(Condition()..key = Keys.id..value = row.id);

      await DbCenter.db.delete(DbCenter.tbMediaMessage, con);
    }
  }

  static Future deleteMessage(TicketMessageModel msg, bool fromDb) async {
    _allTicketMessageList.removeWhere((element) {
      return element.id == msg.id;
    });

    if (fromDb) {
      if (msg.isDraft) {
        // ignore: unawaited_futures
        deleteDraftMessages([msg]);
      }
      else {
        // ignore: unawaited_futures
        deleteMessages([msg]);
      }
    }

    if (msg.mediaId != null) {
      allMediaMessageList.removeWhere((element) {
        return element.id == msg.mediaId;
      });

      if (fromDb) {
        if (msg.isDraft) {
          // ignore: unawaited_futures
          deleteDraftMedias([getMediaMessageById(msg.mediaId!)!]);
        }
        else {
          // ignore: unawaited_futures
          deleteMedias([getMediaMessageById(msg.mediaId!)!]);
        }
      }
    }
  }

  static Future sinkTicketMedia(List<TicketMediaModel> list) async {
    for (var row in list) {
      final con = Conditions();
      con.add(Condition()..key = Keys.id..value = row.id);

      if (row.isDraft) {
        await DbCenter.db.insertOrUpdate(DbCenter.tbMediaMessageDraft, row.toMap(), con);
      }
      else {
        await DbCenter.db.insertOrUpdate(DbCenter.tbMediaMessage, row.toMap(), con);
      }
    }
  }

  static void sendLastSeenToServer(int userId, int ticketId, String ts) {
    final js = <String, dynamic>{};
    js[Keys.request] = 'UpdateLastSeenTicket';
    js[Keys.userId] = userId;
    js['ticket_id'] = ticketId;
    js['date_ts'] = ts;

    final r = Requester();
    r.bodyJson = js;
    r.requestPath = RequestPath.SetData;

    final failDb = <String, dynamic>{};
    failDb['key'] = '$userId-$ticketId';
    failDb[Keys.userId] = userId;
    failDb['ticket_id'] = ticketId;
    failDb['date_ts'] = ts;

    r.httpRequestEvents.onFailState = (req) async {
      // ignore: unawaited_futures
      saveFailLastSeen(failDb);
    };

    r.request();
  }

  static Future saveFailLastSeen(Map data) {
    final con = Conditions();
    con.add(Condition(ConditionType.DefinedNotNull)..key = 'FailLastSeen'..value = data['key']);
    /*con.add(Condition(ConditionType.TestFn)..testFn = (map){
      return map['key'] = data['key'];
    });*/

    return DbCenter.db.insertOrUpdate(DbCenter.tbKv, data, con);
  }

  static void sendFailLastSeen() {
    final con = Conditions();
    con.add(Condition(ConditionType.DefinedNotNull)..key = 'FailLastSeen');

    final cursor = DbCenter.db.query(DbCenter.tbKv, con);

    DbCenter.db.delete(DbCenter.tbKv, con);

    for (var m in cursor) {
      sendLastSeenToServer(m['user_id'], m['ticket_id'], m['date_ts']);
    }
  }

  static void sendFailMessages() {
    final userId = Session.getLastLoginUser()?.userId;

    if (userId == null) {
      return;
    }

    int orderBy(j1, j2) {
      final d1 = j1.value['user_send_ts'];
      final d2 = j2.value['user_send_ts'];

      return DateHelper.compareDatesTs(d1, d2);
    }

    // ..add(Condition()..key = 'sender_user_id'..value = userId)
    final cursor = DbCenter.db.query(DbCenter.tbTicketMessageDraft, Conditions(), orderBy: orderBy);

    for (final m in cursor) {
      var tm = getTicketMessageById(BigInt.parse(m['id']));
      tm ??= TicketMessageModel.fromMap(m);

      sendMessage(tm);
    }
  }

  static void sendMessage(TicketMessageModel tm) {
    if (tm.mediaId == null) {
      _sendTextMessage(tm);
    }
    else {
      _sendMediaMessage(tm);
    }
  }

  static void _sendTextMessage(TicketMessageModel tm) async {
    final js = <String, dynamic>{};
    js[Keys.request] = 'NewTicketTextMessage';
    js[Keys.userId] = tm.senderUserId;
    js['message_data'] = tm.toMap();

    final r = Requester();
    r.bodyJson = js;
    r.requestPath = RequestPath.SetData;

    r.httpRequestEvents.onResultOk = (req, data) async {
      final serverTm = TicketMessageModel.fromMap(data[Keys.mirror]);
      // ignore: unawaited_futures
      deleteDraftMessages([tm]);

      tm.matchBy(serverTm);
      tm.isDraft = false;
      // ignore: unawaited_futures
      sinkTicketMessages([tm]);

      BroadcastCenter.ticketMessageUpdateNotifier.value = tm;
    };

    r.httpRequestEvents.onFailState = (f) async {
      TicketManager.startSendFailedTimer();
    };

    r.request();
  }

  static void _sendMediaMessage(TicketMessageModel tm) async {
    var media = getMediaMessageById(tm.mediaId!);

    if (media == null) {
      await fetchMediaMessageByIds([tm.mediaId!]);
      media = getMediaMessageById(tm.mediaId!);

      if (media == null) {
        return;
      }
    }

    final tag = Keys.genDownloadTag_ticketMedia(media);
    final current = DownloadUpload.uploadManager.getByTag(tag);

    if (current != null && current.isInProcess()) {
      return;
    }

    if (!await media.existMediaFile()) {
      media.isBroken = true;
      return;
    }

    final screenshotBytesExist = media.screenshotModel?.screenshotBytes != null;

    if (media.screenshotModel != null) { //tm.type == ChatType.VIDEO.typeNum
      if (!screenshotBytesExist && !await media.existScreenshotFile()) {
        //deleteDraftMedias([media]);
        //deleteDraftMessages([tm]);
        media.isBroken = true;
        return;
      }
    }

    //final fileName = PathHelper.getFileName(media.mediaPath!);
    final ext = media.extension;
    final fileName = Generator.generateDateMillWithKey(8) + '$ext';

    final js = <String, dynamic>{};
    js[Keys.request] = 'NewTicketMediaMessage';
    js[Keys.userId] = tm.senderUserId;
    js['message_data'] = tm.toMap();
    js['media_data'] = media.toMap();
    js[Keys.fileName] = fileName;
    js[Keys.partName] = 'TicketMediaFile';

    String? screenShotFileName;

    if (media.screenshotModel != null) {
      screenShotFileName = PathHelper.getFileName(media.screenshotPath!);

      js['screenshot_file_name'] = screenShotFileName;
      js['screenshot_js'] = media.screenshotModel?.toMap();
    }

    AppManager.addAppInfo(js);

    final url = HttpCenter.baseUri + '/set-data';
    final holder = TicketDownloadUploadHolder();
    holder.ownerId = tm.senderUserId;
    holder.ticketId = tm.ticketId;
    holder.messageId = tm.id;
    holder.mediaId = tm.mediaId;
    holder.messageModel = tm;

    final up = DownloadUpload.uploadManager.createUploadItem(url, tag);
    up.category = DownloadCategory.ticketMedia;
    up.subCategory = Keys.genCommonRefreshTag_ticketMessage(tm);
    up.attach = holder;
    up.countOfRetry = 5;
    up.addField(JsonHelper.mapToJson(js), Keys.jsonHttpPart);
    up.addFile(media.mediaPath!, 'TicketMediaFile', fileName);

    if (screenshotBytesExist) {
      up.addBytes(media.screenshotModel!.screenshotBytes!.toList(), 'screenshot', screenShotFileName!);
    }
    else if (media.screenshotPath != null) {
      up.addFile(media.screenshotPath!, 'screenshot', screenShotFileName!);
    }

    DownloadUpload.uploadManager.enqueue(up);
  }

  Future<bool> requestTopTickets() async {
    final js = <String, dynamic>{};
    js[Keys.request] = Keys.adminCommand;
    js[Keys.subRequest] = 'GetTicketsForManager';
    js[Keys.requesterId] = userId;
    js[Keys.userId] = userId;

    AppManager.addAppInfo(js);

    final http = HttpItem();
    http.setResponseIsPlain();
    http.pathSection = '/get-data';
    http.method = 'POST';
    http.setBody(JsonHelper.mapToJson(js));

    final httpRequester = HttpCenter.send(http);

    var f = httpRequester.responseFuture.catchError((e) {
      if (httpRequester.isDioCancelError) {
        return httpRequester.emptyError;
      }
    });


    f = f.then((val) async {
      final Map js = httpRequester.getBodyAsJson() ?? {};
      final result = js[Keys.result] ?? Keys.error;

      if (httpRequester.isOk && result == Keys.ok) {
        List? ticketMap = js['ticket_list'];
        List? messageMap = js['message_list'];
        List? mediaMap = js['media_list'];
        List? userMap = js['user_list'];
        List<int>? allIdsMap = Converter.correctList<int>(js['all_ticket_ids']);
        final domain = js[Keys.domain];

        final uList = UserAdvancedManager.addItemsFromMap(userMap, domain: domain);
        UserAdvancedManager.sinkItems(uList);

        final mList = TicketManager.addMediaMessagesFromMap(mediaMap);
        final m2List = TicketManager.addTicketMessagesFromMap(messageMap);
        final tList1 = addItemsFromMap(ticketMap);

        if (allIdsMap != null) {
          removeNotMatchByServer(allIdsMap);
        }

        sortList(false);

        TicketManager.sinkTicketMedia(mList);
        TicketManager.sinkTicketMessages(m2List);
        TicketManager.sinkTickets(tList1);

        return true;
      }

      return false;
    });

    return f.then((value) => value ?? false);
  }

  static void startSendFailedTimer() {
    if(_failSendCounter > 0 && _failSendCounter < 5) {
      return;
    }

    _failSendTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      _failSendCounter++;

      if (_failSendCounter > 4) {
        stopSendFailedTimer();
      }
      else {
        sendFailMessages();
      }
    });
  }

  static void stopSendFailedTimer() {
    _failSendTimer?.cancel();
    _failSendCounter = 0;
  }
}
