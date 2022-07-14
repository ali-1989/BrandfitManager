
// https://pub.dev/packages/android_alarm_manager_plus
// https://pub.dev/packages/flutter_background
// https://pub.dev/packages/background_fetch
// https://pub.dev/packages/flutter_fgbg

import 'dart:io';

import 'package:brandfit_manager/tools/app/appNotification.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';
import 'package:workmanager/workmanager.dart';

import '/system/initialize.dart';
import '/tools/app/appThemes.dart';
import '/tools/centers/directoriesCenter.dart';
import '/tools/centers/wsCenter.dart';

class CronTask {
  CronTask._();

}
///--------------------------------------------------------------------------------------------
void callbackWorkManager() {
  Workmanager().executeTask((task, inputData) async {
    await Initial.waitForImportant();
    var p = DirectoriesCenter.getAppFolderInExternalStorage();
    p += '/worker.txt';

    final f = FileHelper.getFile(p);
    f.createSync(recursive: true);
    f.writeAsStringSync('> ${DateTime.now()} |', mode: FileMode.append);

    WsCenter.connect();
    AppThemes.initial();
    await AppNotification.initial();

    await Future.delayed(Duration(seconds: 20), (){
      f.writeAsStringSync('-ws: ${WsCenter.isConnected}\n', mode: FileMode.append);
    });
    //AppNotification.showNotification(121, 'worker', 'msg', 'p');
    /*switch (task) {
      case Constants.appName:
        break;
      case Workmanager.iOSBackgroundTask:
        break;
    }*/

    return Future.value(true);
  });
}
