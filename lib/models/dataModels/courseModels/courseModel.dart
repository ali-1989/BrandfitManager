import 'package:flutter/material.dart';

import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import '/models/dataModels/countryModel.dart';
import '/system/enums.dart';
import '/system/extensions.dart';
import '/system/keys.dart';
import '/tools/app/appThemes.dart';
import '/tools/centers/directoriesCenter.dart';
import '/tools/uriTools.dart';

class CourseModel {
  int id = 0;
  int creatorUserId = 0;
  late String title;
  late String description;
  late String price;
  late CurrencyModel currencyModel;
  bool hasFoodProgram = false;
  bool hasExerciseProgram = false;
  bool isPrivateShow = false;
  bool isBlock = false;
  int durationDay = 0;
  DateTime? creationDate;
  DateTime? startBroadcastDate;
  DateTime? finishBroadcastDate;
  String? imageUri;
  Map? blockJs; // this field is for trainer/manager
  Map answerJs = {};
  String? creatorUserName; // this field is for manager
  CourseModel(){
    id = Generator.generateIntId(16);
  }

  CourseModel.fromMap(Map js, {String? domain}){
    id = js[Keys.id];
    creatorUserId = js['creator_user_id'];
    title = js[Keys.title];
    description = js['description'];
    price = js['price'];
    currencyModel = CurrencyModel.fromMap(js['currency_js']);
    isPrivateShow = js['is_private_show'];
    isBlock = js['is_block'];
    blockJs = js['block_js'];
    durationDay = js['duration_day']?? 29;
    creationDate = DateHelper.tsToSystemDate(js['creation_date']);
    startBroadcastDate = DateHelper.tsToSystemDate(js['start_date']);
    finishBroadcastDate = DateHelper.tsToSystemDate(js['finish_date']);
    hasFoodProgram = js['has_food_program']?? false;
    hasExerciseProgram = js['has_exercise_program']?? false;
    imageUri = js['image_uri'];
    //-----------------------
    answerJs = js['answer_js']?? {};
    creatorUserName = js['user_name'];
    imageUri = UriTools.correctAppUrl(imageUri, domain: domain);
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};

    map[Keys.id] = id;
    map['creator_user_id'] = creatorUserId;
    map[Keys.title] = title;
    map['description'] = description;
    map['price'] = price;
    map['currency_js'] = currencyModel.toMap();
    map['has_food_program'] = hasFoodProgram;
    map['has_exercise_program'] = hasExerciseProgram;
    map['is_private_show'] = isPrivateShow;
    map['is_block'] = isBlock;
    map['block_js'] = blockJs;
    map['duration_day'] = durationDay;
    map['creation_date'] = DateHelper.toTimestampNullable(creationDate);
    map[Keys.imageUri] = imageUri;

    map['answer_js'] = answerJs;
    map['user_name'] = creatorUserName;

    return map;
  }

  void matchBy(CourseModel other){
    id = other.id;
    creatorUserId = other.creatorUserId;
    title = other.title;
    description = other.description;
    price = other.price;
    currencyModel = other.currencyModel;
    hasFoodProgram = other.hasFoodProgram;
    hasExerciseProgram = other.hasExerciseProgram;
    isPrivateShow = other.isPrivateShow;
    durationDay = other.durationDay;
    isBlock = other.isBlock;
    blockJs = other.blockJs;
    answerJs = other.answerJs;
    creationDate = other.creationDate;
    imageUri = other.imageUri;

    creatorUserName = other.creatorUserName;
  }

  bool get isAccept => answerJs.containsKey('accept');

  bool get isReject => answerJs.containsKey('reject');

  bool get hasImage => imageUri != null || FileHelper.existSync(imagePath!);

  String? get imagePath => DirectoriesCenter.getSavePathUri(imageUri?? 'c$id.jpg', SavePathType.COURSE_PHOTO);

  String? getRejectCause(BuildContext ctx){
    if(isReject && answerJs.containsKey('cause')){
      return answerJs['cause'];
    }

    return null;
  }

  String getStatusText(BuildContext ctx){
    if(isAccept){
      return ctx.t('accepted')!;
    }
    else if(isReject){
      return ctx.t('rejected')!;
    }

    return ctx.t('pending')!;
  }

  Color getStatusColor(){
    if(isAccept){
      return AppThemes.currentTheme.successColor;
    }
    else if(isReject){
      return AppThemes.currentTheme.errorColor;
    }

    return AppThemes.currentTheme.textColor;
  }
}
