import 'package:iris_tools/dateSection/dateHelper.dart';

import '/managers/foodMaterialManager.dart';
import '/models/dataModels/foodModels/materialModel.dart';

class MaterialWithValueModel {
  late int _materialId;
  int materialValue = 0;
  String? unit;
  DateTime? registerTime;

  //---------------- local
  MaterialModel? _material;

  MaterialWithValueModel();

  MaterialWithValueModel.fromMap(Map map){
    _materialId = map['material_id']?? 0;
    materialValue = map['value'];
    unit = map['unit'];
    registerTime = DateHelper.tsToSystemDate(map['register_time']);

    //---------------- local
    _material = FoodMaterialManager.getById(_materialId);
    //MaterialModel.fromMap(map['material']);
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map['material_id'] = _materialId;
    map['value'] = materialValue;
    map['unit'] = unit;
    map['register_time'] = DateHelper.toTimestampNullable(registerTime);

    if(_material != null) {
      FoodMaterialManager.addItem(_material!);
    }

    return map;
  }

  void matchBy(MaterialWithValueModel others){
    _materialId = others._materialId;
    materialValue = others.materialValue;
    unit = others.unit;
    registerTime = others.registerTime;


    _material = others._material;
  }

  MaterialModel? get material => _material;
  int get materialId => _materialId;

  set material (MaterialModel? mat){
    _material = mat;
    _materialId = mat?.id?? 0;

    setRegisterTime();
  }

  void setRegisterTime({DateTime? dt}){
    registerTime = dt?? DateTime.now().toUtc();
  }

  @override
  int get hashCode {
    return _materialId + materialValue + (unit?.hashCode?? 0) + (registerTime?.millisecondsSinceEpoch?? 0);
  }
}
