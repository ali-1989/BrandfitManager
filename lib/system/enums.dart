
enum SavePathType {
  USER_PROFILE,
  ADVERTISING,
  BODY_PHOTO,
  VOICE_REC,
  COURSE_PHOTO,
  CHAT_AUDIO,
  CHAT_VIDEO,
  CHAT_IMAGE,
  CHAT_FILE,
}
///===============================================================================================
enum ImageType {
  File,
  Bytes,
  Asset
}
///===============================================================================================
/// 0 unKnown(file), 1 text, 2 audio, 3 video, 4 image, 5 gif/anim, 6 pdf/pub,
/// 7 html, 8 YouTubes, 9 Contact, 10 Location
enum ChatType {
  FILE,
  TEXT,
  AUDIO,
  VIDEO,
  IMAGE,
  PDF,
  HTML,
  YOUTUBE
}

extension ChatTypeExtension on ChatType {

  int get typeNum {
    switch (this) {
      case ChatType.FILE:
        return 0;
      case ChatType.TEXT:
        return 1;
      case ChatType.AUDIO:
        return 2;
      case ChatType.VIDEO:
        return 3;
      case ChatType.IMAGE:
        return 4;
      case ChatType.PDF:
        return 6;
      case ChatType.HTML:
        return 7;
      case ChatType.YOUTUBE:
        return 8;
      default:
        return 0;
    }
  }

  ChatType byNum(int num){
    switch(num) {
      case 1:
        return ChatType.TEXT;
      case 2:
        return ChatType.AUDIO;
      case 3:
        return ChatType.VIDEO;
      case 4:
        return ChatType.IMAGE;
      case 6:
        return ChatType.PDF;
      case 7:
        return ChatType.HTML;
      case 8:
        return ChatType.YOUTUBE;
      default:
        return ChatType.FILE;
    }
  }
}
///===============================================================================================

/*
extension NodeNamesEx on NodeNames {
  NodeNames? byName(String name){
    for(var i in NodeNames.values){
      if(i.name == name){
        return i;
      }
    }
  }
}
* */