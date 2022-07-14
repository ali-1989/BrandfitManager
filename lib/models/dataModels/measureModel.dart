class MeasureModel {
  late String _name;
  late String _unit;

  MeasureModel(String name, String unit) {
    _name = name;
    _unit = unit;
  }

  String get name => _name;
  String get unit => _unit;

  static MeasureModel unKnow = MeasureModel('unKnow', '-');
  static MeasureModel weight = MeasureModel('weight', 'kg');
  static MeasureModel length = MeasureModel('length', 'cm');
}