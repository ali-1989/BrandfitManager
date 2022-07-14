import 'dart:io';

import 'package:flutter/cupertino.dart';

import 'package:iris_tools/dateSection/dateHelper.dart';

import '/database/models/userAdvancedModelDb.dart';
import '/managers/ticketManager.dart';
import '/managers/userAdvancedManager.dart';
import '/models/dataModels/ticketModels/ticketMessageModel.dart';
import '/system/keys.dart';
import '/tools/centers/broadcastCenter.dart';
import '/tools/dateTools.dart';

class TicketModel {
  int? id;
  String? title;
  int? starterUserId;
  int type = 0;
  String? startDateTs;
  String? lastSeenMessageTs;
  bool isClose = false;
  bool isDelete = false;
  //------------------ local
  DateTime? lastSeenMessageDate;
  DateTime? startDate;
  final List<TicketMessageModel> _messages = [];
  TicketMessageModel? _lastMessage;
  ///if open new ticket this must be true
  bool isDraft = false;

  TicketModel();

  TicketModel.fromMap(Map map, {String? domain}){
    final fId = map[Keys.id];
    id = fId is int? fId : int.parse(fId);
    title = map[Keys.title];
    starterUserId = map['starter_user_id'];
    type = map[Keys.type];
    startDateTs = map['start_date'];
    lastSeenMessageTs = map['last_message_ts'];
    isClose = map['is_close']?? false;
    isDelete = map['is_deleted']?? false;
    //-------------------------- local
    isDraft = map['is_draft']?? false;
    lastSeenMessageDate = DateHelper.tsToSystemDate(lastSeenMessageTs);
    startDate = DateHelper.tsToSystemDate(startDateTs);
  }

  Map toMap(){
    final map = {};

    map[Keys.id] = id;
    map[Keys.title] = title;
    map['starter_user_id'] = starterUserId;
    map[Keys.type] = type;
    map['start_date'] = startDateTs;
    map['last_message_ts'] = lastSeenMessageTs;
    map['is_close'] = isClose;
    map['is_deleted'] = isDelete;
    //-------------------------- local
    map['is_draft'] = isDraft;

    return map;
  }

  void matchBy(TicketModel other){
    id = other.id;
    title = other.title;
    starterUserId = other.starterUserId;
    type = other.type;
    startDateTs = other.startDateTs;
    lastSeenMessageTs = other.lastSeenMessageTs;
    isClose = other.isClose;
    isDelete = other.isDelete;
    //------------------------- locale
    lastSeenMessageDate = other.lastSeenMessageDate;
    startDate = other.startDate;
  }

  DateTime? get ticketSortTime => lastSeenMessageDate?? startDate;

  void updateMessageList({includeDeleted = false}){
    _messages.clear();

    final itr = TicketManager.allTicketMessageList.where(
            (element) => element.ticketId == id && (includeDeleted || element.isDeleted == false));

    _messages.addAll(itr.toList());
  }

  List<TicketMessageModel> get messages {
    if(_messages.isEmpty){
      updateMessageList();
      sortMessages();
    }

    return _messages;
  }

  void _findLastMessage(){
    if(messages.isNotEmpty) {
      sortMessages();
      _lastMessage = messages.last;
    }
  }

  TicketMessageModel? get lastMessage {
    if(_lastMessage == null) {
      _findLastMessage();
    }

    return _lastMessage;
  }

  TicketMessageModel? findMessageById(BigInt id){
    try{
      return _messages.firstWhere((element) => element.id == id);
    }
    catch (e){
      return null;
    }
  }

  String? findMessageLittleTs() {
    if(messages.isEmpty){
      return null;
    }

    DateTime res = messages.first.messageDate;

    for (var element in messages) {
      if(element.messageDate.compareTo(res) < 0){
        res = element.messageDate;
      }
    }

    return DateHelper.toTimestamp(res);
  }

  bool addMessage(TicketMessageModel tm){
    var existItem = findMessageById(tm.id?? BigInt.zero);

    if(existItem == null){
      _messages.add(tm);
      _lastMessage = tm;
      return true;
      //_findLastMessage();
    }
    else {
      existItem.matchBy(tm);
      return false;
    }
  }

  void sortMessages(){
    _messages.sort((e1, e2){
      return DateHelper.compareDates(
          e1.serverReceiveDate?? e1.sendDate,
          e2.serverReceiveDate?? e2.sendDate);
    });
  }

  UserAdvancedModelDb? starterUser(){
    return UserAdvancedManager.getById(starterUserId?? 0);
  }

  String genLastDate(){
    DateTime? dt;

    if(messages.isEmpty){
      dt = startDate;
    }
    else {
      dt = lastMessage?.serverReceiveDate?? lastMessage?.sendDate;
    }

    if(dt != null){
      if(DateHelper.isToday(dt)){
        return DateTools.dateHmOnlyRelative(dt, isUtc: true);
      }
    }

    return DateTools.dateAndHmRelative(dt, isUtc: true);
  }

  int unReadCount(){
    if(lastSeenMessageDate == null){
      return messages.length;
    }

    var c = 0;

    for(var d in messages){
      if(d.serverReceiveDate != null) {
        if (d.serverReceiveDate!.compareTo(lastSeenMessageDate!) > 0) {
          c++;
        }
      }
    }

    return c;
  }

  String? getAvatarUri() {
    final u = starterUser();

    if(u == null){
      return null;
    }

    return u.profileUri;
  }

  String? getAvatarPath(){
    final u = starterUser();

    if(u == null){
      return null;
    }

    return u.genProfilePath();
  }

  ImageProvider? getAvatarProvider(){
    final u = starterUser();

    if(u == null){
      return null;
    }

    return u.getProfileProvider();
  }

  File? getProfileFile(){
    final u = starterUser();

    if(u == null){
      return null;
    }

    return File(u.profilePath!);
  }

  void updateLastSeenDate({DateTime? dateTs, bool notifyParent = true}){
    if(dateTs != null){
      lastSeenMessageDate = dateTs;
    }
    else {
      _findLastMessage();
      lastSeenMessageDate = lastMessage?.serverReceiveDate?? lastMessage?.sendDate?? DateHelper.getNowToUtc();
      lastSeenMessageDate = lastSeenMessageDate!.add(Duration(milliseconds: 5));
    }

    lastSeenMessageTs = DateHelper.toTimestamp(lastSeenMessageDate!);

    if(notifyParent) {
      BroadcastCenter.ticketUpdateNotifier.value = TicketModel();
    }

    TicketManager.sinkTickets([this]);
  }

  void setMyMessageSeenByUser(String ts, int senderId){
    final saveList = <TicketMessageModel>[];

    for(var m in messages){
      if(m.senderUserId == senderId){
        m.seenTs = ts;
        saveList.add(m);
      }
    }

    TicketManager.sinkTicketMessages(saveList);
  }

  String getTicketMessageType(TicketMessageModel? message){
    if(message == null){
      return 'none';
    }

    if(message.type == 0) {
      return 'file';
    }

    if(message.type == 1) {
      return 'text';
    }

    if(message.type == 2) {
      return 'audio';
    }

    if(message.type == 3) {
      return 'video';
    }

    if(message.type == 4) {
      return 'image';
    }

    return '';
  }

  void invalidate(){
    _lastMessage = null;
    messages.clear();
  }
}
