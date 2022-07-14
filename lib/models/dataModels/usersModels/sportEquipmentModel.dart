
class SportEquipmentModel {
  String? homeTools;
  String? gymTools;

  SportEquipmentModel();

  SportEquipmentModel.fromMap(Map? map){
    if(map == null){
      return;
    }

    homeTools = map['home_tools'];
    gymTools = map['gym_tools'];
  }

  Map toMap(){
    final map = {};

    map['home_tools'] = homeTools;
    map['gym_tools'] = gymTools;

    return map;
  }

  void matchBy(SportEquipmentModel other){
    homeTools = other.homeTools;
    gymTools = other.gymTools;
  }
}