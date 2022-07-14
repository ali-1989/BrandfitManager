import 'dart:async';

import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:iris_download_manager/downloadManager/downloadManager.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' as pull;

import '/abstracts/viewController.dart';
import '/models/dataModels/courseModels/courseModel.dart';
import '/models/dataModels/usersModels/appUserModel.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/screens/courseManagementPart/byTrainerSet/managementByTrainerScreen.dart';
import '/screens/loginPart/loginScreen.dart';
import '/screens/userManagementPart/userManagementScreen.dart';
import '/system/downloadUpload.dart';
import '/system/keys.dart';
import '/system/multiViewDialog.dart';
import '/system/queryFiltering.dart';
import '/system/requester.dart';
import '/system/session.dart';
import '/tools/app/appNavigator.dart';
import '/tools/centers/httpCenter.dart';
import '/views/filterViews/filterPanelView.dart';
import '/views/filterViews/searchPanelView.dart';
import '/views/filterViews/sortPanelView.dart';

class CManagementByTrainerScreenCtr implements ViewController {
  late CManagementByTrainerScreenState state;
  Requester? itemRequester;
  UserModel? userAdmin;
  late TextEditingController searchEditController;
  var listChildren = <CourseItemListViewState>[];
  List<CourseModel> itemList = [];
  late double toolbarHeight;
  late Size mediaQuery;
  late FilterRequest filterRequest;
  late StreamSubscription downloadListenerSubscription;
  var pullLoadCtr = pull.RefreshController();


