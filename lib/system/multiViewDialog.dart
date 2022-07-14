import 'dart:async';

import 'package:flutter/material.dart';

import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/api/timerTools.dart';
import 'package:iris_tools/features/overlayDialog.dart';
import 'package:iris_tools/widgets/icon/circularIcon.dart';
import 'package:iris_tools/widgets/maxWidth.dart';

import '/managers/settingsManager.dart';
import '/screens/home/homeScreen.dart';
import '/system/extensions.dart';
import '/system/icons.dart';
import '/system/keys.dart';
import '/system/session.dart';
import '/tools/app/appNavigator.dart';
import '/tools/app/appSizes.dart';
import '/tools/app/appThemes.dart';
import '/tools/centers/routeCenter.dart';
import '/tools/centers/wsCenter.dart';

class MultiViewDialog {
  final String _navName;
  Widget _contentView;
  Color? screenBackground;
  final bool scrollable;
  final bool useExpanded;
  final Function()? onCloseButton;

  MultiViewDialog(
      Widget view,
      String routeName,{
        this.screenBackground,
        this.scrollable = false,
        this.useExpanded = false,
        this.onCloseButton,
      })
      : _navName = routeName, _contentView = view;

  Future<T> _show<T>(BuildContext context, {bool canBack = false, Duration? closeDur}){
    final view = OverlayScreenView(
      content: _contentView,
      routingName: _navName,
      scrollable: scrollable,
      backgroundColor: screenBackground?? AppThemes.currentTheme.backgroundColor,
    );

    final fut = OverlayDialog().show<T>(context, view, canBack: canBack);

    Timer? cancelTimer;

    if(closeDur != null) {
      cancelTimer = TimerTools.timer(closeDur, () {
        OverlayDialog().hideByOverlay(context, view);
      });
    }

    return fut.then((value) {
      cancelTimer?.cancel();

      if(value != null) {
        return value;
      }

      return Future.value(null);
    });
  }

  Future<T> showFullscreen<T>(BuildContext context,{bool canBack = false, Duration? closeDur,}){
    return _show(context, canBack: canBack, closeDur: closeDur);
  }

  Future<T> showMini<T>(BuildContext context, {
    bool canBack = false,
    Duration? closeDur,
    Alignment alignment = Alignment.center,
    EdgeInsets padding = EdgeInsets.zero,
    }){
    screenBackground = Colors.transparent;
    _contentView = Padding(
      padding: padding,
      child: Align(
        alignment: alignment,
        child: _contentView,
      ),
    );
    return _show(context, canBack: canBack, closeDur: closeDur);
  }

