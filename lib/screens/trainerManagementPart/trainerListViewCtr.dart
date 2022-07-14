import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '/abstracts/viewController.dart';
import '/models/dataModels/usersModels/appUserModel.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/screens/trainerManagementPart/trainerManagementScreen.dart';
import '/screens/trainerManagementPart/userFullInfoScreen.dart';
import '/tools/app/appNavigator.dart';

class TrainerListViewCtr implements ViewController {
  late TrainerListViewState state;
  late AppUserModel pupilModel;
  late UserModel user;


  @override
  void onInitState<E extends State>(E state){
    this.state = state as TrainerListViewState;

    state.widget.stateList.add(state);
    pupilModel = state.widget.model;
    user = state.widget.admin;
  }

  @override
  void onBuild(){
  }

  @override
  void onDispose(){
    state.widget.stateList.remove(state);
  }
  ///========================================================================================================
  void gotoFullInfoScreen(){
    AppNavigator.pushNextPage(
        state.context,
        UserFullInfoScreen(userModel: pupilModel,),
        name: UserFullInfoScreen.screenName
    ).then((value) {
      state.update();
    });
  }
}