  @override
  void onInitState<E extends State>(E state){
    this.state = state as CManagementByTrainerScreenState;

    toolbarHeight = 200.0;
    itemRequester = Requester();
    itemRequester?.requestPath = RequestPath.GetData;

    filterRequest = FilterRequest();
    filterRequest.limit = 40;

    prepareTools();

    Session.addLogoffListener(onLogout);
    downloadListenerSubscription = DownloadUpload.downloadManager.addListener(onDownloadListener);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(userAdmin == null){
        AppNavigator.pop(state.context);
        return;
      }
      else {
        requestCourses();
      }
    });
  }

  @override
  void onBuild(){
    userAdmin = Session.getLastLoginUser();
  }

  @override
  void onDispose(){
    Session.removeLogoffListener(onLogout);
    downloadListenerSubscription.cancel();
    HttpCenter.cancelAndClose(itemRequester?.httpRequester);
  }

  void onLogout(user){
    HttpCenter.cancelAndClose(itemRequester?.httpRequester);
    state.stateController.updateMain();
  }

  void onDownloadListener(DownloadItem di) {
    if(di.isInCategory(DownloadCategory.userProfile.toString())){
      if(!di.isComplete()){
        return;
      }

      AppUserModel model = di.attach;
      var f = FileHelper.getFile(model.profileImagePath!);
      model.profileFile = f;

      for(var v in listChildren){
      }
    }
  }//todo del

  void prepareTools(){
    filterRequest.addSortView(SortKeys.registrationKey, isAsc: false, isDefault: true);
    filterRequest.addSortView(SortKeys.registrationKey, isAsc: true);

    filterRequest.addSearchView(SearchKeys.titleKey);
    filterRequest.addSearchView(SearchKeys.descriptionKey);
    filterRequest.addSearchView(SearchKeys.userNameKey);
    filterRequest.selectedSearchKey = SearchKeys.titleKey;

    final f1 = FilteringViewModel();
    f1.key = FilterKeys.byExerciseMode;
    f1.type = FilterType.checkbox;

    final f2 = FilteringViewModel();
    f2.key = FilterKeys.byFoodMode;
    f2.type = FilterType.checkbox;

    final f3 = FilteringViewModel();
    f3.key = FilterKeys.byBlocked;
    f3.type = FilterType.radio;
    f3.subViews.add(FilterSubViewModel()..key = FilterKeys.blockedOp);
    f3.subViews.add(FilterSubViewModel()..key = FilterKeys.noneBlockedOp);

    filterRequest.addFilterView(f1);
    filterRequest.addFilterView(f2);
    filterRequest.addFilterView(f3);
  }
  ///========================================================================================================
  void tryAgain(State state){
    if(state is CManagementByTrainerScreenState) {
      state.stateController.mainStateAndUpdate(StateXController.state$loading);

      requestCourses();
    }
  }

  void tryLogin(State state){
    if(state is UserManagementScreenState) {
      AppNavigator.replaceCurrentRoute(state.context, LoginScreen(), name: LoginScreen.screenName);
    }
  }

  void onSortClick(){
    var oldItem = filterRequest.getSortViewSelected();

    MultiViewDialog fd = MultiViewDialog(
      SortPanelView(filterRequest),
      'Sort',
      screenBackground: Colors.black.withAlpha(100),
      useExpanded: false,
    );

    fd.showWithCloseButton(
      state.context,
      canBack: true,
      alignment: Alignment.topCenter,
      padding: EdgeInsets.fromLTRB(0, 50, 0, 10),
    ).then((value) {
      if(oldItem != filterRequest.getSortViewSelected()) {
        resetRequest();
      }
    });
  }

  void onSearchOptionClick(){
    MultiViewDialog fd = MultiViewDialog(
        SearchPanelView(filterRequest),
        'SearchBy',
        screenBackground: Colors.black.withAlpha(100)
    );

    fd.showWithCloseButton(
      state.context,
      canBack: true,
      alignment: Alignment.topCenter,
      padding: EdgeInsets.fromLTRB(0, 50, 0, 10),
    ).then((value) {
      state.appBarRefresher.update();
    });
  }

  void onFilterOptionClick(){
    final oldValue = filterRequest.toMapFiltering();

    MultiViewDialog fd = MultiViewDialog(
      FilterPanelView(filterRequest),
      'FilterBy',
      screenBackground: Colors.black.withAlpha(100),
      useExpanded: true,
    );

    fd.showWithCloseButton(
      state.context,
      canBack: true,
      alignment: Alignment.topCenter,
      padding: EdgeInsets.fromLTRB(0, 50, 0, 10),
    ).then((value) {
      state.appBarRefresher.update();

      if(!DeepCollectionEquality.unordered().equals(oldValue, filterRequest.toMapFiltering())) {
        resetRequest();
      }
    });
  }

  void onRefresh() async{
    itemList.clear();

    requestCourses();
  }

  Future<void> onLoadMore() async{
    requestCourses();
    return Future.value();
  }

  void resetRequest(){
    itemList.clear();
    pullLoadCtr.resetNoData();

    requestCourses();
  }

  String? findLastCaseTs() {
    DateTime? res;
    final comp = itemList.first.creationDate!;

    for (final element in itemList) {
      if(filterRequest.getSortViewSelectedForce().isASC){
        if (element.creationDate!.compareTo(comp) > 0) {
          res = element.creationDate!;
        }
      }
      else {
        if (element.creationDate!.compareTo(comp) < 0) {
          res = element.creationDate!;
        }
      }
    }

    return DateHelper.toTimestampNullable(res);
  }

  void requestCourses() async {
    FocusHelper.hideKeyboardByUnFocus(state.context);

    filterRequest.lastCase = findLastCaseTs();

    final js = <String, dynamic>{};
    js[Keys.request] = 'GetCourseForManagerUnSet';
    js[Keys.userId] = userAdmin?.userId;
    js[Keys.filtering] = filterRequest.toMap();

    itemRequester?.bodyJson = js;

    itemRequester?.httpRequestEvents.onNetworkError = (req) async {
      state.stateController.mainStateAndUpdate(StateXController.state$serverNotResponse);
    };

    itemRequester?.httpRequestEvents.onResponseError = (req, isOk) async {
      state.stateController.mainStateAndUpdate(StateXController.state$serverNotResponse);
    };

    itemRequester?.httpRequestEvents.onResultError = (req, data) async {
      state.stateController.mainStateAndUpdate(StateXController.state$serverNotResponse);
      return true;
    };

    itemRequester?.httpRequestEvents.onResultOk = (req, data) async {
      List? resList = data[Keys.resultList];
      var domain = data[Keys.domain];

      if(pullLoadCtr.isRefresh){
        itemList.clear();
        pullLoadCtr.refreshToIdle();
      }

      if(resList != null){
        if(resList.length < filterRequest.limit) {
          pullLoadCtr.loadNoData();
        }
        else{
          pullLoadCtr.loadComplete();
        }

        for(var row in resList){
          var r = CourseModel.fromMap(row, domain: domain);
          itemList.add(r);
        }
      }

      state.stateController.mainStateAndUpdate(StateXController.state$normal);
    };

    state.stateController.mainStateAndUpdate(StateXController.state$loading);
    itemRequester?.request(state.context);
  }
}
