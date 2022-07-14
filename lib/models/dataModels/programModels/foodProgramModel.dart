import 'package:iris_tools/api/converter.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import '/models/dataModels/programModels/IProgramModel.dart';
import '/models/dataModels/programModels/foodDay.dart';
import '/models/dataModels/programModels/foodInterface.dart';
import '/models/dataModels/programModels/fundamentalTypes.dart';
import '/system/keys.dart';

class FoodProgramModel extends IProgramModel with FoodInterface<FoodProgramModel>  {
  Map? pcl;
  bool canShow = true;
  List<FoodDay> foodDays = [];

  FoodProgramModel();

  FoodProgramModel.fromMap(Map map){
    id = map[Keys.id]?? 0;
    trainerId = map['trainer_id']?? 0;
    requestId = map['request_id']?? 0;
    title = map[Keys.title];
    pcl = map['p_c_l'];
    registerDate = DateHelper.tsToSystemDate(map['register_date']);
    cronDate = DateHelper.tsToSystemDate(map['cron_date']);
    sendDate = DateHelper.tsToSystemDate(map['send_date']);
    pupilSeeDate = DateHelper.tsToSystemDate(map['pupil_see_date']);
    canShow = map['can_show'];

    final dayList = Converter.correctList<Map>(map['days'])?? [];
    foodDays = dayList.map((e) => FoodDay.fromMap(e)).toList();
  }

  @override
  Map<String, dynamic> toMap({bool withDays = false}){
    final map = <String, dynamic>{};

    map[Keys.id] = id;
    map['trainer_id'] = trainerId;
    map['request_id'] = requestId;
    map[Keys.title] = title;
    map['can_show'] = canShow;
    map['p_c_l'] = pcl;
    map['register_date'] = DateHelper.toTimestamp(registerDate?? DateHelper.getNowToUtc());
    map['cron_date'] = DateHelper.toTimestampNullable(cronDate);
    map['send_date'] = DateHelper.toTimestampNullable(sendDate);
    map['pupil_see_date'] = DateHelper.toTimestampNullable(pupilSeeDate);

    if(withDays){
      map['days'] = daysToMap();
    }

    return map;
  }

  void matchBy(FoodProgramModel others){
    id = others.id;
    trainerId = others.trainerId;
    requestId = others.requestId;
    title = others.title;
    pcl = others.pcl;
    registerDate = others.registerDate;
    cronDate = others.cronDate;
    sendDate = others.sendDate;
    pupilSeeDate = others.pupilSeeDate;
    canShow = others.canShow;
    foodDays = others.foodDays;
  }

  List<Map> daysToMap(){
    final res = <Map>[];

    for(final i in foodDays){
      res.add(i.toMap());
    }

    return res;
  }

  @override
  void sortChildren(){
    foodDays.sort((d1, d2){
      if(d1.ordering == d2.ordering){
        return 0;
      }

      if(d1.ordering > d2.ordering){
        return 1;
      }

      return -1;
    });
  }

  void updateDaysBy(List<Map> days){
    foodDays.clear();

    foodDays.addAll(days.map((e) => FoodDay.fromMap(e)).toList());
  }

  int getLastOrdering(){
    int res = 0;

    for(final i in foodDays){
      if(i.ordering > res){
        res = i.ordering;
      }
    }

    return res;
  }

  void reOrderingDec(int from){
    if(from > foodDays.length){
      return;
    }

    for(int i = from-1; i< foodDays.length; i++){
      final day = foodDays[i];
      day.ordering = day.ordering-1;
    }
  }

  void reOrderingInc(int from){
    if(from > foodDays.length){
      return;
    }

    for(int i = from; i< foodDays.length; i++){
      final day = foodDays[i];
      day.ordering = day.ordering+1;
    }
  }

  double sumFundamental(FundamentalTypes type){
    var res = 0.0;

    for(var i in foodDays){
      res += i.sumFundamental(type);
    }

    return res;
  }

  int sumFundamentalInt(FundamentalTypes type){
    var res = 0.0;

    for(final i in foodDays){
      res += i.sumFundamental(type);
    }

    return res.toInt();
  }

  bool hasEmptyDay(){
    for(final i in foodDays){
      if(i.isEmpty()){
        return true;
      }
    }

    return false;
  }

  int currentCaloriesPercent(){
    if(!isSetPcl()){
      return 0;
    }

    final res = sumFundamental(FundamentalTypes.calories);
    return (res * 100 / getPlanCalories()!).round();
  }

  bool canEdit(){
    return sendDate == null;
  }

  bool canSend(){
    return sendDate == null && !isEmpty();
  }

  bool isEmpty(){
    return pcl == null || sumFundamental(FundamentalTypes.calories) < 1;
  }

  bool isSetPcl(){
    return pcl != null && pcl!.isNotEmpty;
  }

  int? getPlanProtein(){
    return pcl?['protein'];
  }

  int? getPlanCarbohydrate(){
    return pcl?['carbohydrate'];
  }

  int? getPlanFat(){
    return pcl?['fat'];
  }

  int? getPlanCalories(){
    return pcl?['calories']?? (getPlanProtein()! * 4) + (getPlanCarbohydrate()! * 4) + (getPlanFat()! * 9);
  }

  bool isCurrentReport(FoodDay fd){
    return getCurrentReportDay() == foodDays.indexOf(fd);
  }

  int? getCurrentReportDay(){
    sortChildren();

    for(var idx = 0; idx < foodDays.length; idx++){
      final d = foodDays[idx];

      for(final m in d.mealList){
        for(final s in m.suggestionList){
          if(s.usedMaterialList.isEmpty){
            return idx+1;
          }
        }
      }
    }

    return foodDays.length;
  }

  int? getLastReportDay(){
    sortChildren();

    for(var idx = foodDays.length-1; idx > -1; idx--){
      final d = foodDays[idx];

      for(final m in d.mealList){
        for(final s in m.suggestionList){
          if(s.usedMaterialList.isNotEmpty){
            return idx+1;
          }
        }
      }
    }

    return null;
  }

  @override
  int get hashCode {
    int sum = 0;

    for(final k in foodDays){
      sum += k.hashCode;
    }

    return sum + (title?.hashCode?? 0);
  }

  @override
  FoodProgramModel fromMap(Map<String, dynamic> map) {
    return FoodProgramModel.fromMap(map);
  }
}
