import 'package:iris_tools/api/converter.dart';
import 'package:iris_tools/api/generator.dart';

import '/models/dataModels/foodModels/materialWithValueModel.dart';
import '/models/dataModels/programModels/fundamentalTypes.dart';
import '/system/keys.dart';

class FoodSuggestion {
  late int id;
  String? title;
  int ordering = 1;
  bool isBase = false;
  List<MaterialWithValueModel> materialList = [];
  List<MaterialWithValueModel> usedMaterialList = [];

  FoodSuggestion() : id = Generator.generateIntId(10);

  FoodSuggestion.fromMap(Map map){
    id = map[Keys.id]?? Generator.generateIntId(10);
    ordering = map['ordering']?? 1;
    title = map[Keys.title];
    isBase = map['is_base'];

    final List<Map> materialListL = Converter.correctList<Map>(map['materials'])?? [];
    final List<Map> usedMaterialListL = Converter.correctList<Map>(map['used_materials'])?? [];
    materialList = materialListL.map((e) => MaterialWithValueModel.fromMap(e)).toList();
    usedMaterialList = usedMaterialListL.map((e) => MaterialWithValueModel.fromMap(e)).toList();
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map[Keys.id] = id;
    map[Keys.title] = title;
    map['ordering'] = ordering;
    map['is_base'] = isBase;
    map['materials'] = materialList.map((e) => e.toMap()).toList(growable: false);
    map['used_materials'] = usedMaterialList.map((e) => e.toMap()).toList(growable: false);

    return map;
  }

  List<Map> toMapUsedMaterials(){
    return usedMaterialList.map((e) => e.toMap()).toList(growable: false);
  }

  void copyMaterialsToUsedMaterials(){
    usedMaterialList.clear();
    final maps = materialList.map((e) => e.toMap()).toList();
    usedMaterialList.addAll(maps.map((e) => MaterialWithValueModel.fromMap(e)).toList());
  }

  void matchBy(FoodSuggestion others){
    id = others.id;
    title = others.title;
    ordering = others.ordering;
    materialList = others.materialList;
    usedMaterialList = others.usedMaterialList;
    isBase = others.isBase;
  }

  void reId(){
    id = Generator.generateIntId(10);
  }

  double sumFundamentalValue(String funName){
    var res = 0.0;

    for(final m in materialList){
      /*if(m.material == null){
        continue;
      }*/

      final unit = double.parse(m.material!.measure.unitValue);

      if(m.registerTime != null && m.material!.changes.isNotEmpty) {
        final itm = m.material!.findChangeByDate(funName, m.registerTime!);

        if (itm != null) {
          res += double.parse(itm.fundamental.value?? '0') * m.materialValue ~/ unit;
          continue;
        }
      }

      for (final fun in m.material!.fundamentals) {
        if (fun.key == funName) {
          res += double.parse(fun.value?? '0') * m.materialValue / unit;
        }
      }
    }

    return res;
  }

  double sumFundamental(FundamentalTypes type){
    return sumFundamentalValue(type.name);
  }

  int sumFundamentalInt(FundamentalTypes type){
    return sumFundamental(type).toInt();
  }

  double sumUsedFundamentalValue(String funName){
    var res = 0.0;

    for(final m in usedMaterialList){
      /*if(m.material == null){
        continue;
      }*/

      final unit = double.parse(m.material!.measure.unitValue);

      if(m.registerTime != null && m.material!.changes.isNotEmpty) {
        final itm = m.material!.findChangeByDate(funName, m.registerTime!);

        if (itm != null) {
          res += double.parse(itm.fundamental.value?? '0') * m.materialValue / unit;
          continue;
        }
      }

      for (final fun in m.material!.fundamentals) {
        if (fun.key == funName) {
          res += double.parse(fun.value?? '0') * m.materialValue ~/ unit;
        }
      }
    }

    return res;
  }

  double sumUsedFundamental(FundamentalTypes type){
    return sumUsedFundamentalValue(type.name);
  }

  int sumUsedFundamentalInt(FundamentalTypes type){
    return sumUsedFundamental(type).toInt();
  }

  @override
  int get hashCode {
    int sum = 0;

    for(final k in materialList){
      sum += k.hashCode;
    }

    return sum + id + ordering + (title?.hashCode?? 0) + (isBase.hashCode);
  }

  @override
  String toString() {
    return '(suggestion) > id: $id, ordering: $ordering, name: $title';
  }
}
