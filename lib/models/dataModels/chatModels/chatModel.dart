import 'dart:io';

import 'package:flutter/cupertino.dart';

import 'package:iris_tools/api/converter.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import '/database/models/userAdvancedModelDb.dart';
import '/managers/chatManager.dart';
import '/managers/userAdvancedManager.dart';
import '/models/dataModels/chatModels/chatMessageModel.dart';
import '/system/keys.dart';
import '/tools/centers/broadcastCenter.dart';
import '/tools/dateTools.dart';
import '/tools/uriTools.dart';

class ChatModel {
  int? id;
  String? title;
  int creatorUserId = 0;
  int? receiverId;
  int type = 10;
  String? creationDateTs;
  bool isClose = false;
  bool isDelete = false;
  String? logoUrl;
  String? description;
  int state = 4;
  String? lastSeenMessageTs;
  List<int> members = [];

  //------------------ local
  DateTime? lastSeenMessageDate;
  DateTime? creationDate;
  final List<ChatMessageModel> _messages = [];
  ChatMessageModel? _lastMessage;
  ///if open new chat this must be true
  bool isDraft = false;

  ChatModel();

  ChatModel.fromMap(Map map, {String? domain}){
    final fId = map[Keys.id];
    id = fId is int? fId : int.parse(fId);
    title = map[Keys.title];
    creatorUserId = map['creator_user_id']?? 0;
    receiverId = map['receiver_id'];
    type = map[Keys.type]?? 10;
    creationDateTs = map['creation_date'];
    lastSeenMessageTs = map['last_message_ts'];
    isClose = map['is_close']?? false;
    isDelete = map['is_deleted']?? false;
    description = map['description'];
    logoUrl = map['logo_url'];
    state = map['state_key']?? 4;
    members = Converter.correctList<int>(map['members'])?? [];
    //----------------------- local
    isDraft = map['is_draft']?? false;
    lastSeenMessageDate = DateHelper.tsToSystemDate(lastSeenMessageTs);
    creationDate = DateHelper.tsToSystemDate(creationDateTs);

    logoUrl = UriTools.correctAppUrl(logoUrl, domain: domain);
  }

  Map toMap(){
    final map = {};

    map[Keys.id] = id;
    map[Keys.title] = title;
    map['creator_user_id'] = creatorUserId;
    map['receiver_id'] = receiverId;
    map[Keys.type] = type;
    map['creation_date'] = creationDateTs;
    map['last_message_ts'] = lastSeenMessageTs;
    map['is_close'] = isClose;
    map['is_deleted'] = isDelete;
    map['description'] = description;
    map['logo_url'] = logoUrl;
    map['state_key'] = state;
    map['members'] = members;
    //----------------------- local
    map['is_draft'] = isDraft;

    return map;
  }

  void matchBy(ChatModel other){
    id = other.id;
    title = other.title;
    creatorUserId = other.creatorUserId;
    receiverId = other.receiverId;
    type = other.type;
    creationDateTs = other.creationDateTs;
    lastSeenMessageTs = other.lastSeenMessageTs;
    isClose = other.isClose;
    isDelete = other.isDelete;
    description = other.description;
    logoUrl = other.logoUrl;
    state = other.state;
    members = other.members;
    //---------------------- locale
    lastSeenMessageDate = other.lastSeenMessageDate;
    creationDate = other.creationDate;
  }

  DateTime? get chatSortTime => lastSeenMessageDate?? creationDate;

  void updateMessageList({includeDeleted = false}){
    _messages.clear();

    final itr = ChatManager.allMessageList.where(
            (element) => element.chatId == id && (includeDeleted || element.isDeleted == false));

    _messages.addAll(itr.toList());
  }

  List<ChatMessageModel> get messages {
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

  ChatMessageModel? get lastMessage {
    if(_lastMessage == null) {
      _findLastMessage();
    }

    return _lastMessage;
  }

  ChatMessageModel? findMessageById(BigInt id){
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

  bool addMessage(ChatMessageModel tm){
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

  UserAdvancedModelDb? creatorUser(){
    return UserAdvancedManager.getById(creatorUserId);
  }

  UserAdvancedModelDb? receiverUser(){
    return UserAdvancedManager.getById(receiverId?? 0);
  }

  // sender|receiver on P2P chat
  UserAdvancedModelDb? addressee(int myId){
    if(type != 10 || receiverId == null){
      return null;
    }

    if(receiverId != myId){
      return UserAdvancedManager.getById(receiverId!);
    }

    return UserAdvancedManager.getById(myId);
    //return UserLimitManager.getById(creatorUserId);
  }

  String getLastMessageDate(){
    DateTime? dt;

    if(messages.isEmpty){
      dt = creationDate;
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

  String? getAddresseeAvatarUri(int myId) {
    final u = addressee(myId);

    if(u == null){
      return null;
    }

    return u.profileUri;
  }

  String? getAddresseeAvatarPath(int myId){
    final u = addressee(myId);

    if(u == null){
      return null;
    }

    return u.genProfilePath();
  }

  ImageProvider? getAddresseeAvatarProvider(int myId){
    final u = addressee(myId);

    if(u == null){
      return null;
    }

    return u.getProfileProvider();
  }

  File? getAddresseeProfileFile(int myId){
    final u = addressee(myId);

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
      BroadcastCenter.chatUpdateNotifier.value = ChatModel();
    }

    ChatManager.sinkChats([this]);
  }

  void setMyMessageSeenByUser(String ts, int senderId){
    final saveList = <ChatMessageModel>[];

    for(var m in messages){
      if(m.senderUserId == senderId){
        m.seenTs = ts;
        saveList.add(m);
      }
    }

    ChatManager.sinkChatMessages(saveList);
  }

  String getChatMessageType(ChatMessageModel? message){
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

  String getTitleView(){
    if(type == 10){
      final user1 = UserAdvancedManager.getById(members[0]);
      final user2 = UserAdvancedManager.getById(members[1]);

      return '${user1?.userName?? ''}  -  ${user2?.userName?? ''}';
    }

    return title?? '';
  }
}
