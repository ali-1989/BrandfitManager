import 'package:brandfit_manager/database/models/requestHybridModelDb.dart';
import 'package:brandfit_manager/screens/requestCoursePart/showPrograms/programViewScreen.dart';
import 'package:brandfit_manager/screens/requestCoursePart/showPrograms/treeScreen/treeScreen.dart';
import 'package:flutter/material.dart';

import '/abstracts/viewController.dart';
import '/managers/foodProgramManager.dart';
import '/models/dataModels/programModels/foodProgramModel.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/system/requester.dart';
import '/system/session.dart';
import '/tools/app/appNavigator.dart';
import '/tools/centers/httpCenter.dart';

class ProgramViewCtr implements ViewController {
  late ProgramViewScreenState state;
  late RequestHybridModelDb requestHybridModel;
  late UserModel user;
  late Requester commonRequester;
  late FoodProgramManager foodManager;
  late List<FoodProgramModel> programList = [];

  @override
  void onInitState<E extends State>(E state){
    this.state = state as ProgramViewScreenState;

    user = Session.getLastLoginUser()!;
    commonRequester = Requester();
    requestHybridModel = state.widget.requestHybridModel;

    foodManager = FoodProgramManager.managerFor(user.userId);
    programList = foodManager.allModelList.where((element) => element.requestId == requestHybridModel.id).toList();
  }

  @override
  void onBuild(){
  }

  @override
  void onDispose(){
    HttpCenter.cancelAndClose(commonRequester.httpRequester);
  }
  ///========================================================================================================
  void tryAgain(State state){
  }

  void tryLogin(State state){
  }

  void gotoTreeView(FoodProgramModel program){
    AppNavigator.pushNextPage(
        state.context,
        TreeFoodProgramScreen(
          requestHybridModel: state.widget.requestHybridModel,
          pupilUser: user,
          programModel: program,
        ),
        name: TreeFoodProgramScreen.screenName
    );
  }
}
