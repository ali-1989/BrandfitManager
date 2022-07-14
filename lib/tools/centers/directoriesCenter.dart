import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';
import 'package:iris_tools/api/helpers/pathHelper.dart';
import 'package:iris_tools/api/helpers/storageHelper.dart';
import 'package:iris_tools/api/system.dart';
import 'package:permission_handler/permission_handler.dart';

import '/system/enums.dart';
import '/tools/permissionTools.dart';

class DirectoriesCenter {
  DirectoriesCenter._();

  static String _externalStorage = '/';
  static String _documentDir = '/';
  static String _appName = 'app';

  static String? getSavePathUri(String? uri, SavePathType type){
    if(uri == null){
      return null;
    }

    if(type == SavePathType.USER_PROFILE){
      final pat = DirectoriesCenter.getAvatarDir$ex();
      final serverName = PathHelper.getFileName(uri);
      return PathHelper.resolvePath(pat + PathHelper.getSeparator() + serverName);
    }

    if(type == SavePathType.BODY_PHOTO){
      final pat = DirectoriesCenter.getBodyPhotoDir$ex();
      final serverName = PathHelper.getFileName(uri);
      return PathHelper.resolvePath(pat + PathHelper.getSeparator() + serverName);
    }

    if(type == SavePathType.ADVERTISING){
      final pat = DirectoriesCenter.getAdvertisingDir$ex();
      final serverName = PathHelper.getFileName(uri);
      return PathHelper.resolvePath(pat + PathHelper.getSeparator() + serverName);
    }

    if(type == SavePathType.COURSE_PHOTO){
      final pat = DirectoriesCenter.getCourseDir$ex();
      final serverName = PathHelper.getFileName(uri);
      return pat + PathHelper.getSeparator() + serverName;
    }

    if(type == SavePathType.CHAT_AUDIO){
      final pat = DirectoriesCenter.getAudioDir$ex();
      final serverName = PathHelper.getFileName(uri);
      return pat + PathHelper.getSeparator() + serverName;
    }

    if(type == SavePathType.CHAT_VIDEO){
      final pat = DirectoriesCenter.getVideoDir$ex();
      final serverName = PathHelper.getFileName(uri);
      return pat + PathHelper.getSeparator() + serverName;
    }

    if(type == SavePathType.CHAT_IMAGE){
      final pat = DirectoriesCenter.getImageDir$ex();
      final serverName = PathHelper.getFileName(uri);
      return pat + PathHelper.getSeparator() + serverName;
    }

    if(type == SavePathType.CHAT_FILE){
      final pat = DirectoriesCenter.getDocDir$ex();
      final serverName = PathHelper.getFileName(uri);
      return pat + PathHelper.getSeparator() + serverName;
    }

    return null;
  }

  static String? getSavePathByPath(SavePathType type, String? filepath){

    if(type == SavePathType.USER_PROFILE){
      final pat = DirectoriesCenter.getAvatarDir$ex();
      var fName = Generator.generateDateMillWithKey(14);

      if(filepath != null){
        final ext = FileHelper.getDotExtensionForce(filepath, '.jpg');
        fName += ext;
      }
      else {
        fName += '.jpg';
      }

      return pat + PathHelper.getSeparator() + fName;
    }

    if(type == SavePathType.ADVERTISING){
      final pat = DirectoriesCenter.getAdvertisingDir$ex();
      var fName = Generator.generateDateMillWithKey(14);

      if(filepath != null){
        final ext = FileHelper.getDotExtensionForce(filepath, '.jpg');
        fName += ext;
      }
      else {
        fName += '.jpg';
      }

      return pat + PathHelper.getSeparator() + fName;
    }

    if(type == SavePathType.COURSE_PHOTO){
      final pat = DirectoriesCenter.getCourseDir$ex();
      var fName = Generator.generateDateMillWithKey(14);

      if(filepath != null){
        final ext = FileHelper.getDotExtensionForce(filepath, '.jpg');
        fName += ext;
      }
      else {
        fName += '.jpg';
      }

      return pat + PathHelper.getSeparator() + fName;
    }

    if(type == SavePathType.BODY_PHOTO){
      final pat = DirectoriesCenter.getBodyPhotoDir$ex();
      var fName = Generator.generateDateMillWithKey(14);

      if(filepath != null){
        final ext = FileHelper.getDotExtensionForce(filepath, '.jpg');
        fName += ext;
      }
      else {
        fName += '.jpg';
      }

      return pat + PathHelper.getSeparator() + fName;
    }

    if(type == SavePathType.VOICE_REC){
      final pat = DirectoriesCenter.getAudioDir$ex();
      var fName = Generator.generateDateMillWithKey(12);
      var ext = '.aac';

      if(filepath != null){
        ext = FileHelper.getDotExtensionForce(filepath, ext);
      }

      fName += ext;

      return pat + PathHelper.getSeparator() + fName;
    }

    if(type == SavePathType.CHAT_IMAGE){
      final pat = DirectoriesCenter.getImageDir$ex();
      var fName = Generator.generateDateMillWithKey(12);
      var ext = '.png';

      if(filepath != null){
        ext = FileHelper.getDotExtensionForce(filepath, ext);
      }

      fName += ext;

      return pat + PathHelper.getSeparator() + fName;
    }

    return null;
  }

