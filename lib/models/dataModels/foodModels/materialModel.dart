import 'package:flutter/material.dart';

import 'package:iris_tools/api/converter.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import '/managers/settingsManager.dart';
import '/models/dataModels/foodModels/materialFundamentalModel.dart';
import '/models/dataModels/foodModels/materialMeasureModel.dart';
import '/system/extensions.dart';
import '/system/keys.dart';

class MaterialModel {
  late int id;
  late String orgTitle;
  late String orgLanguage;
  String? type;
  Map translateJs = {};
  List<String> alternatives = [];
  late List<MaterialFundamentalModel> fundamentals = [];
  late List<FundamentalChange> changes = [];
  late MaterialMeasureModel measure;
  DateTime? registerDate;
  bool canShow = true;
  String? imageUri;
  late int creatorId;
  //-------------------- local
  String? matchTitle;
  List<MaterialFundamentalModel> mainFundamentals = [];
  List<MaterialFundamentalModel> otherFundamentals = [];

  MaterialModel();

  MaterialModel.fromMap(Map row, {String? domain}){
    final List<Map> fundamentalsJs = Converter.correctList<Map>(row['fundamentals_js'])?? [];
    final List<Map> changesList = Converter.correctList<Map>(row['changes'])?? [];

    id = row[Keys.id];
    orgTitle = row[Keys.title];
    orgLanguage = row['language'];
    type = row[Keys.type];
    canShow = row['can_show'];
    fundamentals = fundamentalsJs.map((e) => MaterialFundamentalModel.fromMap(e)).toList();
    alternatives = Converter.correctList<String>(row['alternatives'])?? [];
    translateJs = row['translates']?? {};
    measure = MaterialMeasureModel.fromMap(row['measure_js']);
    registerDate = DateHelper.tsToSystemDate(row['register_date']);
    imageUri = row['image_uri'];
    creatorId = row['creator_id']?? 0;
    changes = changesList.map((e) => FundamentalChange.fromMap(e)).toList();

    findMatchTitle();
    splitFundamentals();
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map[Keys.id] = id;
    map[Keys.title] = orgTitle;
    map['language'] = orgLanguage;
    map[Keys.type] = type;
    map['can_show'] = canShow;
    map['alternatives'] = alternatives;
    map['translates'] = translateJs;
    map['measure_js'] = measure.toMap();
    map['register_date'] = DateHelper.toTimestampNullable(registerDate);
    map['fundamentals_js'] = fundamentals.map((e) => e.toMap()).toList(growable: false);
    map['image_uri'] = imageUri;
    map['creator_id'] = creatorId;
    map['changes'] = changes.map((e) => e.toMap()).toList(growable: false);

    return map;
  }

  void matchBy(MaterialModel other){
    id = other.id;
    orgTitle = other.orgTitle;
    orgLanguage = other.orgLanguage;
    type = other.type;
    canShow = other.canShow;
    alternatives = other.alternatives;
    translateJs = other.translateJs;
    measure = other.measure;
    registerDate = other.registerDate;
    fundamentals = other.fundamentals;
    creatorId = other.creatorId;
    changes = other.changes;
  }

  void findMatchTitle(){
    matchTitle = orgTitle;

    if(orgLanguage != SettingsManager.settingsModel.appLocale.languageCode){
      for (var t in translateJs.entries) {
        if (t.key == SettingsManager.settingsModel.appLocale.languageCode) {
          matchTitle = t.value;
          break;
        }
      }
    }
  }

  void splitFundamentals() {
    mainFundamentals.clear();
    otherFundamentals.clear();

    for (final t in fundamentals) {
      if (type == 'matter' && Keys.mainMaterialFundamentals.contains(t.key)) {
        mainFundamentals.add(t);
      }
      else {
        otherFundamentals.add(t);
      }
    }
  }

  String? getTypeTranslate(BuildContext ctx){
    return ctx.tInMap('foodProgramScreen', type!);
  }

  String getMainFundamentalsPrompt(BuildContext ctx){
    var t = '';
    /*final caloriesKey = FundamentalTypes.calories.name;
    final proteinKey = FundamentalTypes.protein.name;
    final carbohydrateKey = FundamentalTypes.carbohydrate.name;
    final fatKey = FundamentalTypes.fat.name;*/
    final mainKeys = Keys.mainMaterialFundamentals;
    final proTrans = ctx.tAsMap('materialFundamentals')!;

    for(final mainKey in mainKeys){
      for(final fun in fundamentals){
        if(fun.key == mainKey){
          t += ' ${proTrans[mainKey]}: ${fun.value}';
        }
      }
    }

    return t;
  }

  String getMainFundamentalsPromptFor(BuildContext ctx, int value){
    var t = '';
    final mainKeys = Keys.mainMaterialFundamentals;
    final proTrans = ctx.tAsMap('materialFundamentals')!;
    final unit = double.parse(measure.unitValue);

    for(final mainKey in mainKeys){
      for(final fun in fundamentals){
        if(fun.key == mainKey){
          t += ' ${proTrans[mainKey]}: ${double.parse(fun.value?? '0') * value ~/ unit}';
        }
      }
    }

    return t;
  }

  FundamentalChange? findChangeByDate(String key, DateTime dt){
    FundamentalChange? res;

    for(final i in changes){
      if(i.fundamental.key == key){
        if(i.date.compareTo(dt) <= 0){
          if(res == null || res.date.compareTo(i.date) <= 0){
            res = i;
          }
        }
      }
    }

    return res;
  }

  bool isMatter(){
    return type == 'matter';
  }
}
///============================================================================================
class FundamentalChange {
  late DateTime date;
  late MaterialFundamentalModel fundamental;

  FundamentalChange();

  FundamentalChange.fromMap(Map map){
    date = DateHelper.tsToSystemDate(map['date'])!;
    fundamental = MaterialFundamentalModel.fromMap(map['fundamental']);
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};

    map['date'] = DateHelper.toTimestampNullable(date);
    map['fundamental'] = fundamental.toMap();

    return map;
  }
}


