import 'package:flutter/material.dart';

import 'package:iris_db/iris_db.dart';

import '/abstracts/stateBase.dart';
import '/managers/settingsManager.dart';
import '/screens/bmiPart/bmiScreen.dart';
import '/screens/commons/patternLock.dart';
import '/screens/commons/selectAppLanguageScreen.dart';
import '/screens/home/homeScreen.dart';
import '/screens/loginPart/loginScreen.dart';
import '/screens/registeringPart/registerScreen.dart';
import '/screens/settings/settingsScreen.dart';
import '/system/keys.dart';
import '/tools/app/appManager.dart';
import '/tools/app/appNavigator.dart';
import '/tools/centers/broadcastCenter.dart';
import '/tools/centers/dbCenter.dart';

class RouteCenter {
  RouteCenter._();

  static late BuildContext materialContext;

  static BuildContext getContext() {
    var res = AppManager.widgetsBinding.focusManager.rootScope.focusedChild?.context;//deep: 50
    res ??= AppManager.widgetsBinding.focusManager.primaryFocus?.context; //deep: 71

    return res?? materialContext;
  }

  static BuildContext getFirstContext() {
    return materialContext;
  }

  static Future<bool> saveRouteName(String name) async {
    final val = <dynamic, dynamic>{};
    val[Keys.name] = 'LastScreenName';
    val[Keys.value] = name;

    final dynamic res = await DbCenter.db.insertOrReplace(DbCenter.tbKv, val,
        Conditions()..add(Condition()..key = Keys.name..value = 'LastScreenName'));

    return res != null;
  }

  static String? fetchRouteScreenName() {
    final res = DbCenter.db.query(DbCenter.tbKv,
        Conditions()..add(Condition()..key = Keys.name..value = 'LastScreenName'));

    if(res.isEmpty) {
      return null;
    }

    final Map m = res.firstWhere((map) => map.containsValue('LastScreenName'));
    return m[Keys.value];
  }

  static void navigateRouteScreen(String name) {
    SettingsManager.settingsModel.currentRouteScreen = name;
    BroadcastCenter.pageRouterStream.sink.add(name);
    saveRouteName(name);
  }

  static void backRoute() {
    final mustLastCtx = AppNavigator.getLastRouteContext(getContext());
    AppNavigator.backRoute(mustLastCtx);
  }

  static void reCallPage(BuildContext ctx, Widget page, {required String name, dynamic arguments}) {
    //ModalRoute before = AppNavigator.getPreviousPage(ctx);
    final current = AppNavigator.getModalRouteOf(ctx);
    AppNavigator.popRoutesUntil(ctx, current);
    AppNavigator.replaceCurrentRoute(ctx, page, name: name, data: arguments);
  }

  //must be StateBase
  static bool reloadPreviousModalRoute(BuildContext context){
    final mr = AppNavigator.getPreviousModalRoute(context);

    if(mr == null) {
      return false;
    }

    final StateBase? find = AppNavigator.findStateIn(mr);

    if(find == null) {
      return false;
    }

    find.update();
    return true;
  }

  // onGenerateRoute: RouteCenter.generateRoute,
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.homePage:
        return MyPageRoute(
            widget: HomeScreen(), routeName: settings.name);
      default:
        return MaterialPageRoute(
                builder: (ctx){
                  return HomeScreen();
                },);
    }
  }
}
///============================================================================================
 // Navigator.pushNamed(context, RoutesName.SECOND_PAGE);
class RoutesName {
  static const homePage = HomeScreen.screenName;
  static const loginPage = LoginScreen.screenName;
  static const registerPage = RegisterScreen.screenName;
  static const languagePage = SelectAppLanguageScreen.screenName;
  //static const welcomePage = WelcomeScreen.screenName;
  static const settingsPage = SettingsScreen.screenName;
  static const lockScreenPage = PatternLockScreen.screenName;
  //static const aboutUs = AboutUsScreen.screenName;
  //static const contactUs = SupportScreen.screenName;
  //static const term = TermScreen.screenName;
  static const bmiPage = BmiScreen.screenName;
  //static const caloriesCounterPage = CaloriesCounterScreen.screenName;
}
///============================================================================================
class MyPageRoute extends PageRouteBuilder {
  final Widget widget;
  final String? routeName;

  MyPageRoute({
    required this.widget,
    this.routeName,
  })
      : super(
        settings: RouteSettings(name: routeName),
        pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
          return widget;
        },
      transitionDuration: Duration(milliseconds: 500),
      transitionsBuilder: (BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child) {
        return SlideTransition(
          textDirection: TextDirection.rtl,
          position: Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset.zero,).animate(animation),
          child: child,
        );
      });
}
