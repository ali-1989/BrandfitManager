import 'package:iris_tools/api/converter.dart';
import 'package:iris_tools/api/generator.dart';

import '/models/dataModels/programModels/foodInterface.dart';
import '/models/dataModels/programModels/foodMeal.dart';
import '/models/dataModels/programModels/fundamentalTypes.dart';
import '/system/keys.dart';

class FoodDay with FoodInterface<FoodDay> {
  late int id;
  int ordering = 1;
  List<FoodMeal> mealList = [];

  FoodDay() : id = Generator.generateIntId(10);

  FoodDay.fromMap(Map map){
    id = map[Keys.id]?? Generator.generateIntId(10);
    ordering = map['ordering']?? 1;

    final List<Map> mealListL = Converter.correctList<Map>(map['meals'])?? [];
    mealList = mealListL.map((e) => FoodMeal.fromMap(e)).toList();
  }

  @override
  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map[Keys.id] = id;
    map['ordering'] = ordering;
    map['meals'] = mealList.map((e) => e.toMap()).toList(growable: false);

    return map;
  }

  void matchBy(FoodDay others){
    id = others.id;
    ordering = others.ordering;
    mealList = others.mealList;
  }

  @override
  void sortChildren(){
    mealList.sort((d1, d2){
      if(d1.ordering == d2.ordering){
        return 0;
      }

      if(d1.ordering > d2.ordering){
        return 1;
      }

      return -1;
    });
  }

  int getLastOrdering(){
    int res = 0;

    for(final i in mealList){
      if(i.ordering > res){
        res = i.ordering;
      }
    }

    return res;
  }

  void reOrderingDec(int from){
    if(from > mealList.length){
      return;
    }

    for(int i = from-1; i< mealList.length; i++){
      final day = mealList[i];
      day.ordering = day.ordering-1;
    }
  }

  double sumFundamental(FundamentalTypes type, {int? suggestionId}){
    var res = 0.0;

    for(final m in mealList){
      res += m.sumFundamental(type, curSuggestionId: suggestionId);
    }

    return res;
  }

  bool isEmpty(){
    for(final m in mealList){
      if(m.suggestionList.isNotEmpty){
        for(final s in m.suggestionList){
          if(s.materialList.isNotEmpty){
            return false;
          }
        }
      }

      return true;
    }


    return true;
  }

  int sumFundamentalInt(FundamentalTypes type, {int? suggestionId}){
    return sumFundamental(type, suggestionId: suggestionId).toInt();
  }

  DateTime? getReportDate(){
    for(final m in mealList){
      for(final s in m.suggestionList){
        if(s.usedMaterialList.isNotEmpty){
          return s.usedMaterialList.first.registerTime;
        }
      }
    }

    return null;
  }

  @override
  int get hashCode {
    int sum = 0;

    for(final k in mealList){
      sum += k.hashCode;
    }

    return sum + id + ordering;
  }

  @override
  FoodDay fromMap(Map<String, dynamic> map) {
    return FoodDay.fromMap(map);
  }
}
