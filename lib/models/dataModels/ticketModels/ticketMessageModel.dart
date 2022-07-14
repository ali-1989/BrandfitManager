import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:blur_preview/blur_hash.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import '/managers/ticketManager.dart';
import '/models/dataModels/ticketModels/ticketModel.dart';
import '/system/icons.dart';
import '/tools/app/appThemes.dart';
import '/tools/dateTools.dart';

class TicketMessageModel {
  BigInt? id;
  int? ticketId;
  String? text;
  int? senderUserId;
  int type = 0;
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
  int? replyId;
  //------------- local
  bool isDraft = false;
  DateTime? serverReceiveDate;
  DateTime? sendDate;
  Uint8List? coverImage;

  bool get isSeen => seenTs != null;
  DateTime get messageDate => serverReceiveDate?? sendDate!;

  TicketMessageModel();

  TicketMessageModel.fromMap(Map map){
    final mi = map['media_id'];
    final coverJs = map['cover_data'];

    id = BigInt.parse(map['id']);
    ticketId = map['ticket_id'];
    mediaId = mi != null? BigInt.parse(mi): null;
    replyId = map['reply_id'];
    type = map['message_type'];
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
    coverData = coverJs;// != null? ChatCoverModel.fromMap(coverJs): null;

    //------------- local
    serverReceiveDate = DateHelper.tsToSystemDate(serverReceiveTs);
    sendDate = DateHelper.tsToSystemDate(sendTs);
  }

  void matchBy(TicketMessageModel other){
    id = other.id;
    ticketId = other.ticketId;
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
    map['ticket_id'] = ticketId;
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
      final media = TicketManager.getMediaMessageById(mediaId!)!;
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

  bool senderIsUser(TicketModel ticket){
    return senderUserId == ticket.starterUserId;
  }
}
