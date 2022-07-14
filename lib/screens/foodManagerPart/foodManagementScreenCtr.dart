import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:iris_tools/modules/stateManagers/stateX.dart';

import '/abstracts/viewController.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/screens/foodManagerPart/foodManagementScreen.dart';
import '/system/session.dart';
import '/tools/app/appNavigator.dart';

class FoodManagementScreenCtr implements ViewController {
  late FoodManagementScreenState state;
  late UserModel? userAdmin;


  @override
  void onInitState<E extends State>(E state){
    this.state = state as FoodManagementScreenState;

    Session.addLogoffListener(onLogout);
    userAdmin = Session.getLastLoginUser();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(userAdmin == null){
        AppNavigator.pop(state.context);
        return;
      }
    });
  }

  @override
  void onBuild(){
    userAdmin = Session.getLastLoginUser();
  }

  @override
  void onDispose(){
    //HttpCenter.cancelAndClose(noneRequester?.httpRequester);
    Session.removeLogoffListener(onLogout);
  }

  void onLogout(user){
    //HttpCenter.cancelAndClose(noneRequester?.httpRequester);
    AppNavigator.popRoutesUntilRoot(state.context);
  }
  ///========================================================================================================
  void tryAgain(State state){
    if(state is FoodManagementScreenState) {
      state.stateController.mainStateAndUpdate(StateXController.state$loading);
    }
  }
}
