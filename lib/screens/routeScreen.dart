import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:animate_do/animate_do.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import '/managers/settingsManager.dart';
import '/screens/commons/patternLock.dart';
import '/screens/commons/selectAppLanguageScreen.dart';
import '/screens/home/homeScreen.dart';
import '/screens/loginPart/loginScreen.dart';
import '/screens/registeringPart/registerScreen.dart';
import '/system/extensions.dart';
import '/system/initialize.dart';
import '/system/keys.dart';
import '/system/launchUp.dart';
import '/tools/centers/broadcastCenter.dart';
import '/tools/centers/dbCenter.dart';
import '/tools/centers/directoriesCenter.dart';
import '/tools/centers/routeCenter.dart';

part 'routeScreenLock.dart';

class RouteScreen extends StatelessWidget {
  static const screenName = 'RouteScreen';

  RouteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    callOnBuild();

    if (LockScreenTools.mustSetPattern() || LockScreenTools.mustLock()) {
      SettingsManager.settingsModel.currentRouteScreen = RoutesName.lockScreenPage;
    }

    return StreamBuilder<String>(
      initialData: SettingsManager.settingsModel.currentRouteScreen,
      stream: BroadcastCenter.pageRouterStream.stream,
      builder: (context, snapshot) {
        RouteCenter.materialContext = context;

        switch (snapshot.data) {
          case RoutesName.lockScreenPage:
            return LockScreenTools.getLockScreen(context);
          case RoutesName.homePage:
            return FadeInUp(
                child: HomeScreen(
              key: BroadcastCenter.homeScreenKey,
            ));
          case RoutesName.languagePage:
            return SelectAppLanguageScreen();
          case RoutesName.loginPage:
            return LoginScreen();
          case RoutesName.registerPage:
            return RegisterScreen();
          default:
            return Container(
              alignment: Alignment.center,
              child: const Text(
                'Page not found.',
                style: TextStyle(decoration: TextDecoration.none, color: Colors.red, fontSize: 28),
              ),
            );
        }
      },
    );
  }
}
///=============================================================================================================
void callOnBuild() {
  if (!SettingsManager.calledBootUp) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Timer.periodic(const Duration(milliseconds: 50), (Timer timer) {
        if (Initial.isInitial) {
          timer.cancel();
          LaunchUp.callOnLaunchUp();
        }
      });
    });
  }

  if (SettingsManager.settingsModel.currentRouteScreen == RoutesName.homePage) {
    DirectoriesCenter.generateNoMediaFile();
  }
}
