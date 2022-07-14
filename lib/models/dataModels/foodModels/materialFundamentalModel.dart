
// calories, fat, protein, carbohydrate, ...

import '/system/keys.dart';

class MaterialFundamentalModel {
  late String key;
  String? value;

  MaterialFundamentalModel();

  MaterialFundamentalModel.fromMap(Map map){
    key = map[Keys.key];
    value = map[Keys.value];
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map[Keys.key] = key;
    map[Keys.value] = value?? 0;

    return map;
  }
}