  Future<T> showWithCloseButton<T>(BuildContext context, {
  bool canBack = false,
  Widget? closeButton,
  Duration? closeDur,
  Alignment alignment = Alignment.center,
  EdgeInsets padding = const EdgeInsets.fromLTRB(0, 40, 0, 10),
  double closeOffset = 22,
  }){

    closeButton ??= CircularIcon(
      icon: IconList.close,
      itemColor: Colors.black,
      backColor: Colors.white,
    );

    final Widget wrap = LayoutBuilder(
        builder: (ctx, w){
          return SizedBox(
            width: w.maxWidth,
            height: w.maxHeight,
            child: Padding(
              padding: padding,
              child: Align(
                alignment: alignment,
                child: Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.antiAlias,
                  fit: StackFit.loose,

                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: closeOffset,),

                        Flexible(
                          flex: useExpanded? 1: 0, // 1 = Expanded
                          fit: useExpanded? FlexFit.tight : FlexFit.loose,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: _contentView,
                          ),
                        ),
                      ],
                    ),

                    Positioned(
                      left: 0,
                      right: 0,
                      child: Align(
                        alignment: FractionalOffset(0.5, 0.0),
                        //alignment: Alignment.topCenter,
                        child: IconButton(
                          icon: closeButton!,
                          onPressed: (){
                            if(onCloseButton != null) {
                              onCloseButton?.call();
                            }
                            else {
                              hide(context);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
    );

    final view = OverlayScreenView(
      content: wrap,
      routingName: _navName,
      scrollable: scrollable,
      backgroundColor: screenBackground?? Colors.transparent,
    );

    final fut = OverlayDialog().show<T>(context, view, canBack: canBack);

    Timer? cancelTimer;

    if(closeDur != null) {
      cancelTimer = TimerTools.timer(closeDur, () {
        OverlayDialog().hideByOverlay(context, view);
      });
    }

    return fut.then((value) {
      cancelTimer?.cancel();

      if(value != null) {
        return value;
      }

      return Future.value(null);
    });
  }

  void hide(BuildContext context) {
    AppNavigator.popByRouteName(context, _navName);
  }
  ///======================================================================================================
  static void hideDialog(BuildContext context, String routeName) {
    AppNavigator.removeRouteByName(context, routeName);
  }
  ///======================================================================================================
  static Future<dynamic> showWelcomeUser(BuildContext context, Map<String, dynamic> json){
    final stableCtx = AppNavigator.getStableContext(context);

    final name = json[Keys.name].toString();
    final family = json['family'].toString();
    final String? token = json[Keys.token];
    //String userName = json['UserName'].toString();

    AppNavigator.removeRouteByName(context, 'VerifyMobile');
    AppNavigator.removeRouteByName(stableCtx, 'Register');

    final startBtn = ElevatedButton(
      child: Text('${stableCtx.tC('start')}'),
      onPressed: (){

        if(SettingsManager.serverHackState || (token != null && !Session.hasAnyLogin()) ){
          Session.login$newProfileData(json).then((value) {
            if (WsCenter.isConnected) {
              WsCenter.sendHeartAndUsers();
            } else {
              WsCenter.connect();
            }

            RouteCenter.navigateRouteScreen(HomeScreen.screenName);
            OverlayDialog().hideByPop(stableCtx);
            AppNavigator.popRoutesUntilRoot(stableCtx);
          });
        }
        else{
          RouteCenter.navigateRouteScreen(HomeScreen.screenName);
          OverlayDialog().hideByPop(stableCtx);// hideByName(stableCtx, 'WelcomeNewRegister');
          AppNavigator.popRoutesUntilRoot(stableCtx);
        }
      },
    );

    final Widget content = ConstrainedBox(
      constraints: BoxConstraints.expand(),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.fwSize(40), vertical: AppSizes.fwSize(30)),
        children: [
          SizedBox(height: AppSizes.fwSize(110),),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.account_circle, size: 130,),
              SizedBox(height: AppSizes.fwSize(10),),
              Text('$name $family').bold().fs(18),
              SizedBox(height: AppSizes.fwSize(5),),
              //Text('($userName)').fs(14),
            ],
          ),

          SizedBox(height: AppSizes.fwSize(10),),
          Center(child: AutoSizeText('${context.tC('welcomeToBrandfit')}', maxLines: 1,).bold().fs(20)),

          SizedBox(height: AppSizes.fwSize(35),),
          MaxWidth(
              maxWidth: 400,
              child: Text('${stableCtx.tJoin('descriptionAfterRegister')}',
                textAlign: TextAlign.center,).fs(16).infoColor()
          ),

          SizedBox(height: AppSizes.fwSize(50),),
          MaxWidth(
            maxWidth: 500,
            child: FractionallySizedBox(
              widthFactor: 0.6,
              child: startBtn,
            ),

          ),
        ],
      ),
    );

    final view = OverlayScreenView(
      content: content,
      routingName: 'WelcomeNewRegister',
      backgroundColor: AppThemes.currentTheme.backgroundColor,
    );

    System.removeColorTopStatusBar();

    return OverlayDialog().show(stableCtx, view, canBack: false,).then((value){
      System.returnBackColorTopStatusBar(AppThemes.currentThemeMode == ThemeMode.light);
      return value;
    });
  }
  ///======================================================================================================
  static Widget addCloseBtn(BuildContext context, Widget content, {
    Widget? closeButton,
    Function? onCloseButton,
    String? navName,
    Alignment alignment = Alignment.center,
    EdgeInsets padding = EdgeInsets.zero,
    double closeOffset = 20,
    bool withExpanded = false,
  }){

    closeButton ??= CircularIcon(
      icon: IconList.close,
      itemColor: Colors.black,
      backColor: Colors.white,);

    final Widget stack = Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.antiAlias,
      fit: StackFit.loose,

      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: closeOffset,
            ),

            if(!withExpanded)
              content,
            if(withExpanded)
              Expanded(
                child: content
            ),
          ],
        ),

        Positioned(
          left: 0,
          right: 0,
          child: Align(
            alignment: FractionalOffset(0.5, 0.0),
            child: IconButton(
              icon: closeButton,
              onPressed: (){
                if(onCloseButton != null) {
                  onCloseButton.call();
                }
                else {
                  if(navName != null) {
                    AppNavigator.popByRouteName(context, navName);
                  }
                }
              },
            ),
          ),
        ),
      ],
    );

    final Widget wrap = Padding(
      padding: padding,
      child: Align(
        alignment: alignment,
        child: stack,
      ),
    );

    return wrap;
  }
}
