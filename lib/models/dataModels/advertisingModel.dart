import 'dart:io';

import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/pathHelper.dart';
import 'package:iris_tools/api/helpers/urlHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import '/managers/settingsManager.dart';
import '/system/keys.dart';

class AdvertisingModel {
  int? id;
  int? creatorId;
  String? creatorUserName;
  String? type;
  String? tag;
  String? title;
  int? orderNum;
  bool canShow = true;
  String? imageUri;
  DateTime? registerDate;
  DateTime? startShowDate;
  DateTime? finishShowDate;
  String? clickLink;
  //----------- local --------------------
  String? imagePath;
  File? advFile;
  Widget? imageWidget;

  AdvertisingModel();

  bool get inRange{
    if(startShowDate == null && finishShowDate == null){
      return true;
    }

    if(startShowDate != null){
      if (startShowDate!.isAfter(DateHelper.getNow())){
        return false;
      }
    }

    if(finishShowDate != null){
      if (finishShowDate!.isBefore(DateHelper.getNow())){
        return false;
      }
    }

    return true;
  }

  AdvertisingModel.fromMap(Map map, {String? domain}){
    id = map['id'];
    creatorUserName = map[Keys.userName];
    title = map[Keys.title];
    type = map[Keys.type];
    tag = map['tag'];
    canShow = map['can_show']?? true;
    clickLink = map['click_link'];
    creatorId = map['creator_id'];
    orderNum = map['order_num'];
    imageUri = map[Keys.imageUri];

    if(imageUri != null) {
      if(!imageUri!.startsWith(RegExp('http'))) {
        imageUri = (domain ?? SettingsManager.settingsModel.httpAddress!) + imageUri!;
      }

      imageUri = UrlHelper.decodePathFromDataBase(imageUri!);
      imageUri = PathHelper.resolvePath(imageUri!);
    }

    registerDate = DateHelper.tsToSystemDate(map['register_date']);
    startShowDate = DateHelper.tsToSystemDate(map['start_show_date']);
    finishShowDate = DateHelper.tsToSystemDate(map['finish_show_date']);

    registerDate = DateHelper.utcToLocal(registerDate!);

    if(startShowDate != null){
      startShowDate = DateHelper.utcToLocal(startShowDate!);
    }

    if(finishShowDate != null){
      finishShowDate = DateHelper.utcToLocal(finishShowDate!);
    }

    imagePath = map['path'];
  }
}
