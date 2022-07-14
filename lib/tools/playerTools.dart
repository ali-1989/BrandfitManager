import 'package:flutter_audio_recorder2/flutter_audio_recorder2.dart';
import 'package:just_audio/just_audio.dart';

import '/managers/settingsManager.dart';

class PlayerTools {
  PlayerTools._();

  static late FlutterAudioRecorder2 audioRecorder;
  static late AudioPlayer _notifyPlayer;
  static late AudioPlayer _chatMessageSendPlayer;
  static late AudioPlayer audioDurationGet;
  static late AudioPlayer chatAudioPlayer;

  static void init(){
    audioDurationGet = AudioPlayer();
    chatAudioPlayer = AudioPlayer();

    _notifyPlayer = AudioPlayer();
    _notifyPlayer.setAsset('assets/audio/graceful.mp3', preload: true);

    _chatMessageSendPlayer = AudioPlayer();
    _chatMessageSendPlayer.setAsset('assets/audio/intuition.mp3', preload: true);
  }

  static Future playNotificationForce() async {
    if(!_notifyPlayer.playing){
      return _notifyPlayer.play().then((value) async {
        await _notifyPlayer.stop();
        return _notifyPlayer.seek(Duration());
      });
    }
  }

  static Future playChatMessageSendForce() async {
    if(!_chatMessageSendPlayer.playing){
      return _chatMessageSendPlayer.play().then((value) async {
        await _chatMessageSendPlayer.stop();
        return _chatMessageSendPlayer.seek(Duration());
      });
    }
  }

  static Future playChatMessageSend() async {
    if(SettingsManager.settingsModel.chatNotification){
      return playChatMessageSendForce();
    }
  }

  static Future playNotification() async {
    if(SettingsManager.settingsModel.appNotification){
      return playNotificationForce();
    }
  }
}
