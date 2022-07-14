import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import '/abstracts/viewController.dart';
import '/database/models/userAdvancedModelDb.dart';
import '/screens/chatPart/filteringPart/filteringPage.dart';
import '/system/keys.dart';
import '/system/queryFiltering.dart';
import '/system/requester.dart';
import '/tools/app/appNavigator.dart';
import '/tools/centers/httpCenter.dart';

class FilteringCtr implements ViewController {
  late FilteringScreenState state;
  late Requester commonRequester;
  late FloatingSearchBarController searchBarCtr;
  List<UserAdvancedModelDb> userList = [];
  bool showProgress = false;
  late FilterRequest filterRequest;

  @override
  void onInitState<E extends State>(E state){
    this.state = state as FilteringScreenState;

    filterRequest = FilterRequest();
    filterRequest.limit = 100;

    commonRequester = Requester();

    searchBarCtr = FloatingSearchBarController();

    prepareFilterOptions();
  }

  @override
  void onBuild(){
  }

  @override
  void onDispose(){
    HttpCenter.cancelAndClose(commonRequester.httpRequester);
  }

  void prepareFilterOptions(){
    filterRequest.addSearchView(SearchKeys.global);
  }
  ///========================================================================================================
  void onClickOnUser(UserAdvancedModelDb user){
    FocusHelper.hideKeyboardByService();

    AppNavigator.pop(state.context, result: user);
  }

  void requestUser(String searchText) {

    if(searchText.length < 2){
      showProgress = false;
      state.stateController.updateMain();
      return;
    }

    filterRequest.setTextToSelectedSearch(searchText);
    userList.clear();

    final js = <String, dynamic>{};
    js[Keys.request] = 'SearchOnPupilTrainer';
    js[Keys.filtering] = filterRequest.toMap();

    commonRequester.requestPath = RequestPath.GetData;
    commonRequester.bodyJson = js;

    commonRequester.httpRequestEvents.onFailState = (req) async {
      showProgress = false;
      state.stateController.updateMain();
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      return true;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      showProgress = false;

      List? list = data[Keys.resultList];
      String? domain = data[Keys.domain];

      if(list != null) {
        for (final row in list) {
          final r = UserAdvancedModelDb.fromMap(row, domain: domain);

          userList.add(r);
        }
      }

      Future.delayed(Duration(milliseconds: 1000), (){
        searchBarCtr.close();
      });

      state.stateController.updateMain();
    };

    showProgress = true;
    state.stateController.updateMain();
    commonRequester.request(state.context);
  }
}
