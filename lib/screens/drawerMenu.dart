import 'dart:async';

import 'package:flutter/material.dart';

import 'package:iris_tools/api/cache/memoryCache.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/api/helpers/textHelper.dart';
import 'package:iris_tools/api/manageCallAction.dart';
import 'package:iris_tools/modules/propertyNotifier/propertyChangeConsumer.dart';
import 'package:iris_tools/modules/stateManagers/refresh.dart';
import 'package:permission_handler/permission_handler.dart';

import '/models/dataModels/usersModels/userModel.dart';
import '/system/enums.dart';
import '/system/extensions.dart';
import '/system/icons.dart';
import '/system/keys.dart';
import '/system/session.dart';
import '/tools/app/appThemes.dart';
import '/tools/centers/broadcastCenter.dart';
import '/tools/centers/cacheCenter.dart';
import '/tools/centers/dialogCenter.dart';
import '/tools/centers/directoriesCenter.dart';
import '/tools/centers/httpCenter.dart';
import '/tools/centers/routeCenter.dart';
import '/tools/permissionTools.dart';

///UserAccountsDrawerHeader
typedef OnMenuClick = void Function(String name);
///========================================================================================
class DrawerMenuTool {
  DrawerMenuTool._();

  static void refreshDrawer(){
    BroadcastCenter.drawerMenuRefresher.update();
  }

