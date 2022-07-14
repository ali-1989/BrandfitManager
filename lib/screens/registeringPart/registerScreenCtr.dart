import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:iris_db/iris_db.dart';
import 'package:iris_tools/api/checker.dart';
import 'package:iris_tools/api/converter.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';

import '/abstracts/stateBase.dart';
import '/abstracts/viewController.dart';
import '/models/dataModels/registeringModel.dart';
import '/screens/loginPart/loginScreen.dart';
import '/screens/registeringPart/registerScreen.dart';
import '/screens/registeringPart/verifyMobileScreen.dart';
import '/system/httpProcess.dart';
import '/system/keys.dart';
import '/system/requester.dart';
import '/tools/app/appNavigator.dart';
import '/tools/centers/dbCenter.dart';
import '/tools/centers/httpCenter.dart';
import '/tools/centers/routeCenter.dart';
import '/tools/centers/sheetCenter.dart';
import '/tools/centers/snackCenter.dart';

class RegisterScreenCtr implements ViewController {
  late RegisterScreenState state;
  Requester? registerRequester;
  //GlobalKey<NavigatorState> internalNavKey = GlobalKey<NavigatorState>();
  RegisteringModel registeringModel = RegisteringModel();
  PageController pageController = PageController(initialPage: 0, keepPage: true);


  @override
  void onInitState<E extends State>(E state){
    this.state = state as RegisterScreenState;

    registerRequester = Requester();
    registerRequester?.methodType = MethodType.Post;
  }

  @override
  void onBuild(){
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchMobileNumber();
    });
  }

  @override
  void onDispose(){
    HttpCenter.cancelAndClose(registerRequester?.httpRequester);
  }
  ///========================================================================================================
  void tryAgain(State state){
    if(state is RegisterScreenState) {
      state.stateController.mainStateAndUpdate(StateXController.state$loading);
    }
  }

  void jumpNext(){
    pageController.jumpToPage((pageController.page!).round() +1);
  }

  void jumpPre(){
    pageController.jumpToPage((pageController.page!).round() -1);
  }

  void saveMobileNumber(String mobile, String pre) {
    var kv = {};
    kv[Keys.name] = 'VerifyMobile';
    kv[Keys.mobileNumber] = mobile;
    kv[Keys.phoneCode] = pre;

    DbCenter.db.insertOrUpdate(DbCenter.tbKv, kv,
        Conditions().add(Condition()..key = Keys.name..value = 'VerifyMobile'));
  }

  void fetchMobileNumber() {
    var res = DbCenter.db.query(DbCenter.tbKv,
        Conditions().add(Condition()..key = Keys.name..value = 'VerifyMobile'));

    if (res.isEmpty) {
      return;
    }

    Map row = res.first;

    if(row[Keys.mobileNumber] == null) {
      return;
    }

    String mobile = row[Keys.mobileNumber];
    String preMobile = row[Keys.phoneCode];

    if (!Checker.validateMobile(preMobile + mobile)) {
      return;
    }

    state.stateController.setObject('hasMobileNumber', true);
    state.stateController.setObject(Keys.mobileNumber, mobile);
    state.stateController.setObject(Keys.phoneCode, preMobile);
    state.stateController.setOverlay(state.getMobileView);
  }

  void loginBtn() {
    if (AppNavigator.canPopCurrent(state.context)) {
      AppNavigator.replaceCurrentRoute(state.context, LoginScreen(), name: LoginScreen.screenName);
    } else {
      RouteCenter.navigateRouteScreen(LoginScreen.screenName);
    }
  }

  void requestRegistering(StateBase stateInp) async {
    FocusHelper.hideKeyboardByService();
    //FocusHelper.hideKeyboardByUnFocus(state.context);

    /*if (!(await NetManager.isConnected())) {
      DialogCenter().showDialog$NetDisconnected(stateInp.context);
      return;
    }*/

    String name = registeringModel.name;
    String family = registeringModel.family;
    String mobile = registeringModel.mobile;
    String userName = registeringModel.userName;
    String password = registeringModel.password;

    Map<String, dynamic> js = {};
    js[Keys.request] = 'RegisterNewUser';
    js[Keys.name] = name;
    js['family'] = family;
    js[Keys.mobileNumber] = Converter.resolveMobile(mobile);
    js[Keys.phoneCode] = registeringModel.selectedCountryCode;
    js[Keys.countryIso] = registeringModel.selectedCountryIso;
    js['sex'] = registeringModel.gender +1;
    js[Keys.userName] = userName;
    js['password'] = password;
    js['birthdate'] = registeringModel.birthDate;
    js['is_exercise_trainer'] = registeringModel.isExerciseTrainer;
    js['is_food_trainer'] = registeringModel.isFoodTrainer;

    registerRequester?.bodyJson = js;
    registerRequester?.httpItem.pathSection = '/register';

    registerRequester?.httpRequestEvents.onNetworkError = (req) async {
      await stateInp.hideLoading();
      //DialogCenter().showErrorDialog(context, null, t('errorCommunicatingServer')!);
      SnackCenter.showSnack$errorCommunicatingServer(stateInp.context);
    };

    registerRequester?.httpRequestEvents.onResponseError = (req, isOk) async {
      await stateInp.hideLoading();
      //DialogCenter().showErrorDialog(context, null, t('serverNotRespondProperly')!);
      if(isOk){
        SnackCenter.showSnack$errorInServerSide(state.context);
      } else {
        SnackCenter.showSnack$serverNotRespondProperly(state.context);
      }
    };

    registerRequester?.httpRequestEvents.onResultError = (req, data) async {
      stateInp.hideLoading().then((value){
        SnackCenter.showSnack$errorInServerSide(stateInp.context);
      });

      return true;
    };

    registerRequester?.httpRequestEvents.manageResponse = (req, data) async {
      await stateInp.hideLoading();

      String result = data[Keys.result] ?? Keys.error;

      if (result == 'Registered') {
        String mobileNumber = data[Keys.mobileNumber] ?? '0';
        String countryCode = data[Keys.phoneCode] ?? '0';
        saveMobileNumber(mobileNumber, countryCode);
        stateInp.update();

        AppNavigator.pushNextPage(stateInp.context,
            VerifyMobileScreen(mobileNumber, countryCode),
            name: VerifyMobileScreen.screenName);
      }
      else if (result == Keys.error) {
        int causeCode = data[Keys.causeCode] ?? 0;
        String cause = data[Keys.cause] ?? Keys.error;

        if(!HttpProcess.processCommonRequestErrors(stateInp.context, causeCode, cause, data)) {
          if (cause == 'ExistUserName') {
            SheetCenter.showSheetOk(stateInp.context, state.tC('thisUserNameExist')!);
            pageController.jumpToPage(0);
          }
          else if (cause == 'NotAcceptUserName') {
            SheetCenter.showSheetOk(stateInp.context, state.tC('thisUserNameIsNotValid')!);
            pageController.jumpToPage(0);
          }
          else if (cause == 'ExistMobile') {
            SheetCenter.showSheetOk(stateInp.context, state.tC('thisMobileExistRestore')!);
            pageController.jumpToPage(0);
          }
          else {
            SnackCenter.showSnack$serverNotRespondProperly(stateInp.context);
          }
        }
      }
    };

    stateInp.showLoading();
    registerRequester?.request(stateInp.context);
  }
}
