
class MaterialMeasureModel {
  late String unit;
  late String unitValue;

  MaterialMeasureModel();

  MaterialMeasureModel.fromMap(Map map){
    unit = map['unit'];
    unitValue = map['unit_value'];
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map['unit'] = unit;
    map['unit_value'] = unitValue;

    return map;
  }
}
///================================================================================================
enum MeasureUnits {
  gram,
  milLitre,
}