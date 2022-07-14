import 'package:flutter/material.dart';

import 'package:iris_tools/widgets/drawer/stackDrawer.dart';

import '/abstracts/viewController.dart';
import '/managers/settingsManager.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/screens/bmiPart/bmiScreen.dart';
import '/screens/home/homeScreen.dart';
import '/screens/loginPart/loginScreen.dart';
import '/screens/registeringPart/registerScreen.dart';
import '/screens/settings/settingsScreen.dart';
import '/system/session.dart';
import '/tools/app/appNavigator.dart';
import '/tools/centers/routeCenter.dart';

class HomeScreenCtr extends ViewController {
  late HomeScreenState state;

  @override
  void onInitState<E extends State>(covariant E state) {
    this.state = state as HomeScreenState;

    Session.addLoginListener(onNewLoginLogoff);
    Session.addLogoffListener(onNewLoginLogoff);
  }

  @override
  void onBuild() {
  }

  @override
  void onDispose() {
    Session.removeLoginListener(onNewLoginLogoff);
    Session.removeLogoffListener(onNewLoginLogoff);
  }

  void onNewLoginLogoff(UserModel user){
    state.stateController.updateMain();
  }

  void toggleDrawer(){
    DrawerStacks.toggle(state.drawerName);
    //Settings.drawerMenuCtr.currentState?.openDrawer();
  }

  void onDrawerMenuClick(String name) async {
    if(name == RoutesName.homePage) {
      toggleDrawer();
      await Future.delayed(Duration(milliseconds: SettingsManager.drawerMenuTimeMill), () {});// optional

      BuildContext ctx = AppNavigator.getStableContext(state.context);
      AppNavigator.popRoutesUntilRoot(ctx);

      if (SettingsManager.settingsModel.currentRouteScreen != RoutesName.homePage) {
        RouteCenter.navigateRouteScreen(RoutesName.homePage);
      }
    }

    if(name == RoutesName.loginPage){
      toggleDrawer();
      await Future.delayed(Duration(milliseconds: SettingsManager.drawerMenuTimeMill), (){});
      AppNavigator.pushNextPageIfNotCurrent<LoginScreen>(state.context, LoginScreen(), name: LoginScreen.screenName);
    }

    if(name == RoutesName.registerPage){
      toggleDrawer();
      await Future.delayed(Duration(milliseconds: SettingsManager.drawerMenuTimeMill), (){});
      AppNavigator.pushNextPageIfNotCurrent<RegisterScreen>(state.context, RegisterScreen(), name: RegisterScreen.screenName);
    }

    if(name == RoutesName.bmiPage){
      toggleDrawer();
      await Future.delayed(Duration(milliseconds: SettingsManager.drawerMenuTimeMill), (){});
      AppNavigator.pushNextPageIfNotCurrent<BmiScreen>(state.context, BmiScreen(), name: BmiScreen.screenName);
    }

    if(name == RoutesName.settingsPage){
      toggleDrawer();
      await Future.delayed(Duration(milliseconds: SettingsManager.drawerMenuTimeMill), (){});
      AppNavigator.pushNextPageIfNotCurrent<SettingsScreen>(state.context, SettingsScreen(), name: SettingsScreen.screenName);
    }
  }
}
