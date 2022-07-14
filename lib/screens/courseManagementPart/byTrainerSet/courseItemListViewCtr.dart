import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '/abstracts/viewController.dart';
import '/models/dataModels/courseModels/courseModel.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/screens/courseManagementPart/byTrainerSet/managementByTrainerScreen.dart';
import '/system/keys.dart';
import '/system/requester.dart';
import '/tools/app/appNavigator.dart';
import '/tools/centers/httpCenter.dart';
import '/tools/centers/sheetCenter.dart';
import '/tools/centers/snackCenter.dart';

class CourseItemListViewCtr implements ViewController {
  late CourseItemListViewState state;
  Requester? commonRequester;
  late CourseModel model;
  late UserModel userAdmin;


  @override
  void onInitState<E extends State>(E state){
    this.state = state as CourseItemListViewState;

    commonRequester = Requester();
    commonRequester?.requestPath = RequestPath.GetData;

    state.widget.stateList.add(state);
    model = state.widget.model;
    userAdmin = state.widget.admin;
  }

  @override
  void onBuild(){
  }

  @override
  void onDispose(){
    state.widget.stateList.remove(state);
    HttpCenter.cancelAndClose(commonRequester?.httpRequester);
  }
  ///========================================================================================================
  void uploadUserName(String username) {
    if(username.isEmpty){
      SheetCenter.showSheetNotice(state.context, state.tC('selectOneUsername')!);
      return;
    }

    Map<String, dynamic> js = {};
    js[Keys.request] = Keys.adminCommand;
    js[Keys.subRequest] = 'UpdateProfileUserName';
    js[Keys.requesterId] = userAdmin.userId;
    //js[Keys.forUserId] = model.userId;
    js[Keys.userName] = username;

    commonRequester?.requestPath = RequestPath.SetData;
    commonRequester?.bodyJson = js;

    commonRequester?.httpRequestEvents.onAnyState = (req) async {
      await state.hideLoading();
    };

    commonRequester?.httpRequestEvents.onNetworkError = (req) async {
      SnackCenter.showSnack$errorCommunicatingServer(state.context);
    };

    commonRequester?.httpRequestEvents.onResponseError = (req, isOk) async {
      if(isOk) {
        SnackCenter.showSnack$errorInServerSide(state.context);
      } else {
        SnackCenter.showSnack$errorCommunicatingServer(state.context);
      }
    };

    commonRequester?.httpRequestEvents.onResultError = (req, data) async {
      return false;
    };

    commonRequester?.httpRequestEvents.onResultOk = (req, data) async {
      //model.userName = username;
      AppNavigator.pop(state.context);
      //state.update();
    };

    state.showLoading();
    commonRequester?.request(state.context);
  }
}