  // status == PermissionStatus.granted
  static Future<PermissionStatus> checkStoragePermission() async{
    return PermissionTools.requestStoragePermission();
  }
  ///-----------------------------------------------------------------------------------------
  static Future<String> prepareStoragePaths(String appName) async {
    _appName = appName;

    if (kIsWeb) {
      _externalStorage = StorageHelper.getWebExternalStorage();
    } else if (Platform.isAndroid) {
      _externalStorage = (await StorageHelper.getAndroidExternalStorage())!;
    } else if (Platform.isIOS) {
      _externalStorage = (await StorageHelper.getIosApplicationSupportDir()).path;
    } else {
      _externalStorage = '/';
    }

    final p = await StorageHelper.getDocumentsDirectory$external();
    _documentDir = p + PathHelper.getSeparator() + _appName;

    return _externalStorage;
  }

  static String getExternalStorage() {
    return _externalStorage;
  }

  // android: /storage/emulated/0/Documents/appName
  // iOS:
  static String getDocumentsDirectory() {
    return _documentDir;
  }

  static String getAppFolderInExternalStorage() {
    return _externalStorage + PathHelper.getSeparator() + _appName;
  }

  static Future<String> getDatabasesDir() async {
    if(System.isWeb()) {
      return StorageHelper.getWebExternalStorage() + PathHelper.getSeparator() + 'database';
    }

    if(System.isAndroid()) {
      return (await StorageHelper.getAppDirectory$internal()).path + PathHelper.getSeparator() + 'database';
    }

    if(System.isIOS()) {
      return (await StorageHelper.getAppDirectory$internal()).path + PathHelper.getSeparator() + 'database';
    }

    return StorageHelper.getWebExternalStorage() + PathHelper.getSeparator() + 'database';
  }

  static String getTempFile({String? name, String? extension}){
    name ??= Generator.generateDateMillWithKey(4);

    if(extension != null) {
      return getTempDir$ex()+ PathHelper.getSeparator() + name + '.$extension';
    } else {
      return getTempDir$ex()+ PathHelper.getSeparator() + name;
    }
  }

  static String getScreenshotFile({String? name, String? extension}){
    name ??= Generator.generateDateMillWithKey(4);

    if(extension != null) {
      return getVideoDir$ex()+ PathHelper.getSeparator() + name + '.$extension';
    } else {
      return getVideoDir$ex()+ PathHelper.getSeparator() + name;
    }
  }
  ///================================================================================================
  // /storage/emulated/0/appName/tmp
  static String getTempDir$ex(){
    return getAppFolderInExternalStorage() + PathHelper.getSeparator() + 'tmp';
  }

  static String getAvatarDir$ex() {
    return getAppFolderInExternalStorage() + PathHelper.getSeparator() + 'avatar';
  }

  static String getAdvertisingDir$ex(){
    return getAppFolderInExternalStorage() + PathHelper.getSeparator() + 'advertising';
  }

  static String getMediaDir$ex() {
    return getAppFolderInExternalStorage() + PathHelper.getSeparator() + 'media';
  }

  static String getAudioDir$ex() {
    return getMediaDir$ex() + PathHelper.getSeparator() + 'audio';
  }

  static String getVideoDir$ex() {
    return getMediaDir$ex() + PathHelper.getSeparator() + 'video';
  }

  static String getImageDir$ex() {
    return getMediaDir$ex() + PathHelper.getSeparator() + 'image';
  }

  static String getDocDir$ex() {
    return getMediaDir$ex() + PathHelper.getSeparator() + 'document';
  }

  static String getCourseDir$ex() {
    return getAppFolderInExternalStorage() + PathHelper.getSeparator() + 'Course';
  }

  static String getBodyPhotoDir$ex(){
    return getMediaDir$ex() + PathHelper.getSeparator() + 'body photos';
  }

  static Future<bool> generateNoMediaFile() async {
    if(System.isWeb()) {
      return true;
    }

    final x = await checkStoragePermission();

    if(x != PermissionStatus.granted) {
      return false;
    }

    final tmpDir = getTempDir$ex();
    var f = FileHelper.getFile(tmpDir + PathHelper.getSeparator() + '.nomedia');
    await f.create(recursive: true);

    final avatarDir = getAvatarDir$ex();
    f = FileHelper.getFile(avatarDir + PathHelper.getSeparator() + '.nomedia');
    await f.create(recursive: true);

    final advertisingDir = getAdvertisingDir$ex();
    f = FileHelper.getFile(advertisingDir + PathHelper.getSeparator() + '.nomedia');
    await f.create(recursive: true);

    final contentDir = getMediaDir$ex();
    f = FileHelper.getFile(contentDir + PathHelper.getSeparator() + '.nomedia');
    await f.create(recursive: true);

    final bodyPhotoDir = getBodyPhotoDir$ex();
    f = FileHelper.getFile(bodyPhotoDir + PathHelper.getSeparator() + '.nomedia');
    await f.create(recursive: true);

    final courseDir = getCourseDir$ex();
    f = FileHelper.getFile(courseDir + PathHelper.getSeparator() + '.nomedia');
    await f.create(recursive: true);

    return true;
  }
}
