import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:iris_tools/modules/stateManagers/stateX.dart';

import '/abstracts/viewController.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/screens/courseManagementPart/courseManagementScreen.dart';
import '/screens/courseManagementPart/withoutSet/managementWithoutSetScreen.dart';
import '/system/session.dart';
import '/tools/app/appNavigator.dart';

class CourseManagementScreenCtr implements ViewController {
  late CourseManagementScreenState state;
  late UserModel? userAdmin;


  void onInitState<E extends State>(E state){
    this.state = state as CourseManagementScreenState;

    Session.addLogoffListener(onLogout);
    userAdmin = Session.getLastLoginUser();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(userAdmin == null){
        AppNavigator.pop(state.context);
        return;
      }
      else {
        AppNavigator.replaceCurrentRoute(state.context,
            CManagementWithoutSetScreen(),
            name: CManagementWithoutSetScreen.screenName
        );
      }
    });
  }

  void onBuild(){
    userAdmin = Session.getLastLoginUser();
  }

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
    if(state is CourseManagementScreenState) {
      state.stateController.mainStateAndUpdate(StateXController.state$loading);
    }
  }
}
