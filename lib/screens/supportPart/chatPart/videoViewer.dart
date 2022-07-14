import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

import '/system/icons.dart';
import '/tools/app/appNavigator.dart';
import '/tools/app/appThemes.dart';
import '/views/preWidgets.dart';

enum VideoSourceType {
  File,
  Network,
  Bytes,
  Asset
}
///==================================================================================================
class VideoViewer extends StatefulWidget {
  final VideoSourceType videoSourceType;
  final String srcAddress;
  final String? info;

  VideoViewer({
    Key? key,
    this.videoSourceType = VideoSourceType.File,
    required this.srcAddress,
    this.info,
  })
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return VideoViewerState();
  }
}
///==================================================================================================
class VideoViewerState extends State<VideoViewer> {
  VideoPlayerController? playerController;
  ChewieController? chewieVideoController;
  bool isVideoInit = false;
  VideoInformation? videoInfo;

  @override
  void initState() {
    super.initState();

    _init();
  }

  @override
  Widget build(BuildContext context) {
    var param = AppNavigator.getArgumentsOf(context);
    
    if(param is VideoInformation) {
      videoInfo = param;
    }

    videoInfo ??= VideoInformation();
    
    return Scaffold(
      backgroundColor: Colors.black,
      //appBar: AppBar(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: playerController?.value.aspectRatio?? 16/10,
              child: isVideoInit?
                  Chewie(controller: chewieVideoController!,)
                  : PreWidgets.flutterLoadingWidget$Center(),
            ),
          ),

          if(widget.info != null)
          Positioned(
              bottom: 0, left: 0, right: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: Colors.transparent, //AppThemes.currentTheme.inactiveTextColor.withAlpha(200),
                    //borderRadius: BorderRadius.circular(8.0)
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        overflow: TextOverflow.fade,
                        maxLines: 6,
                          text: TextSpan(
                            text: widget.info,
                          ),
                      ),
                    ],
                  ),
                ),
              )
          ),

          Positioned(
              bottom: 32,
              right: 40,
              child: GestureDetector(
                onTap: (){
                  playerController?.pause();
                  Navigator.of(context).pop(videoInfo);
                },
                child: CircleAvatar(
                  backgroundColor: Colors.lightBlue,
                  child: Icon(IconList.send, color: Colors.white,),
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
      case VideoSourceType.File:
        playerController = VideoPlayerController.file(File(widget.srcAddress));
        break;
      case VideoSourceType.Network:
        playerController = VideoPlayerController.network(widget.srcAddress);
        break;
      case VideoSourceType.Bytes:
        break;
      case VideoSourceType.Asset:
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
      autoPlay: false,
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
    //List<int> size = MediaTools.getLandscapeMaxSizeCover(w, h);

    //MediaTools.thumbnailVideoPreView(widget.srcAddress,
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
  VoidCallback? viewUpdater;
}
///==================================================================================================
