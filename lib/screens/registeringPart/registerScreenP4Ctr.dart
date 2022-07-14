import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:iris_tools/dateSection/calendarTools.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import '/abstracts/viewController.dart';
import '/screens/registeringPart/registerScreen.dart';
import '/screens/registeringPart/registerScreenCtr.dart';
import '/tools/centers/sheetCenter.dart';
import '/tools/dateTools.dart';

class RegisterScreenP4Ctr implements ViewController {
  late RegisterScreenP4State state;
  late RegisterScreenCtr parentCtr;
  late DateTime birthdate;
  late int selectedYear;
  int selectedMonth = 1;
  int selectedDay = 1;
  int maxDayOfMonth = 28;
  int age = 0;
  bool isAcceptTerms = true;
  var inputAnimationDelay = const Duration(milliseconds: 400);


  @override
  void onInitState<E extends State>(E state){
    this.state = state as RegisterScreenP4State;

    parentCtr = state.widget.parentCtr;
    selectedYear = DateTools.calMaxBirthdateYear();
    birthdate = DateTools.getDateByCalendar(selectedYear, selectedMonth, selectedDay)!;
    maxDayOfMonth = DateTools.calMaxMonthDay(selectedYear, selectedMonth);
    calcAge();
  }

  @override
  void onBuild(){
  }

  @override
  void onDispose(){
  }
  ///========================================================================================================
  void tryAgain(State state){
    if(state is RegisterScreenP4State) {
      state.stateController.updateMain();
    }
  }

  void calcAge(){
    age = DateHelper.calculateAge(birthdate);
  }

  void calcBirthdate(){
    maxDayOfMonth = DateTools.calMaxMonthDay(selectedYear, selectedMonth);

    if(selectedDay > maxDayOfMonth){
      selectedDay = maxDayOfMonth;
    }

    birthdate = DateTools.getDateByCalendar(selectedYear, selectedMonth, selectedDay)!;
    calcAge();
  }

  void changeCalendar(CalendarType cal){
    DateTools.saveAppCalendar(cal);

    maxDayOfMonth = DateTools.calMaxMonthDay(selectedYear, selectedMonth);

    final list = DateTools.splitDateByCalendar(birthdate);
    selectedYear = list[0];
    selectedMonth = list[1];
    selectedDay = list[2];
  }

  void gotoNextPage() async {
    parentCtr.registeringModel.birthDate = DateHelper.dateOnlyToStamp(birthdate);

    if(!isAcceptTerms){
      SheetCenter.showSheetOk(state.context, '${state.tInMap('registeringPage', 'mustAcceptTerm')}');
      return;
    }

    parentCtr.requestRegistering(state);
    //parentCtr.jumpNext();
  }
}
