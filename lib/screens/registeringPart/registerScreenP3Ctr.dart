import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:iris_tools/api/helpers/focusHelper.dart';

import '/abstracts/viewController.dart';
import '/screens/registeringPart/registerScreen.dart';
import '/screens/registeringPart/registerScreenCtr.dart';
import '/tools/centers/snackCenter.dart';

class RegisterScreenP3Ctr implements ViewController {
  late RegisterScreenP3State state;
  late RegisterScreenCtr parentCtr;
  int selectedGender = -1;
  var inputAnimationDelay = const Duration(milliseconds: 400);


  @override
  void onInitState<E extends State>(E state){
    this.state = state as RegisterScreenP3State;

    parentCtr = state.widget.parentCtr;
  }

  @override
  void onBuild(){
  }

  @override
  void onDispose(){
  }
  ///========================================================================================================
  void tryAgain(State state){
    if(state is RegisterScreenP3State) {
      state.stateController.updateMain();
    }
  }

  void gotoNextPage() async {
    FocusHelper.hideKeyboardByService();

    if (selectedGender < 0) {
      SnackCenter.showSnackNotice(state.context, state.tC('selectYourGender')!);
      return;
    }

    parentCtr.registeringModel.gender = selectedGender;

    parentCtr.jumpNext();
  }
}
