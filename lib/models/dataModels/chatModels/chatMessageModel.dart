import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:blur_preview/blur_hash.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import '/managers/chatManager.dart';
import '/models/dataModels/chatModels/chatModel.dart';
import '/system/icons.dart';
import '/tools/app/appThemes.dart';
import '/tools/dateTools.dart';

class ChatMessageModel {
  BigInt? id;
  int? chatId;
  String? text;
  int senderUserId = 0;
  int type = 1;
  String? sendTs;
  String? serverReceiveTs;
  String? userReceiveTs;
  String? seenTs;
  bool isEdited = false;
  bool isDeleted = false;
  bool isClose = false;
  String? coverData;
  Map? extraJs;
  BigInt? mediaId;
  BigInt? replyId;
  BigInt? forwardId;
  //------------- local
  bool isDraft = false;
  DateTime? serverReceiveDate;
  DateTime? sendDate;
  Uint8List? coverImage;

  bool get isSeen => seenTs != null;
  DateTime get messageDate => serverReceiveDate?? sendDate!;

  ChatMessageModel();

  ChatMessageModel.fromMap(Map map){
    final sMediaId = map['media_id'];
    final sReplyId = map['reply_id'];
    final sForwardId = map['forward_id'];
    final fCoverData = map['cover_data'];

    id = BigInt.parse(map['id']);
    chatId = map['conversation_id'];
    mediaId = sMediaId != null? BigInt.parse(sMediaId): null;
    replyId = sReplyId != null? BigInt.parse(sReplyId): null;
    forwardId = sForwardId != null? BigInt.parse(sForwardId): null;
    type = map['message_type']?? 1;
    senderUserId = map['sender_user_id'];
    isEdited = map['is_edited']?? false;
    isDeleted = map['is_deleted']?? false;
    isClose = map['is_close']?? false;
    sendTs = map['user_send_ts'];
    serverReceiveTs = map['server_receive_ts'];
    userReceiveTs = map['receive_ts'];
    seenTs = map['seen_ts'];
    text = map['message_text'];
    extraJs = map['extra_js'];
    coverData = fCoverData;

    //------------- local
    serverReceiveDate = DateHelper.tsToSystemDate(serverReceiveTs);
    sendDate = DateHelper.tsToSystemDate(sendTs);
  }

  void matchBy(ChatMessageModel other){
    id = other.id;
    chatId = other.chatId;
    mediaId = other.mediaId;
    replyId = other.replyId;
    type = other.type;
    senderUserId = other.senderUserId;
    isEdited = other.isEdited;
    isDeleted = other.isDeleted;
    isClose = other.isClose;
    sendTs =other.sendTs;
    serverReceiveTs = other.serverReceiveTs;
    userReceiveTs = other.userReceiveTs;
    seenTs = other.seenTs;
    text = other.text;
    extraJs = other.extraJs;
    coverData = other.coverData;
    //------------- local
    serverReceiveDate = other.serverReceiveDate;
    sendDate = other.sendDate;
    isDraft = other.isDraft;
  }

  Map toMap(){
    final map = {};

    map['id'] = id!.toString();
    map['conversation_id'] = chatId;
    map['media_id'] = mediaId != null? mediaId!.toString(): null;
    map['reply_id'] = replyId;
    map['message_type'] = type;
    map['sender_user_id'] = senderUserId;
    map['is_edited'] = isEdited;
    map['is_deleted'] = isDeleted;
    map['is_close'] = isClose;
    map['user_send_ts'] = sendTs;
    map['server_receive_ts'] = serverReceiveTs;
    map['receive_ts'] = userReceiveTs;
    map['seen_ts'] = seenTs;
    map['message_text'] = text;
    map['extra_js'] = extraJs;
    map['cover_data'] = coverData;

    return map;
  }

  Future prepareCover() async {
    if(coverImage == null && coverData != null){
      final media = ChatManager.getMediaById(mediaId!)!;
      coverImage = await BlurHash.hashToImageBytes(coverData!, media.width!, media.height!);
    }
  }

  String getShowDate(){
    String ts;

    if(seenTs != null){
      ts = seenTs!;
    }

    if(userReceiveTs != null){
      ts = userReceiveTs!;
    }

    if(serverReceiveTs != null){
      ts = serverReceiveTs!;
    }

    ts = sendTs!;

    if(DateHelper.isToday(DateHelper.tsToSystemDate(ts)!, utc: true)){
      return DateTools.dateHmOnlyRelative$String(ts);
    }

    return DateTools.dateAndHmRelative$String(ts);
  }

  IconData getStateIcon(){
    IconData? ts;

    if(seenTs != null){
      ts = IconList.tickM;//tick2M;
    }

    else if(userReceiveTs != null){
      ts = IconList.tickM;//tick2M;
    }

    else if(serverReceiveTs != null){
      ts = IconList.tickM;
    }
    else {
      ts = IconList.timerSand;
    }

    return ts;
  }

  Color getStateColor(){
    return seenTs != null? AppThemes.currentTheme.primaryColor: Colors.black.withAlpha(180);
  }

  // Addressee: sender|receiver in P2P
  bool senderIsAddressee(ChatModel chat){
    return senderUserId == chat.addressee(senderUserId)?.userId;
  }

  bool isLeftSide(ChatModel chat){
    return senderUserId == chat.members[0];
  }
}
