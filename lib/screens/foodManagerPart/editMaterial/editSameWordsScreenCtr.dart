import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:iris_tools/api/helpers/focusHelper.dart';

import '/abstracts/viewController.dart';
import '/models/dataModels/foodModels/materialModel.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/screens/commons/topInputFieldScreen.dart';
import '/screens/foodManagerPart/editMaterial/editSameWordsScreen.dart';
import '/system/keys.dart';
import '/system/requester.dart';
import '/system/session.dart';
import '/tools/app/appNavigator.dart';
import '/tools/centers/httpCenter.dart';
import '/tools/centers/sheetCenter.dart';

class EditSameWordScreenCtr implements ViewController {
  late EditSameWordsScreenState state;
  late Requester commonRequester;
  late UserModel user;
  late MaterialModel materialModel;
  List<String> alternatives = [];


  @override
  void onInitState<E extends State>(E state){
    this.state = state as EditSameWordsScreenState;

    materialModel = state.widget.materialModel;
    user = Session.getLastLoginUser()!;
    alternatives.addAll(materialModel.alternatives);

    commonRequester = Requester();
    commonRequester.requestPath = RequestPath.SetData;
  }

  @override
  void onBuild(){
  }

  @override
  void onDispose(){
    HttpCenter.cancelAndClose(commonRequester.httpRequester);
  }
  ///========================================================================================================
  void onAddClick(){
    AppNavigator.pushNextTransparentPage(
        state.context,
        TopInputFieldScreen(),
        name: TopInputFieldScreen.screenName
    ).then((value) {
      if(value != null){
        alternatives.add(value);
        state.update();
      }
    });
  }
  void uploadSameWords() {
    FocusHelper.hideKeyboardByUnFocus(state.context);

    final js = <String, dynamic>{};
    js[Keys.request] = Keys.adminCommand;
    js[Keys.requesterId] = user.userId;
    js[Keys.subRequest] = 'UpdateFoodMaterialAlternatives';
    js['id'] = materialModel.id;
    js['alternatives'] = alternatives;

    commonRequester.bodyJson = js;

    commonRequester.httpRequestEvents.onNetworkError = (req) async {
      await state.hideLoading();
      SheetCenter.showSheet$ErrorCommunicatingServer(state.context);
    };

    commonRequester.httpRequestEvents.onResponseError = (req, isOk) async {
      await state.hideLoading();
      SheetCenter.showSheet$ServerNotRespondProperly(state.context);
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      await state.hideLoading();

      return false;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      await state.hideLoading();

      materialModel.alternatives = alternatives;
      AppNavigator.pop(state.context, result: Keys.ok);
    };

    state.showLoading(canBack: false);
    commonRequester.request(state.context);
  }
}

