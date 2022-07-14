import 'package:iris_tools/api/helpers/boolHelper.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/system.dart';

import '/constants.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/screens/drawerMenu.dart';
import '/system/httpCodes.dart';
import '/system/keys.dart';
import '/system/session.dart';
import '/tools/app/appManager.dart';
import '/tools/app/appNavigator.dart';
import '/tools/centers/broadcastCenter.dart';
import '/tools/centers/cacheCenter.dart';
import '/tools/centers/httpCenter.dart';
import '/tools/centers/routeCenter.dart';
import '/tools/deviceInfoTools.dart';

class UserLoginTools {
  UserLoginTools._();

  // on new login
  static void onLogin(UserModel user){
    DrawerMenuTool.prepareAvatar(user);

    /*UserNotifierManager.managerFor(user.userId).requestNotifiers().then((value){
      Broadcast.prepareBadgesAndRefresh();
    });*/
  }

  static void onLogoff(UserModel user){
    user.profileProvider = null;
    sendLogoffState(user);
  }

  // on new data for existUser
  static void onProfileChange(UserModel user, Map? old) async {
    DrawerMenuTool.prepareAvatar(user);
  }

  static void sendLogoffState(UserModel user){
    if(BroadcastCenter.isNetConnected){
      final reqJs = <String, dynamic>{};
      reqJs[Keys.request] = 'LogoffUserReport';
      reqJs[Keys.userId] = user.userId;

      AppManager.addAppInfo(reqJs, curUser: user);

      final info = HttpItem();
      info.pathSection = '/set-data';
      info.method = 'POST';
      info.addBodyField('Json', JsonHelper.mapToJson(reqJs));
      info.setResponseIsPlain();

      HttpCenter.send(info);
    }
  }

  static void prepareRequestUsersProfileData() async {
    for(var user in Session.currentLoginList) {
      if(!CacheCenter.timeoutCache.addTimeout('updateProfileInfo_${user.userId}', Duration(seconds: 12))){
        continue;
      }

      requestProfileInfo(user.userId).then((value){
        if(BoolHelper.itemToBool(value)) {
        }
      });
    }
  }

  static Future<bool> requestProfileInfo(int userId) async{
    final reqJs = <String, dynamic>{};
    reqJs[Keys.request] = 'GetProfileInfo';
    reqJs[Keys.userId] = userId;

    AppManager.addAppInfo(reqJs);

    final request = HttpItem();
    request.pathSection = '/get-data';
    request.method = 'POST';
    request.setBodyJson(reqJs);
    request.setResponseIsPlain();

    final f = Future<bool>((){
      final response = HttpCenter.send(request);

      var res = response.responseFuture.catchError((err){
				return err;
			});

      return res.then((value) async {
        if (!response.isOk) {
          return false;
        }

        final json = response.getBodyAsJson();

        if (json == null) {
          return false;
        }

        final String result = json[Keys.result] ?? Keys.error;

        if (result == Keys.ok) {
          await Session.newProfileData(json);
        }
        else {
          final causeCode = json[Keys.causeCode]?? 0;

          if(causeCode == HttpCodes.error_tokenNotCorrect || causeCode == HttpCodes.error_userNotFound) {
            await forceLogoff(userId);
            await Session.deleteUserInfo(userId);
          }
        }

        return true;
      });
    });

    return f;
  }

  static Future forceLogoff(int userId) async {
    final isCurrent = Session.getLastLoginUser()?.userId == userId;
    await Session.logoff(userId);

    if (isCurrent) {
      AppNavigator.popRoutesUntilRoot(RouteCenter.getContext());
    }
  }

  static Future forceLogoffAll() async {
    await Session.logoffAll();
    AppNavigator.popRoutesUntilRoot(RouteCenter.getContext());
  }

  ///----------- HowIs ----------------------------------------------------
  static Map<String, dynamic> getHowIsMap() {
    final howIs = <String, dynamic>{
      'how_is': 'HowIs',
      Keys.deviceId: DeviceInfoTools.deviceId,
      Keys.languageIso: System.getLocalizationsLanguageCode(RouteCenter.getContext()),
      'app_version_code': Constants.appVersionCode,
      'app_version_name': Constants.appVersionName,
      'app_name': Constants.appName,
    };

    final users = [];

    for(var um in Session.currentLoginList) {
      users.add(um.userId);
    }

    howIs['users'] = users;

    return howIs;
  }

  static Map<String, dynamic> getHeartMap() {
    final heart = <String, dynamic>{
      'heart': 'Heart',
      Keys.deviceId: DeviceInfoTools.deviceId,
      Keys.languageIso: System.getLocalizationsLanguageCode(RouteCenter.getContext()),
      'app_version_code': Constants.appVersionCode,
      'app_version_name': Constants.appVersionName,
      'app_name': Constants.appName,
    };

    final users = [];

    for(var um in Session.currentLoginList) {
      users.add(um.userId);
    }

    heart['users'] = users;

    return heart;
  }
}
