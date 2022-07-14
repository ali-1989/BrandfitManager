import 'package:flutter/material.dart';

import '/abstracts/viewController.dart';
import '/screens/settings/calendarScreen.dart';
import '/screens/settings/fontChange.dart';
import '/screens/settings/selectLanguage.dart';
import '/screens/settings/settingsScreen.dart';
import '/screens/settings/themeChange.dart';
import '/tools/app/appNavigator.dart';

class SettingsScreenCtr extends ViewController {
  late SettingsScreenState state;

  @override
  void onInitState<E extends State>(covariant E state) {
    this.state = state as SettingsScreenState;
  }

  @override
  void onBuild() {
  }

  @override
  void onDispose() {
  }
  ///====================================================================================
  void gotoDateCalendarPage(){
    AppNavigator.pushNextPage<bool>(state.context,
        CalendarScreen(),
        arguments: state,
        name: CalendarScreen.screenName
    );
  }

  void gotoSelectLanguagePage(){
    AppNavigator.pushNextPage<bool>(state.context,
        SelectLanguageScreen(),
        arguments: this,
        name: SelectLanguageScreen.screenName
    ).then((value){
      if(value != null && value) {
        state.stateController.updateMain();
      }
    });
  }

  void gotoFontPage(){
    AppNavigator.pushNextPage<bool>(state.context,
        FontScreen(),
        arguments: state,
        name: FontScreen.screenName
    );
  }

  void gotoThemePage(){
    AppNavigator.pushNextPage<bool>(state.context,
        ThemeScreen(),
        arguments: state,
        name: ThemeScreen.screenName
    ).then((value){
      if(value != null && value) {
        state.stateController.updateMain();
      }
    });
  }

}
