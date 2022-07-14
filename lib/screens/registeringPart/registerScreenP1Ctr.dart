import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:iris_tools/api/checker.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';

import '/abstracts/viewController.dart';
import '/managers/settingsManager.dart';
import '/screens/commons/countrySelect.dart';
import '/screens/registeringPart/registerScreen.dart';
import '/screens/registeringPart/registerScreenCtr.dart';
import '/system/extensions.dart';
import '/tools/app/appNavigator.dart';
import '/tools/centers/localeCenter.dart';
import '/tools/centers/snackCenter.dart';
import '/tools/countryTools.dart';

class RegisterScreenP1Ctr implements ViewController {
  late RegisterScreenP1State state;
  late RegisterScreenCtr parentCtr;
  GlobalKey<FormState> formKeyCtr = GlobalKey<FormState>();
  TextEditingController mobileCtl = TextEditingController();
  TextEditingController userNameCtl = TextEditingController();
  TextEditingController passwordCtl = TextEditingController();
  TextEditingController password2Ctl = TextEditingController();
  String selectedCountry = 'Iran';
  String selectedCountryIso = 'IR';
  String selectedCountryCode = '+98';
  var inputAnimationDelay = const Duration(milliseconds: 400);


  @override
  void onInitState<E extends State>(E state){
    this.state = state as RegisterScreenP1State;

    parentCtr = state.widget.parentCtr;
    fetchCountry();
  }

  @override
  void onBuild(){
  }

  @override
  void onDispose(){
  }
  ///========================================================================================================
  void tryAgain(State state){
    if(state is RegisterScreenP1State) {
      state.stateController.mainStateAndUpdate(StateXController.state$loading);
    }
  }

  void fetchCountry() {
    Map all = CountryTools.countriesMap!;

    //it is better remove this line for international
    String? cIso = SettingsManager.settingsModel.appLocale.countryCode;
    cIso = System.getPlatformLocale().countryCode;
    cIso ??= System.getLocalizationsCountryCode(state.context);

    if(cIso != null) {
      bool find = false;
      all.entries.firstWhereSafe((country) {
        if(country.value['iso'] == cIso) {
          selectedCountryIso = cIso!;
          selectedCountryCode = country.value['phoneCode'];
          selectedCountry = country.key + (country.value['nativeName'] != null? ' (${country.value['nativeName']})': '');
          find = true;
          return true;
        }

        return false;
      });

      if(find) {
        state.stateController.updateMain();
      }
    }
  }

  String? validation(TextEditingController controller) {
    String text = controller.text.trim();

    if (controller == mobileCtl) {
      if (text.isEmpty) {
        return LocaleCenter.appLocalize.translate('enterMobile')!;
      }

      if (text.length < 11 || !Checker.validateMobile(text)) {
        return LocaleCenter.appLocalize.translate('enterMobileCorrectly')!;
      }
    }

    if (controller == userNameCtl) {
      if (text.isEmpty) {
        return LocaleCenter.appLocalize.translate('selectOneUsername')!;
      }

      if (text.length < 3) {
        return LocaleCenter.appLocalize.translate('usernameMustBigger2Char')!;
      }
    }

    if (controller == passwordCtl) {
      if (text.isEmpty) {
        return LocaleCenter.appLocalize.translate('selectPassword')!;
      }

      if (text.length < 4 || text.length > 12) {
        return LocaleCenter.appLocalize.translate('passwordMust4Char')!;
      }
    }

    if (controller == password2Ctl) {
      if (text.isEmpty) {
        return LocaleCenter.appLocalize.translate('selectPassword')!;
      }

      if (text != passwordCtl.text.trim()) {
        return LocaleCenter.appLocalize.translate('passwordsNotSame')!;
      }
    }

    return null;
  }

  void clickOnHaveAccount(){
    parentCtr.loginBtn();
  }

  void openSelectCountry(){
    AppNavigator.pushNextPage(
        state.context,
        CountrySelectScreen(),
        name: CountrySelectScreen.screenName
    ).then((value) {
      final country = value as Map;

      if(country.isNotEmpty){
        selectedCountry = country['name'] + (country['native_name']!= null? ' (${country['native_name']})': '');
        selectedCountryCode = country['phone_code'];
        selectedCountryIso = country['iso'];

        state.stateController.updateMain();
      }
    });
  }

  void gotoNextPage() async {
    FocusHelper.hideKeyboardByUnFocus(state.context);

    String mobile = mobileCtl.text.trim();

    if (mobile.isEmpty) {
      SnackCenter.showSnackNotice(state.context, state.tC('enterMobile')!);
      return;
    }

    mobile = selectedCountryCode + mobile;
    if (!Checker.validateMobile(mobile)) {
      SnackCenter.showSnackNotice(state.context, state.tC('enterMobileCorrectly')!);
      return;
    }

    if (!(formKeyCtr.currentState?.validate()?? true)) {
      SnackCenter.showSnackNotice(state.context, LocaleCenter.appLocalize.translateCapitalize('pleaseFillOptions')!);
      return;
    }

    parentCtr.registeringModel.userName = userNameCtl.text.trim();
    parentCtr.registeringModel.password = passwordCtl.text.trim();
    parentCtr.registeringModel.mobile = mobileCtl.text.trim();
    parentCtr.registeringModel.selectedCountryCode = selectedCountryCode;
    parentCtr.registeringModel.selectedCountryIso = selectedCountryIso;

    parentCtr.jumpNext();
    //AppNavigator.pushNextPage(context, RegisterScreenP2(parentState), name: RegisterScreenP2.screenName);
  }
}