  static Widget getDrawerMenu(BuildContext ctx, OnMenuClick onMenuClick){
    return Drawer(
      // * for remove statusBar padding use: MediaQuery.removePadding(removeTop: true)
      // * for remove Drawer from statusBar: remove Drawer() from tree
      elevation: 0.0,
      child: Refresh(
          controller: BroadcastCenter.drawerMenuRefresher,
          builder: (ctx, c) {
            final user = Session.getLastLoginUser();

            return ListTileTheme(
              style: ListTileStyle.drawer,
              contentPadding: const EdgeInsetsDirectional.only(start: 16.0),
              iconColor: AppThemes.currentTheme.drawerItemColor,
              textColor: AppThemes.currentTheme.drawerItemColor,
              dense: true,
              child: ListView(
                padding: EdgeInsets.zero, // * remove statusBar padding
                children: <Widget>[
                  Theme(
                    data: AppThemes.themeData.copyWith(dividerTheme: const DividerThemeData(color: Colors.transparent)),
                    child: DrawerHeader(
                      decoration: BoxDecoration(
                          color: AppThemes.currentTheme.primaryColor
                      ),
                      duration: const Duration(milliseconds: 500),
                      curve: const ElasticInCurve(),
                      margin: EdgeInsets.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Stack(
                        children: <Widget>[

                          ///-------- avatar
                          Positioned.directional(
                            textDirection: AppThemes.textDirection,
                            start: 10.0,
                            bottom: 20.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                    width: 82, height: 82,
                                    child: PropertyChangeConsumer<UserModel, UserModelNotifierMode>(
                                      model: user,
                                      onAnyInstance: true,
                                      properties: [UserModelNotifierMode.profilePath],
                                      builder: (context, model, properties){
                                        if(model?.profileProvider != null && user != null) {
                                          return CircleAvatar(
                                            backgroundImage: model!.profileProvider,
                                          );
                                        }

                                        return LayoutBuilder(
                                            builder: (ctx, size){
                                              return Icon(
                                                Icons.supervised_user_circle,
                                                size: size.maxWidth,
                                                color: AppThemes.currentTheme.appBarItemColor,
                                              );
                                            });
                                      },
                                    )
                                ),

                                const SizedBox(height: 5,),

                                if(user != null)
                                  Text(TextHelper.subStringIfBig(user.userName, 0, 20),
                                    style: AppThemes.appBarTextStyle(),
                                    maxLines: 1,
                                  )
                              ],
                            ),
                          ),

                          Positioned.directional(
                            textDirection: AppThemes.textDirection,
                            end: 10.0,
                            bottom: 20.0,
                            child: (user != null)?
                            GestureDetector(
                                onTap: () {
                                  void yes(){
                                    Session.logoff(user.userId).then((value) {
                                      refreshDrawer();
                                    });
                                  }

                                  final desc = ctx.tC('doYouWantLogoutYourAccount')!;
                                  final yesText = ctx.tC('yes')!;
                                  final noText = ctx.tC('no')!;

                                  DialogCenter().showYesNoDialog(ctx, desc: desc,yesText: yesText, yesFn: yes,
                                      noText: noText);
                                },
                                child: Icon(
                                    Icons.power_settings_new,
                                    color: ColorHelper.getUnNearColor(Colors.red, AppThemes.currentTheme.primaryColor, Colors.black)
                                )
                            ) : const SizedBox(),
                          )
                        ],
                      ),
                    ),
                  ),

                  ///-------------------menu item list
                  ///...home item
                  ListTile(
                    title: Text(ctx.tInMap('drawerMenu', 'home')!),
                    leading: SizedBox(height: double.infinity, child: Icon(IconList.home,)),
                    onTap: () async{
                      onMenuClick.call(RoutesName.homePage);
                    },
                  ),

                  if(!Session.hasAnyLogin())
                    ListTile(
                      title: Text(ctx.tInMap('drawerMenu', 'login')!,),
                      leading: Icon(IconList.personLogin),
                      onTap: () {
                        //Settings.rootScreenKey.currentState?.toggleDrawer();
                        onMenuClick.call(RoutesName.loginPage);
                      },
                    ),

                  ListTile(
                    title: Text(ctx.tInMap('drawerMenu', 'register')!),
                    leading: Icon(IconList.pencil),
                    //subtitle: Divider(height: 1, thickness: 1,),
                    onTap: () {
                      onMenuClick.call(RoutesName.registerPage);

                      /*if (Settings.lastRouteScreen != 'Register')
                    AppManager.changeRouteScreen('Register');

                  ctx = WidgetHelper.findLastContext(ctx);
                  AppNavigator.removeAllPageExceptRoot(ctx);*/
                    },
                  ),

                  ListTile(
                    title: Text(ctx.tInMap('drawerMenu', 'bmi&bmr')!),
                    leading: Icon(IconList.bmi),
                    onTap: () {
                      onMenuClick.call(RoutesName.bmiPage);
                    },
                  ),

                  ListTile(
                    title: Text(ctx.tInMap('drawerMenu', 'settings')!),
                    leading: Icon(IconList.settings),
                    //subtitle: SizedBox(height: 1, child: ColoredBox(color: AppThemes.currentTheme.textColor,),),
                    onTap: () async{
                      onMenuClick.call(RoutesName.settingsPage);
                    },
                  ),

                ],
              ),
            );
          }
      ),
    );
  }
  ///============================================================================================
  static Future<bool> prepareAvatar(UserModel? user) async {
    if(user == null || user.profileUri == null) {
      return false;
    }

    final permission = await PermissionTools.requestStoragePermission();

    if (permission != PermissionStatus.granted) {
      return false;
    }

    if(user.profilePath != null) {
      if(user.profileProvider == null) {
        // for call listeners
        user.profilePath = user.profilePath;
      }

      return true;
    }

    var dKey = Keys.genDownloadKey_userAvatar(user.userId);

    Completer<bool>? notifier;
    CacheItem? ci = CacheCenter.appCache.get(dKey);

    if(ci != null){
      return true;
    }
    else {
      notifier = Completer<bool>();
      var mci = CacheItem(value: notifier);
      CacheCenter.appCache.add(dKey, mci);
    }

    void action() async {
      downloadAvatarFile(user).then((isDownload) async {
        CacheCenter.appCache.deleteCash(dKey);
        ManageCallInDuration.purgeItem(dKey);

        if(isDownload){
          final savePath = DirectoriesCenter.getSavePathUri(user.profileUri, SavePathType.USER_PROFILE);
          user.profilePath = savePath;

          notifier!.complete(true);
          return;
        }

        notifier!.complete(false);
        });
    }

    final downloadAvatar = ManageCallInDuration(dKey, const Duration(seconds: 30));
    downloadAvatar.defineAction(action);
    downloadAvatar.call();

    return true; // notifier.future;
  }

  static Future<bool> downloadAvatarFile(UserModel user) async{
    if(user.profileUri == null) {
      return false;
    }

    final permission = await PermissionTools.requestStoragePermission();

    if (permission != PermissionStatus.granted) {
      return false;
    }

    final httpItem = HttpItem();
    httpItem.fullUri = user.profileUri;
    httpItem.method = 'GET';

    final savePath = DirectoriesCenter.getSavePathUri(user.profileUri, SavePathType.USER_PROFILE)!;
    final re = HttpCenter.download(httpItem, savePath);

    return re.responseFuture.catchError((e){
      return false;
    }).then((value) {
      if(!re.isOk){
        return false;
      }

      return true;
    });
  }
}


