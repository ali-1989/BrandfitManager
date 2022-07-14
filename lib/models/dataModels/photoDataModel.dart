import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/pathHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import '/system/enums.dart';
import '/system/keys.dart';
import '/tools/centers/directoriesCenter.dart';
import '/tools/uriTools.dart';

class PhotoDataModel {
  late String id;
  DateTime? utcDate;
  String? uri;
  int order = 0;
  String? description;
  //--------------- local
  String? localPath;

  PhotoDataModel() : id = Generator.generateName(14);

  PhotoDataModel.fromMap(Map? map, {String? domain}){
    if(map == null){
      id = Generator.generateName(14);
      return;
    }

    id = map[Keys.id]?? Generator.generateName(14);
    utcDate = DateHelper.tsToSystemDate(map[Keys.date]); //is utc
    uri = map[Keys.imageUri];
    order = map[Keys.orderNum]?? 0;
    description = map[Keys.description];

    uri = UriTools.correctAppUrl(uri, domain: domain);
  }

  Map toMap(){
    final map = {};

    map[Keys.id] = id;
    map[Keys.date] = DateHelper.toTimestampNullable(utcDate);
    map[Keys.imageUri] = uri;
    map[Keys.orderNum] = order;
    map[Keys.description] = description;

    return map;
  }

  void correctUri(){
    if(uri != null){
      UriTools.correctAppUrl(uri);
    }
  }

  String? genPath([String? dir]) {
    if (dir == null) {
      if (uri != null) {
        final path = DirectoriesCenter.getSavePathUri(uri, SavePathType.COURSE_PHOTO);
        return PathHelper.resolvePath(path);
      }

      return DirectoriesCenter.getSavePathUri('c$id.jpg', SavePathType.COURSE_PHOTO);
    }
    else {
      var fileName = 'c$id.jpg';

      if (uri != null) {
        fileName = PathHelper.getFileName(uri!);
      }

      dir += PathHelper.getSeparator() + fileName;
      return PathHelper.resolvePath(dir);
    }
  }

  String? getPath(){
    if(localPath != null){
      return localPath;
    }

    return genPath();
  }
  @override
  String toString() {
    return '$uri , ${getPath()} , date:$utcDate';
  }

  static void sort(List<PhotoDataModel> list, {bool asc = true}){
    list.sort((PhotoDataModel p1, PhotoDataModel p2){
      final d1 = p1.utcDate;
      final d2 = p2.utcDate;

      if(d1 == null){
        return asc? 1: 1;
      }

      if(d2 == null){
        return asc? 1: 1;
      }

      return asc? d1.compareTo(d2) : d2.compareTo(d1);
    });
  }
}
