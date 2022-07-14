import 'dart:io';

import 'package:iris_sound_player/soundPlayer/track.dart';

import '/models/dataModels/chatModels/shotModel.dart';
import '/system/enums.dart';
import '/system/keys.dart';
import '/tools/centers/directoriesCenter.dart';
import '/tools/uriTools.dart';

class ChatMediaModel {
  BigInt? id;
  BigInt? groupId; // for image gallery
  int msgType = 0;
  String? extension;
  String? name;
  int? width;
  int? height;
  int volume = 0;
  Duration? duration;
  Map? extraJs;
  String? uri;
  ChatMediaShotModel? screenshotModel;
  //-------------- local
  bool isDraft = false;
  bool isDownloaded = false;
  bool isBroken = false;
  Track? audioTrack;
  String? mediaPath;
  String? screenshotPath;

  ChatMediaModel();

  bool get isPortland => width != null && height != null && height! > width!;

  ChatMediaModel.fromMap(Map map, {String? domain}){
    final gi = map['group_id'];
    final dur = map['duration'];
    final screenshotJs = map['screenshot_js'];

    id = BigInt.parse(map[Keys.id]);
    msgType = map['message_type'];
    groupId = gi == null? null : BigInt.parse(gi);
    extension = map['extension'];
    name = map['name'];
    width = map['width'];
    height = map['height'];
    volume = map['volume']?? 0;
    duration = dur != null ? Duration(milliseconds: dur) : null;
    extraJs = map['extra_js'];
    uri = map['uri'];
    screenshotModel = screenshotJs != null? ChatMediaShotModel.fromMap(screenshotJs, domain: domain): null;

    uri = UriTools.correctAppUrl(uri, domain: domain);
    //---------------- local
    mediaPath = map['file_path'];
    screenshotPath = map['screenshot_path'];
  }

  Map toMap(){
    final map = {};

    map['id'] = id!.toString();
    map['message_type'] = msgType;
    map['group_id'] = groupId;
    map['extension'] = extension;
    map['name'] = name;
    map['width'] = width;
    map['height'] = height;
    map['volume'] = volume;
    map['duration'] = duration != null ? duration!.inMilliseconds: null;
    map['extra_js'] = extraJs;
    map['uri'] = uri;
    map['screenshot_js'] = screenshotModel?.toMap();

    //---------------- local
    map['screenshot_path'] = screenshotPath;
    map['file_path'] = mediaPath;

    return map;
  }

  void matchBy(ChatMediaModel other){
    id = other.id;
    msgType = other.msgType;
    groupId = other.groupId;
    extension = other.extension;
    name = other.name;
    width = other.width;
    height = other.height;
    volume = other.volume;
    duration = other.duration;
    extraJs = other.extraJs;
    uri = other.uri;

    if(screenshotModel == null){
      screenshotModel = other.screenshotModel;
    }
    else {
      if(other.screenshotModel != null){
        screenshotModel!.matchBy(other.screenshotModel!);
      }
    }

    //---------------- local
    mediaPath ??= other.mediaPath;
    screenshotPath ??= other.screenshotPath;
  }

  void prepareMediaPath(bool force) async {
    if(!force && mediaPath != null){
      return;
    }

    if(msgType == ChatType.AUDIO.typeNum) {
      mediaPath = DirectoriesCenter.getSavePathUri(uri, SavePathType.CHAT_AUDIO);
    }

    else if(msgType == ChatType.VIDEO.typeNum) {
      mediaPath = DirectoriesCenter.getSavePathUri(uri, SavePathType.CHAT_VIDEO);
    }

    else if(msgType == ChatType.IMAGE.typeNum) {
      mediaPath = DirectoriesCenter.getSavePathUri(uri, SavePathType.CHAT_IMAGE);
    }

    else {
      mediaPath = DirectoriesCenter.getSavePathUri(uri, SavePathType.CHAT_FILE);
    }
  }

  void prepare() {
    prepareMediaPath(false);

    final f = File(mediaPath!);
    final exist = f.existsSync();

    if(exist){
      final len = f.lengthSync();

      if(volume > 0 && len >= volume) {
        isDownloaded = true;
      }
    }

    if(msgType == ChatType.AUDIO.typeNum){
      if(isDownloaded) {
        audioTrack ??= Track.fromFile(mediaPath!);
      }
      /*else {
        audioTrack = Track.fromURL(uri!);
      }*/
    }

    if(isDraft && !isDownloaded){
      isBroken = true;
    }
  }

  Future<bool> existMediaFile() async {
    if(mediaPath == null){
      return false;
    }

    final f = File(mediaPath!);
    return await f.exists();
  }

  Future<bool> existScreenshotFile() async {
    if(screenshotPath == null){
      return false;
    }

    final f = File(screenshotPath!);
    return await f.exists();
  }
}
