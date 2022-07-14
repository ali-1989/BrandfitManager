import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:blur_preview/blurHash/blurHash.dart';
import 'package:iris_tools/api/helpers/imageHelper.dart';
import 'package:iris_tools/api/helpers/imageHelperImagePkg.dart';
import 'package:iris_tools/api/helpers/mediaHelper.dart';
import 'package:iris_tools/api/helpers/mimeHelper.dart';

import '/managers/settingsManager.dart';

//import 'package:video_thumbnail/video_thumbnail.dart' show ImageFormat;


enum ImageState {
  square,
  landscape,
  portland
}
///==============================================================================================
class MediaTools {
  MediaTools._();

  static ImageState getImageOrientation(int w, int h){
    if((w - h).abs() < 16){
      return ImageState.square;
    }

    if(w > h){
      return ImageState.landscape;
    }

    return ImageState.portland;
  }

  static Future<bool> isImage(String path) async {
    final mime = await MimeHelper.getFileMimeFromMagic(path);
    return MimeHelper.isImageByMime(mime);
  }

  static Future<ImageAttribute> getImageAttribute(String filePath) async {
    final att = ImageAttribute();
    final f = File(filePath);
    final fb = await f.readAsBytes();

    final buffer = await ui.ImmutableBuffer.fromUint8List(fb);
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    final orgW = descriptor.width;
    final orgH = descriptor.height;
    descriptor.dispose();

    var img = ImageHelperImagePkg.bytesToImage(fb);
    final imgState = getImageOrientation(orgW, orgH);

    var newW = SettingsManager.maxViewWidth; //380
    var newH = SettingsManager.maxViewWidth;

    if(imgState == ImageState.landscape){
      newH = SettingsManager.maxViewHeightL;
    }
    else if(imgState == ImageState.portland){
      newH = SettingsManager.maxViewHeightP; //460
    }
    var point = ImageHelper.getScaledDimension(orgW, orgH, newW, newH);
    img = ImageHelperImagePkg.resize$image(img!, newWidth: point.x, newHeight: point.y);

    att.width = point.x;
    att.height = point.y;
    att.volume = img.length;

    newW = SettingsManager.maxCoverWidth; //240
    newH = SettingsManager.maxCoverWidth;

    if(imgState == ImageState.landscape){
      newH = SettingsManager.maxCoverHeightL; //180
    }
    else if(imgState == ImageState.portland){
      newH = SettingsManager.maxCoverHeightP; //300
    }

    point = ImageHelper.getScaledDimension(att.width!, att.height!, newW, newH);
    var cover = ImageHelperImagePkg.resize$image(img, newWidth: point.x, newHeight: point.y);

    cover = ImageHelperImagePkg.gaussianBlur$image(cover, 12);
    att.blurHash = BlurHash.encodeImage(cover).hash;

    return att;
  }

  static Future<ImageAttribute> getImageAttribute2(String filePath) async {
    final att = ImageAttribute();
    final f = File(filePath);
    final fb = await f.readAsBytes();

    final dim = await ImageHelper.getImageDimByBytesB(fb);
    final orgW = dim.x.toInt();
    final orgH = dim.y.toInt();

    final imgState = getImageOrientation(orgW, orgH);
    var newW = SettingsManager.maxViewWidth; //380
    var newH = SettingsManager.maxViewWidth;

    if(imgState == ImageState.landscape){
      newH = SettingsManager.maxViewHeightL;
    }
    else if(imgState == ImageState.portland){
      newH = SettingsManager.maxViewHeightP; //460
    }

    var point = ImageHelper.getScaledDimension(orgW, orgH, newW, newH);
    final img = await ImageHelper.resizeBytesAsRgba(fb, newWidth: point.x, newHeight: point.y);

    att.newPicture = await ImageHelper.rgbaToPng(img, point.x, point.y);
    att.width = point.x;
    att.height = point.y;
    att.volume = att.newPicture!.lengthInBytes;

    newW = SettingsManager.maxCoverWidth; //240
    newH = SettingsManager.maxCoverWidth;

    if(imgState == ImageState.landscape){
      newH = SettingsManager.maxCoverHeightL; //180
    }
    else if(imgState == ImageState.portland){
      newH = SettingsManager.maxCoverHeightP; //300
    }

    point = ImageHelper.getScaledDimension(att.width!, att.height!, newW, newH);

    final cover = await ImageHelper.resizeRgbaToRgba(img, width: att.width!, height: att.height!, newWidth: point.x, newHeight: point.y);
    /*var cover = await ImageHelper.resizeRgbaAsImage(img.buffer.asUint8List(), width: att.width!, height: att.height!, newWidth: point.x, newHeight: point.y);
    cover = await ImageHelper.blurImage(cover, sigma: 4);
    var coverRgb = await ImageHelper.imageToRgba(cover);*/

    final hash = BlurHash.encode(cover, point.x, point.y, numCompX: 4, numCompY: 4);
    att.blurHash = hash.hash;

    return att;
  }

  static Future<VideoAttribute> getVideoAttribute(String filePath) async {
    final att = VideoAttribute();
    final info = await MediaHelper.getLocalVideoInfo(filePath);
    att.width = info.width!;
    att.height = info.height!;
    att.duration = Duration( milliseconds: info.duration!.toInt());
    att.volume = info.filesize;

    final imgState = getImageOrientation(att.width!, att.height!);
    var newW = SettingsManager.maxViewWidth; //380
    var newH = SettingsManager.maxViewWidth;

    if(imgState == ImageState.landscape){
      newH = SettingsManager.maxViewHeightL;
    }
    else if(imgState == ImageState.portland){
      newH = SettingsManager.maxViewHeightP; //460
    }

    var point = ImageHelper.getScaledDimension(att.width!, att.height!, newW, newH);
    att.shotWidth = point.x;
    att.shotHeight = point.y;

    att.shotBytes = await MediaHelper.screenshotVideo(filePath);
    final img = await ImageHelper.resizeBytesAsRgba(att.shotBytes!, newWidth: point.x, newHeight: point.y);

    newW = SettingsManager.maxCoverWidth; //240
    newH = SettingsManager.maxCoverWidth;

    if(imgState == ImageState.landscape){
      newH = SettingsManager.maxCoverHeightL; //180
    }
    else if(imgState == ImageState.portland){
      newH = SettingsManager.maxCoverHeightP; //300
    }

    point = ImageHelper.getScaledDimension(att.width!, att.height!, newW, newH);
    final img2 = await ImageHelper.resizeRgbaAsImage(img, width: att.shotWidth!, height: att.shotHeight!, newWidth: point.x, newHeight: point.y);

    final cover = await ImageHelper.blurImage(img2, sigma: 4);
    final coverRgb = await ImageHelper.imageToRgba(cover);

    att.blurHash = BlurHash.encode(coverRgb!, point.x, point.y).hash;

    return att;
  }
}
///===================================================================================
class ImageAttribute {
  int? width;
  int? height;
  int? volume;
  Uint8List? newPicture;
  String? blurHash;
}

class VideoAttribute {
  int? width;
  int? height;
  int? shotWidth;
  int? shotHeight;
  int? volume;
  Duration? duration;
  String? blurHash;
  Uint8List? shotBytes;
}
