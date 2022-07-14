import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:chewie/chewie.dart';
import 'package:iris_tools/modules/stateManagers/refresh.dart';
import 'package:video_player/video_player.dart';

import '/tools/app/appNavigator.dart';
import '/tools/app/appThemes.dart';
import '/views/preWidgets.dart';

enum VideoSourceType {
  file,
  network,
  bytes,
  asset
}
///==================================================================================================
class VideoPlayerView extends StatefulWidget {
  final VideoSourceType videoSourceType;
  final String srcAddress;
  final String heroTag;
  final String? info;
  final TextStyle? infoStyle;

  VideoPlayerView({
    Key? key,
    this.videoSourceType = VideoSourceType.file,
    required this.srcAddress,
    required this.heroTag,
    this.info,
    this.infoStyle,
  })
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return VideoPlayerViewState();
  }
}
///==================================================================================================
class VideoPlayerViewState extends State<VideoPlayerView> {
  VideoPlayerController? playerController;
  ChewieController? chewieVideoController;
  bool isVideoInit = false;
  TextStyle? infoStyle;
  VideoInformation? videoInfo;

  @override
  void initState() {
    super.initState();

    infoStyle = widget.infoStyle?? const TextStyle(color: Colors.white);
    _init();
  }

  @override
  Widget build(BuildContext context) {
    final param = AppNavigator.getArgumentsOf(context);

    if(param is VideoInformation) {
      videoInfo = param;
    }

    videoInfo ??= VideoInformation();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: playerController?.value.aspectRatio?? 16/10,
              child: Hero(
                  tag: widget.heroTag,
                  child: isVideoInit?
                      Chewie(controller: chewieVideoController!,)
                      : PreWidgets.flutterLoadingWidget$Center()
              ),
            ),
          ),

          if(widget.info != null)
          Positioned(
              bottom: 0, left: 0, right: 0,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                    color: Colors.transparent, //AppThemes.currentTheme.inactiveTextColor.withAlpha(200),
                    //borderRadius: BorderRadius.circular(8.0)
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        overflow: TextOverflow.fade,
                        maxLines: 6,
                          text: TextSpan(
                            text: widget.info,
                            style: infoStyle,
                          ),
                      ),
                    ],
                  ),
                ),
              )
          ),
        ]
      ),
    );
  }

  @override
  void dispose() {
    chewieVideoController?.dispose();
    playerController?.dispose();

    super.dispose();
  }

  void update(){
    if(mounted){
      setState(() {});
    }
  }

  void _init(){
    switch(widget.videoSourceType){
      case VideoSourceType.file:
        playerController = VideoPlayerController.file(File(widget.srcAddress));
        break;
      case VideoSourceType.network:
        playerController = VideoPlayerController.network(widget.srcAddress);
        break;
      case VideoSourceType.bytes:
        break;
      case VideoSourceType.asset:
        playerController = VideoPlayerController.asset(widget.srcAddress);
        break;
    }

    playerController!.initialize().then((value) {
      isVideoInit = playerController!.value.isInitialized;
      _onVideoInit();
    });
  }

  void _onVideoInit(){

    chewieVideoController = ChewieController(
      videoPlayerController: playerController!,
      autoPlay: true,
      allowFullScreen: false,
      allowedScreenSleep: false,
      allowPlaybackSpeedChanging: true,
      allowMuting: true,
      autoInitialize: true,
      fullScreenByDefault: false,
      looping: false,
      isLive: false,
      showControls: true,
      showControlsOnInitialize: true,
      placeholder: PreWidgets.flutterLoadingWidget$Center(),
      materialProgressColors: ChewieProgressColors(handleColor: AppThemes.currentTheme.differentColor,
          playedColor: AppThemes.currentTheme.differentColor,
          backgroundColor: Colors.green, bufferedColor: AppThemes.currentTheme.primaryColor),
    );

    //int w = playerController!.value.size.width.toInt(); //?? 440
    //int h = playerController!.value.size.height.toInt(); //?? 260

    update();
  }
}
///==================================================================================================
class VideoInformation {
  late int id;
  late int creatorId;
  late String name;
  String? caption;
  late String extension;
  String? registerDate;
  late String url;
  int type = 0;
  int volume = 0;
  int width = 0;
  int height = 0;
  Uint8List? preView;
  Map<String, dynamic>? extraInfo;

  String? creatorUserName;
  String? downloadItemId;
  bool isDownloaded = false;
  String? savedPath;
  Duration? duration;
  RefreshController? viewUpdater;

/*updateToMap(Map<String, dynamic> myMap){
    myMap['Id'] = id;
    myMap['Name'] = name;
    myMap['Caption'] = caption;
    myMap['Extension'] = extension;
    myMap['Type'] = type;
    myMap['Volume'] = volume;
    myMap['Width'] = width;
    myMap['Height'] = height;
    myMap['ExtraInfo'] = JsonHelper.mapToJson(extraInfo);
  }*/
}
///==================================================================================================
