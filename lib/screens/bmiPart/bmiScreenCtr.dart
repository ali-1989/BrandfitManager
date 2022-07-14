import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/widgets/horizontalPicker.dart';

import '/abstracts/viewController.dart';
import '/screens/bmiPart/bmiScreen.dart';
import '/system/session.dart';
import '/tools/bmiTools.dart';

class BmiScreenCtr implements ViewController {
  late BmiScreenState state;
  bool isGuest = true;
  HorizontalPickerController wBmiController = HorizontalPickerController();
  HorizontalPickerController hBmiController = HorizontalPickerController();
  HorizontalPickerController wBmrController = HorizontalPickerController();
  HorizontalPickerController hBmrController = HorizontalPickerController();
  HorizontalPickerController aBmrController = HorizontalPickerController();
  KeyGenerator bmiCodeGen = KeyGenerator(length: 10);
  KeyGenerator bmrCodeGen = KeyGenerator(length: 10);
  String bmiResultText = '-';
  double bmiResultNum = 0;
  double bmrResultNum = 0;
  double bmrRegResultNum = 0;
  double selectedHeight = 170;
  double selectedWeight = 70;
  int selectedGender = 0; //0: male
  int selectedActivityRate = 0;
  int selectedAge = 27;

  @override
  void onInitState<E extends State>(E state){
    this.state = state as BmiScreenState;

    isGuest = !Session.hasAnyLogin();
    final user = Session.getLastLoginUser();

    if(user != null){
      selectedGender = user.sex -1;
      selectedGender = MathHelper.maxInt(selectedGender, 0);

      selectedAge = DateHelper.calculateAge(user.birthDate, def: selectedAge);

      selectedHeight = user.fitnessDataModel.height?? selectedHeight;
      selectedWeight = user.fitnessDataModel.weight?? selectedWeight;
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      state.tabController.addListener(() {
        //if(tabController.index == 0) {
        calculateBmi();
        calculateBmr();

        bmiCodeGen.rebuild();
        bmrCodeGen.rebuild();
        state.stateController.updateMain();
      });
    });

    calculateBmi();
  }

  @override
  void onBuild(){
  }

  @override
  void onDispose(){
  }
  ///========================================================================================================
  void calculateBmi(){
    bmiResultNum = BmiTools.calculateBmi(selectedHeight, selectedWeight);
    bmiResultText = BmiTools.bmiDescription(state.context, bmiResultNum);
  }

  void calculateBmr(){
    bmrResultNum = BmiTools.calculateBmr(selectedHeight, selectedWeight, selectedAge, selectedGender);
    bmrRegResultNum = BmiTools.calculateBmrRegister(selectedHeight, selectedWeight, selectedAge, selectedGender, selectedActivityRate);
  }
}
