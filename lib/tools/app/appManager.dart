import 'package:flutter/material.dart';

import 'package:iris_tools/api/logger/logger.dart';
import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/api/logger/reporter.dart';

import '/constants.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/system/keys.dart';
import '/system/session.dart';
import '/tools/centers/routeCenter.dart';
import '/tools/deviceInfoTools.dart';

class AppManager {
  AppManager._();

  static late Logger logger;
  static late Reporter reporter;
  // postCallback work only inside build()
  static late WidgetsBinding widgetsBinding;

	static Map addLanguageIso(Map src, [BuildContext? ctx]) {
    src[Keys.languageIso] = System.getLocalizationsLanguageCode(ctx ?? RouteCenter.getContext());

    return src;
  }

	static Map<String, dynamic> addAppInfo(Map<String, dynamic> src, {UserModel? curUser}) {
		final token = curUser?.token ?? Session.getLastLoginUser()?.token;

    src.addAll(getAppInfo(token));

    return src;
  }


  static Map<String, dynamic> getAppInfo(String? token) {
    final res = <String, dynamic>{};
    res['device_id'] = DeviceInfoTools.deviceId;
    res['app_name'] = Constants.appName;
    res['app_version_code'] = Constants.appVersionCode;
    res['app_version_name'] = Constants.appVersionName;

	if(token != null){
		res['token'] = token;
	}
	
    return res;
  }

	static WidgetsBinding getAppWidgetsBinding(){
		return widgetsBinding;
	}
}
