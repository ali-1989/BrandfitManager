import 'package:iris_tools/api/generator.dart';

abstract class IProgramModel {
  late int id;
  late int trainerId;
  late int requestId;
  String? title;
  DateTime? registerDate;
  DateTime? cronDate;
  DateTime? sendDate;
  DateTime? pupilSeeDate;

  IProgramModel() : id = Generator.generateIntId(14);
}