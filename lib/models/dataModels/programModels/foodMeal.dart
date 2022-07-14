import 'package:iris_tools/api/converter.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';

import '/models/dataModels/programModels/foodInterface.dart';
import '/models/dataModels/programModels/foodSuggestion.dart';
import '/models/dataModels/programModels/fundamentalTypes.dart';
import '/system/keys.dart';

class FoodMeal with FoodInterface {
  late int id;
  int ordering = 1;
  String? title;
  DateTime? eatTime;
  List<FoodSuggestion> suggestionList = [];

  FoodMeal() : id = Generator.generateIntId(10);

  FoodMeal.fromMap(Map map){
    id = map[Keys.id]?? Generator.generateIntId(10);
    title = map[Keys.title];
    ordering = map['ordering']?? 1;
    eatTime = map['eat_time'];

    final List<Map> sugListL = Converter.correctList(map['suggestions'])?? [];
    suggestionList = sugListL.map((e) => FoodSuggestion.fromMap(e)).toList();
  }

  @override
  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map[Keys.id] = id;
    map[Keys.title] = title;
    map['ordering'] = ordering;
    map['eat_time'] = eatTime;
    map['suggestions'] = suggestionList.map((e) => e.toMap()).toList(growable: false);

    return map;
  }

  void matchBy(FoodMeal others){
    id = others.id;
    ordering = others.ordering;
    title = others.title;
    eatTime = others.eatTime;
    suggestionList = others.suggestionList;
  }

  void reId(){
    id = Generator.generateIntId(10);
  }

  @override
  void sortChildren(){
    suggestionList.sort((d1, d2){
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

    for(final i in suggestionList){
      if(i.ordering > res){
        res = i.ordering;
      }
    }

    return res;
  }

  void reOrderingDec(int from){
    if(from > suggestionList.length){
      return;
    }

    for(int i = from-1; i< suggestionList.length; i++){
      final sug = suggestionList[i];

      sug.ordering = sug.ordering-1;
    }
  }

  void reOrderingInc(int from){
    if(from > suggestionList.length){
      return;
    }

    for(int i = from; i< suggestionList.length; i++){
      final day = suggestionList[i];
      day.ordering = day.ordering+1;
    }
  }

  double sumFundamental(FundamentalTypes type, {int? curSuggestionId}){
    var res = 0.0;
    bool existSug = suggestionList.indexWhere((element) => element.id == curSuggestionId) >= 0;

    for(final m in suggestionList){
      if(existSug){
        if(m.id == curSuggestionId){
          res += m.sumFundamental(type);
        }
      }
      else if(m.isBase) {
        res += m.sumFundamental(type);
      }
    }

    return res;
  }

  int sumFundamentalInt(FundamentalTypes type, {int? curSuggestionId}){
    return sumFundamental(type, curSuggestionId: curSuggestionId).toInt();
  }

  int percentOfCalories(int whole){
    int sum = sumFundamental(FundamentalTypes.calories).toInt();
    return MathHelper.percentInt(whole, sum);
  }

  @override
  FoodMeal fromMap(Map<String, dynamic> map) {
    return FoodMeal.fromMap(map);
  }

  @override
  int get hashCode {
    int sum = 0;

    for(final k in suggestionList){
      sum += k.hashCode;
    }

    return sum + id + ordering + (title?.hashCode?? 0) + (eatTime?.millisecondsSinceEpoch?? 0);
  }

  @override
  String toString() {
    return '(meal) > id: $id, ordering: $ordering, name: $title';
  }
}
