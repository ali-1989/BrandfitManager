import 'package:flutter/material.dart';

import 'package:another_flushbar/flushbar.dart';

import '/system/extensions.dart';
import '/tools/centers/broadcastCenter.dart';

class SnackCenter {
  SnackCenter._();

  static ScaffoldMessengerState getScaffoldMessenger(BuildContext context){
    return ScaffoldMessenger.of(context);
  }

  static ScaffoldMessengerState getScaffoldMessengerByKey(){
    return BroadcastCenter.rootScaffoldMessengerKey.currentState!;
  }

  static ScaffoldFeatureController showFlutterSnackBar(SnackBar snackBar){
    return getScaffoldMessengerByKey().showSnackBar(snackBar);
  }

  static ScaffoldFeatureController showFlutterBanner(MaterialBanner banner){
    return getScaffoldMessengerByKey().showMaterialBanner(banner);
  }
  ///===================================================================================================
  static  ScaffoldFeatureController showSnack(
      BuildContext context,
      String message, {
        Duration dur = const Duration(milliseconds: 3500),
        SnackBarAction? action,
        Color? backColor,
        EdgeInsetsGeometry? padding,
      }){
    final snackBar = SnackBar(
        content: Text(message),
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.horizontal,
      duration: dur,
      action: action,
      padding: padding,
      backgroundColor: backColor,
    );

    return getScaffoldMessenger(context).showSnackBar(snackBar);
  }

  static Flushbar showFlushBar(
      BuildContext context,
      String message, {
      String? title,
      Icon? icon,
        Duration dur = const Duration(milliseconds: 3500),
        Color? backColor,
        Color? leftBarColor,
    }){
    final f = Flushbar(
      title: title,
      message: message,
      blockBackgroundInteraction: false,
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.elasticOut,
      forwardAnimationCurve: Curves.decelerate,
      icon: icon,
      duration: dur,
      isDismissible: true,
      backgroundColor: backColor?? Color(0xFF303030),
      leftBarIndicatorColor: leftBarColor,
    );

    f.show(context);
    return f;
  }

  static Flushbar showFlashBarInfo(BuildContext context, String message ,{String? title}) {
    final icon = Icon(
      Icons.info_outline,
      color: Colors.blue[300],
      size: 28.0,
    );

    return showFlushBar(context, message, title: title, icon: icon, leftBarColor: Colors.blue[300]);
  }

  static Flushbar showFlashBarSuccess(BuildContext context, String message ,{String? title}) {
    final icon = Icon(
      Icons.check_circle,
      color: Colors.green[300],
      size: 28.0,
    );

    return showFlushBar(context, message, title: title, icon: icon, leftBarColor: Colors.green[300]);
  }

  static Flushbar showFlashBarError(BuildContext context, String message ,{String? title}) {
    final icon = Icon(
      Icons.warning,
      color: Colors.red[300],
      size: 28.0,
    );

    return showFlushBar(context, message, title: title, icon: icon, leftBarColor: Colors.red[300]);
  }

  static Flushbar showFlashBarAction(BuildContext context,
      String message,
      Widget btn, {
    String? title,
        Duration dur = const Duration(milliseconds: 3500),
        bool autoDismiss = false,
        String routeName = 'flushBarSnack',
      }) {
    final fb = Flushbar(
      title: title,
      message: message,
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.GROUNDED,
      reverseAnimationCurve: Curves.elasticOut,
      forwardAnimationCurve: Curves.decelerate,
      duration: (!autoDismiss)? null: dur,
      isDismissible: autoDismiss,
      mainButton: btn,
    );

    fb.show(context);
    return fb;
  }

  static Flushbar showSnackNotice(BuildContext context, String message){
    return showFlushBar(context, message, title: context.tC('notice'));
  }
  ///--------------------------------------------------------------------------------
  static Flushbar showSnack$netDisconnected(BuildContext context) {
    return showFlashBarError(context, context.tC('netConnectionIsDisconnect')!);
  }

  static Flushbar showSnack$errorCommunicatingServer(BuildContext context) {
    return showFlashBarError(context, context.tC('errorCommunicatingServer')!);
  }

  static Flushbar showSnack$serverNotRespondProperly(BuildContext context) {
    return showFlashBarInfo(context, context.tC('serverNotRespondProperly')!);
  }

  static Flushbar showSnack$errorInServerSide(BuildContext context) {
    return showFlashBarInfo(context, context.tC('errorInServerSide')!);
  }

  static Flushbar showSnack$operationCannotBePerformed(BuildContext context) {
    return showFlashBarInfo(context, context.tC('operationCannotBePerformed')!);
  }

  static Flushbar showSnack$successOperation(BuildContext context) {
    return showFlashBarSuccess(context, context.tC('successOperation')!);
  }

  static Flushbar showSnack$OperationFailed(BuildContext context) {
    return showFlashBarError(context, context.tC('operationFailed')!);
  }

  static Flushbar showSnack$OperationFailedTryAgain(BuildContext context) {
    return showFlashBarError(context, context.tC('operationFailedTryAgain')!);
  }

  static Flushbar showSnack$operationCanceled(BuildContext context) {
    return showFlashBarInfo(context, context.tC('operationCanceled')!);
  }
}

/*
  ScaffoldMessenger.of(context).showSnackBar(mySnackBar);
  ScaffoldMessenger.of(context).hideCurrentSnackBar(mySnackBar);
  ScaffoldMessenger.of(context).removeCurrentSnackBar(mySnackBar);

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  ScaffoldMessenger(
    key: scaffoldMessengerKey,
    child: ...
  )

  scaffoldMessengerKey.currentState.showSnackBar(mySnackBar);
  scaffoldMessengerKey.currentState.hideCurrentSnackBar(mySnackBar);
  scaffoldMessengerKey.currentState.removeCurrentSnackBar(mySnackBar);
 */
