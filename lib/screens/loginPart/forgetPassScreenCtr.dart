import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:iris_tools/api/checker.dart';
import 'package:iris_tools/api/converter.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';
import 'package:simple_timer/simple_timer.dart';

import '/abstracts/viewController.dart';
import '/screens/loginPart/forgetPassScreen.dart';
import '/screens/loginPart/loginScreen.dart';
import '/system/httpCodes.dart';
import '/system/keys.dart';
import '/system/requester.dart';
import '/tools/app/appNavigator.dart';
import '/tools/centers/dialogCenter.dart';
import '/tools/centers/httpCenter.dart';
import '/tools/centers/snackCenter.dart';

class ForgetPassScreenCtr implements ViewController {
  late ForgetPassScreenState state;
  Requester? restoreRequester;
  TextEditingController mobileFieldController = TextEditingController();
  TimerController? timerController;


  @override
  void onInitState<E extends State>(E state){
    this.state = state as ForgetPassScreenState;

    restoreRequester = Requester();
    restoreRequester?.requestPath = RequestPath.GetData;

    timerController = TimerController(state);
  }

  @override
  void onBuild(){
  }

  @override
  void onDispose(){
    timerController?.dispose();
    mobileFieldController.dispose();
    HttpCenter.cancelAndClose(restoreRequester?.httpRequester);
  }
  ///========================================================================================================
  void tryAgain(State state){
    if(state is ForgetPassScreenState) {
      state.stateController.mainStateAndUpdate(StateXController.state$loading);
    }
  }

  void timerEnd() {
    state.stateController.setStateData('activeBtn', true);
    state.stateController.updateMain();
  }

  void loginBtn() {
    if(AppNavigator.existRouteByName(state.context, LoginScreen.screenName)){
      AppNavigator.popRoutesUntilPageName(state.context, LoginScreen.screenName);
    }
    //AppManager.navigateRouteScreen('');
    AppNavigator.replaceCurrentRoute(state.context, LoginScreen(), name: LoginScreen.screenName);
  }

  void onSendInfoClick() async {
    FocusHelper.hideKeyboardByUnFocus(state.context);
    //FocusHelper.unFocus(state.context);

    var ph = mobileFieldController.text.trim();
    ph = Converter.resolveMobile(ph)?? '';

    if(ph.isEmpty){
      SnackCenter.showFlashBarError(state.context, state.tC('enterMobile')!);
      return;
    }

    if(!Checker.validateMobile(ph)){
      SnackCenter.showFlashBarError(state.context, state.tC('enterMobileCorrectly')!);
      return;
    }

    final js = <String, dynamic>{};
    js[Keys.request] = 'RestorePassword';
    js[Keys.mobileNumber] = ph;
    js[Keys.phoneCode] = '+98';//todo

    restoreRequester?.bodyJson = js;

    restoreRequester?.httpRequestEvents.onAnyState = (req) async {
      await state.hideLoading();
    };

    restoreRequester?.httpRequestEvents.onNetworkError = (req) async {
      // ignore: unawaited_futures
      DialogCenter().showErrorDialog(state.context, null, state.t('errorCommunicatingServer')!);
    };

    restoreRequester?.httpRequestEvents.onResponseError = (req, isOk) async {
      // ignore: unawaited_futures
      DialogCenter().showErrorDialog(state.context, null, state.t('serverNotRespondProperly')!);
    };

    restoreRequester?.httpRequestEvents.onResultError = (req, data) async {
      final int causeCode = data[Keys.causeCode] ?? 0;

      if(causeCode == HttpCodes.error_dataNotExist) {
        SnackCenter.showFlashBarError(state.context, state.tC('phoneNumberNotExist')!);
        return true;
      }

      return false;
    };

    restoreRequester?.httpRequestEvents.onResultOk = (req, data) async {
      await state.hideLoading();

      timerController?.reset();
      timerController?.start();
      state.stateController.setStateData('activeBtn', false);
      state.stateController.updateMain();

      SnackCenter.showSnack(state.context, state.tC('informationWasSend')!);
    };

    state.showLoading();
    restoreRequester!.request(state.context);
  }
}
