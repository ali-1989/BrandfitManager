import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';

import '/abstracts/viewController.dart';
import '/screens/loginPart/forgetPassScreen.dart';
import '/screens/loginPart/loginScreen.dart';
import '/screens/registeringPart/registerScreen.dart';
import '/system/httpCodes.dart';
import '/system/httpProcess.dart';
import '/system/keys.dart';
import '/system/requester.dart';
import '/system/session.dart';
import '/tools/app/appNavigator.dart';
import '/tools/centers/broadcastCenter.dart';
import '/tools/centers/dialogCenter.dart';
import '/tools/centers/httpCenter.dart';
import '/tools/centers/localeCenter.dart';
import '/tools/centers/routeCenter.dart';
import '/tools/centers/snackCenter.dart';
import '/tools/centers/wsCenter.dart';
import '/tools/deviceInfoTools.dart';

class LoginScreenCtr implements ViewController {
  late LoginScreenState state;
  Requester? loginRequester;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController userNameCtl = TextEditingController();
  TextEditingController passwordCtl = TextEditingController();


  @override
  void onInitState<E extends State>(E state){
    this.state = state as LoginScreenState;

    loginRequester = Requester();
  }

  @override
  void onBuild(){
  }

  @override
  void onDispose(){
    userNameCtl.dispose();
    passwordCtl.dispose();
    HttpCenter.cancelAndClose(loginRequester?.httpRequester);
  }
  ///========================================================================================================
  void tryAgain(State state){
    if(state is LoginScreenState) {
      state.stateController.mainStateAndUpdate(StateXController.state$loading);
    }
  }

  String? validation(TextEditingController controller) {
    final text = controller.text.trim();

    if (controller == userNameCtl) {
      if (text.isEmpty) return LocaleCenter.appLocalize.translate('enterUserName')!;

      return null;
    }

    if (controller == passwordCtl) {
      if (text.isEmpty) return LocaleCenter.appLocalize.translate('enterYourPassword')!;

      if (text.length < 4 || text.length > 12) return LocaleCenter.appLocalize.translate('passwordMust4Char')!;

      return null;
    }

    return null;
  }

  void forgetPasswordBtn() {
    Timer(const Duration(milliseconds: 200), (){
      if (AppNavigator.canPopCurrent(state.context)) {
        AppNavigator.replaceCurrentRoute(state.context, ForgetPassScreen(), name: ForgetPassScreen.screenName);
      } else {
        AppNavigator.pushNextPage(state.context, ForgetPassScreen(), name: ForgetPassScreen.screenName);
      }
    });
  }

  void registerBtn() {
    Timer(const Duration(milliseconds: 200), (){
      if (AppNavigator.canPopCurrent(state.context)) {
        AppNavigator.replaceCurrentRoute(state.context, const RegisterScreen(), name: RegisterScreen.screenName);
      } else {
        RouteCenter.navigateRouteScreen(RegisterScreen.screenName);
      }
    });
  }

  void requestLogin() async {
    FocusHelper.hideKeyboardByUnFocusRoot();

    if (!(formKey.currentState?.validate() ?? true)) {
      SnackCenter.showSnack(state.context, state.tC('pleaseFillOptions')!,);
      return;
    }

    /*if (!(await NetManager.isConnected())) {
      DialogCenter().showDialog$NetDisconnected(state.context);
      return;
    }*/

    final userName = userNameCtl.text.trim();
    final password = passwordCtl.text.trim();

    final js = <String, dynamic>{};
    js[Keys.userName] = userName;
    js['hash_password'] = Generator.generateMd5(password);
    js['timezone_offset'] = DateHelper.getTimeZoneOffsetMillis();
    js[Keys.languageIso] = System.getLocalizationsLanguageCode(state.context);
    js[Keys.countryIso] = System.getLocalizationsCountryCode(state.context);

    if (System.isWeb()) {
      js['device_type'] = 'Web';
      js['model'] = DeviceInfoTools.webDeviceInfo?.appName;
      js['brand'] = DeviceInfoTools.webDeviceInfo?.userAgent;
      js['api'] = DeviceInfoTools.webDeviceInfo?.appVersion;
    }
    else if (System.isAndroid()) {
      js['device_type'] = 'Android';
      js['model'] = DeviceInfoTools.androidDeviceInfo?.model;
      js['brand'] = DeviceInfoTools.androidDeviceInfo?.brand;
      js['api'] = DeviceInfoTools.androidDeviceInfo?.version.sdkInt.toString();
    }
    else if (System.isIOS()) {
      js['device_type'] = 'iOS';
      js['model'] = DeviceInfoTools.iosDeviceInfo?.model; //utsname.machine
      js['brand'] = DeviceInfoTools.iosDeviceInfo?.systemName;
      js['api'] = DeviceInfoTools.iosDeviceInfo?.utsname.version.toString();
    }

    loginRequester?.bodyJson = js;
    loginRequester?.httpItem.pathSection = '/login';

    loginRequester?.httpRequestEvents.onNetworkError = (req) async {
      await state.hideLoading();
      // ignore: unawaited_futures
      DialogCenter().showErrorDialog(state.context, null, state.t('errorCommunicatingServer')!);
    };

    loginRequester?.httpRequestEvents.onResponseError = (req, isOk) async {
      await state.hideLoading();
      // ignore: unawaited_futures
      DialogCenter().showErrorDialog(state.context, null, state.t('serverNotRespondProperly')!);
    };

    loginRequester?.httpRequestEvents.onResultError = (req, data) async {
      await state.hideLoading();
      SnackCenter.showSnack$errorInServerSide(state.context);

      return true;
    };

    loginRequester?.httpRequestEvents.manageResponse = (req, data) async {
      await state.hideLoading();

      final String result = data[Keys.result] ?? Keys.error;

      if (result == 'Grant') {
        await Session.logoffAll();

        await Session.login$newProfileData(data as Map<String, dynamic>).then((value) {
          if (WsCenter.isConnected) {
            WsCenter.sendHeartAndUsers();
          } else {
            WsCenter.connect();
          }
        });

        SnackCenter.showFlashBarSuccess(state.context, state.tC('welcome_')!.replaceFirst('#1', data[Keys.userName]));

        Timer(const Duration(milliseconds: 3500), () {
          if(state.mounted) {
            if (AppNavigator.canPop(state.context)) {
              BroadcastCenter.reBuildMaterial();
              AppNavigator.backRoute(state.context);
            }
            else {
              RouteCenter.navigateRouteScreen(RoutesName.homePage);
              AppNavigator.popRoutesUntilRoot(state.context);
            }
          }
        });
      }
      else if (result == Keys.error) {
        final int causeCode = data[Keys.causeCode] ?? 0;
        final String cause = data[Keys.cause] ?? Keys.error;

        if (causeCode == HttpCodes.error_userNamePassIncorrect) {
          SnackCenter.showSnack(state.context, state.tInMap('httpCodes', 'userNameOrPasswordIncorrect')!);
        }
        else if (!HttpProcess.processCommonRequestErrors(state.context, causeCode, cause, data)) {
          SnackCenter.showSnack$serverNotRespondProperly(state.context);
        }
      }
    };

    state.showLoading();
    loginRequester!.request(state.context);

    /*Dio dio = Dio();

    dio.options.baseUrl = 'http://localhost:6060';
    dio.options.method = 'POST';
    dio.options.responseType = ResponseType.plain;

    var res = await dio.request('/login');*/

    /*var url = Uri.parse('http://localhost:6060/login');
    var response = await http.post(url);
    prin-t('Response body: ${response.body}');*/
  }
}
