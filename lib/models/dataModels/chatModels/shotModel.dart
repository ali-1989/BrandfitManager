import 'dart:typed_data';

import '/tools/uriTools.dart';

class ChatMediaShotModel {
  String? uri;
  late int width;
  late int height;
  //------------------ local
  Uint8List? screenshotBytes;

  ChatMediaShotModel();

  ChatMediaShotModel.fromMap(Map map, {String? domain}){
    uri = map['uri'];
    width = map['width']?? 0;
    height = map['height']?? 0;

    uri = UriTools.correctAppUrl(uri, domain: domain);
  }

  Map toMap(){
    final map = {};
    map['uri'] = uri;
    map['width'] = width;
    map['height'] = height;

    return map;
  }

  void matchBy(ChatMediaShotModel other){
    uri ??= other.uri;
  }
}