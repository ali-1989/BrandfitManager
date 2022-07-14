import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:iris_tools/api/appEventListener.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/net/netManager.dart';
import 'package:workmanager/workmanager.dart';

import '/constants.dart';
import '/managers/settingsManager.dart';
import '/screens/commons/patternLock.dart';
import '/screens/routeScreen.dart';
import '/system/downloadUpload.dart';
import '/system/keys.dart';
import '/system/session.dart';
import '/tools/app/appNavigator.dart';
import '/tools/centers/broadcastCenter.dart';
import '/tools/centers/cacheCenter.dart';
import '/tools/centers/dbCenter.dart';
import '/tools/centers/routeCenter.dart';
import '/tools/netListenerTools.dart';
import '/tools/userLoginTools.dart';

class LaunchUp {
  LaunchUp._();

  static void callOnLaunchUp(){
    if(SettingsManager.calledBootUp) {
      return;
    }

    SettingsManager.calledBootUp = true;

    final eventListener = AppEventListener();
    eventListener.addResumeListener(onResume);
    eventListener.addPauseListener(onPause);
    eventListener.addDetachListener(onDetach);
    WidgetsBinding.instance.addObserver(eventListener);

    DownloadUpload.downloadManager.addListener(DownloadUpload.commonDownloadListener);
    DownloadUpload.uploadManager.addListener(DownloadUpload.commonUploadListener);

    NetManager.addChangeListener(NetListenerTools.onNetListener);

    Session.addLoginListener(UserLoginTools.onLogin);
    Session.addLogoffListener(UserLoginTools.onLogoff);
    Session.addProfileChangeListener(UserLoginTools.onProfileChange);

    Workmanager().registerPeriodicTask(
      '1',
      Constants.appName,
      frequency: Duration(hours: 2),
      initialDelay: Duration(seconds: 15),
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: Duration(minutes: 5),
      existingWorkPolicy: ExistingWorkPolicy.keep,
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
    /*Future.delayed(Duration(seconds: 4), (){
      CourseRequestManager.checkSendProgramsDeadline();
    });*/
  }
  ///---------------------------------------------------------------------------------------------
  static void onPause() async {
    if(!CacheCenter.timeoutCache.addTimeout('onPause', Duration(seconds: 10))) {
      return;
    }

    if(LockScreenTools.mustLock()) {
      SettingsManager.settingsModel.lastForegroundTs = DateHelper.getNowTimestamp();
      await SettingsManager.saveSettings();
    }
  }

  static void onDetach() async {
    if(!CacheCenter.timeoutCache.addTimeout('onDetach', Duration(seconds: 10))) {
      return;
    }

    if(LockScreenTools.mustLock()) {
      SettingsManager.settingsModel.lastForegroundTs = null;
      await SettingsManager.saveSettings();
    }
  }

  static void onResume() {
    if (LockScreenTools.mustLock()) {
      final screen = PatternLockScreen(
        controller: BroadcastCenter.lockController,
        description: LockScreenTools.getDescription(RouteCenter.materialContext),
        onBack: (ctx, result) {
          SystemNavigator.pop();
          return false;
        },
        onResult: (BuildContext context, List<int>? result) {
          if (result == null) {
            return false;
          }

          final current = DbCenter.fetchKv(Keys.sk$patternKey);

          if (result.join() == current) {
            return true;
          }

          return false;
        },
      );

      AppNavigator.pushNextPage(RouteCenter.getContext(), screen, name: PatternLockScreen.screenName);
    }
  }
}
