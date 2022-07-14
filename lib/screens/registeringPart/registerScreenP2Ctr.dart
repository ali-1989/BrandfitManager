import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:iris_tools/api/helpers/focusHelper.dart';

import '/abstracts/viewController.dart';
import '/screens/registeringPart/registerScreen.dart';
import '/screens/registeringPart/registerScreenCtr.dart';
import '/tools/centers/localeCenter.dart';
import '/tools/centers/snackCenter.dart';

class RegisterScreenP2Ctr implements ViewController {
  late RegisterScreenP2State state;
  late RegisterScreenCtr parentCtr;
  GlobalKey<FormState> formKeyCtr = GlobalKey<FormState>();
  TextEditingController nameCtl = TextEditingController();
  TextEditingController familyCtl = TextEditingController();
  var inputAnimationDelay = const Duration(milliseconds: 400);


  @override
  void onInitState<E extends State>(E state){
    this.state = state as RegisterScreenP2State;

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
    if(state is RegisterScreenP2State) {
      state.stateController.updateMain();
    }
  }

  String? validation(TextEditingController controller) {
    String text = controller.text.trim();

    if (controller == nameCtl) {
      if (text.isEmpty) {
        return LocaleCenter.appLocalize.translate('enterYourName')!;
      }
    }

    if (controller == familyCtl) {
      if (text.isEmpty) {
        return LocaleCenter.appLocalize.translate('enterFamily')!;
      }
    }

    return null;
  }

  void gotoNextPage() async {
    FocusHelper.hideKeyboardByUnFocus(state.context);

    if (!(formKeyCtr.currentState?.validate()?? true)) {
      SnackCenter.showSnackNotice(state.context, state.tC('pleaseFillOptions')!);
      return;
    }

    parentCtr.registeringModel.name = nameCtl.text.trim();
    parentCtr.registeringModel.family = familyCtl.text.trim();

    parentCtr.jumpNext();
  }
}
