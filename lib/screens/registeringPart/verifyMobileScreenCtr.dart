import 'package:flutter/material.dart';

import 'package:iris_db/iris_db.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';
import 'package:simple_timer/simple_timer.dart';

import '/abstracts/viewController.dart';
import '/screens/registeringPart/verifyMobileScreen.dart';
import '/system/httpProcess.dart';
import '/system/keys.dart';
import '/system/multiViewDialog.dart';
import '/system/requester.dart';
import '/tools/centers/dbCenter.dart';
import '/tools/centers/httpCenter.dart';
import '/tools/centers/sheetCenter.dart';
import '/tools/centers/snackCenter.dart';

class VerifyMobileScreenCtr implements ViewController {
  late VerifyMobileScreenState state;
  Requester? resendRequester;
  Requester? verifyRequester;
  var pinController = TextEditingController();
  late TimerController timerController;


  @override
  void onInitState<E extends State>(E state){
    this.state = state as VerifyMobileScreenState;

    resendRequester = Requester();
    verifyRequester = Requester();
    
    timerController = TimerController(state);
  }

  @override
  void onBuild(){
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(timerController.status != AnimationStatus.forward) {
        timerController.start();
      }
    });
  }

  @override
  void onDispose(){
    timerController.dispose();
    pinController.dispose();

    HttpCenter.cancelAndClose(resendRequester?.httpRequester);
    HttpCenter.cancelAndClose(verifyRequester?.httpRequester);
  }
  ///========================================================================================================
  void tryAgain(State state){
    if(state is VerifyMobileScreenState) {
      state.stateController.mainStateAndUpdate(StateXController.state$loading);
    }
  }

  void onTimerEnd() {
    state.stateController.setStateData('activeBtn', true);
    state.stateController.updateMain();
  }

  void resendCode() {
    FocusHelper.hideKeyboardByUnFocus(state.context);

    Map<String, dynamic> js = {};
    js[Keys.request] = 'ResendVerifyCode';
    js[Keys.mobileNumber] = state.widget.mobileNumber;
    js[Keys.phoneCode] = state.widget.phoneCode;

    resendRequester?.bodyJson = js;
    resendRequester?.httpItem.pathSection = '/register';

    /*resendRequester?.httpRequestEvents.onAnyState = (req) async {
      await state.hideLoading();
    };*/

    resendRequester?.httpRequestEvents.onNetworkError = (req) async {
      SnackCenter.showSnack$errorCommunicatingServer(state.context);
    };

    resendRequester?.httpRequestEvents.onResponseError = (req, isOk) async {
      if(isOk){
        SnackCenter.showSnack$errorInServerSide(state.context);
      } else {
        SnackCenter.showSnack$serverNotRespondProperly(state.context);
      }
    };

    resendRequester?.httpRequestEvents.onResultOk = (req, data) async {
      SnackCenter.showFlashBarSuccess(state.context, state.tC('verifyCodeResend')!);

      state.stateController.setStateData('activeBtn', false);
      state.stateController.updateMain();

      timerController.reset();
      timerController.start();
    };

    resendRequester?.request(state.context);
  }

  void verify() async {
    FocusHelper.hideKeyboardByUnFocus(state.context);

    String code = pinController.text;

    if(code.isEmpty) {
      SheetCenter.showSheetOk(state.context, state.tC('pleaseFillOptions')!);
      return;
    }

    /*if(!(await NetManager.isConnected())){
		DialogCenter().showDialog$NetDisconnected(context);
		return;
	}*/

    Map<String, dynamic> js = {};
    js[Keys.request] = 'VerifyNewUser';
    js['code'] = code;
    js[Keys.mobileNumber] = state.widget.mobileNumber;
    js[Keys.phoneCode] = state.widget.phoneCode;

    verifyRequester?.bodyJson = js;
    verifyRequester?.httpItem.pathSection = '/register';

    verifyRequester?.httpRequestEvents.onAnyState = (req) async {
      await state.hideLoading();
    };

    verifyRequester?.httpRequestEvents.onNetworkError = (req) async {
      SnackCenter.showSnack$errorCommunicatingServer(state.context);
    };

    verifyRequester?.httpRequestEvents.onResponseError = (req, isOk) async {
      if(isOk){
        SnackCenter.showSnack$errorInServerSide(state.context);
      } else {
        SnackCenter.showSnack$serverNotRespondProperly(state.context);
      }
    };

    verifyRequester?.httpRequestEvents.manageResponse = (req, data) async {
      await state.hideLoading();

      String result = data[Keys.result] ?? Keys.error;

      if (result == Keys.ok) {
        removeVerifyMobile();
        MultiViewDialog.showWelcomeUser(state.context, data as Map<String, dynamic>);
        /*SnackCenter.showSnackSuccess(context,
					LocaleCenter.appLocalize.getCapitalize('thanksRegister')!,
					LocaleCenter.appLocalize.getCapitalize('thanksRegisterDescription')!);*/
      }
      else if (result == Keys.error) {
        int causeCode = data[Keys.causeCode] ?? 0;
        String cause = data[Keys.cause] ?? Keys.error;

        if (!HttpProcess.processCommonRequestErrors(state.context, causeCode, cause, data)) {
          if (cause == 'MobileNotFound') {
            SnackCenter.showFlashBarError(state.context, state.tC('phoneNumberNotExist')!);
          }
          else if (cause == 'NotCorrect') {
            SnackCenter.showFlashBarError(state.context, state.tC('incorrectVerifyCode')!);
          }
          else if (cause == 'TimeOut') {
            SnackCenter.showSnackNotice(state.context, state.tC('registerAgain')!);
          }
          else {
            SnackCenter.showSnack$serverNotRespondProperly(state.context);
          }
        }
      }
    };

    state.showLoading();
    verifyRequester?.request(state.context);
  }

  void removeVerifyMobile(){
    DbCenter.db.delete(DbCenter.tbKv, Conditions().add(Condition()..key = Keys.name..value = 'VerifyMobile'));
  }
}
