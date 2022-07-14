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
import '/models/dataModels/usersModels/appUserModel.dart';
import '/models/dataModels/usersModels/userModel.dart';
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
import '/tools/permissionTools.dart';
import '/views/filterViews/filterPanelView.dart';
import '/views/filterViews/searchPanelView.dart';
import '/views/filterViews/sortPanelView.dart';

class UserManagementScreenCtr implements ViewController {
  late UserManagementScreenState state;
  late Requester commonRequester;
  UserModel? user;
  late TextEditingController searchEditController;
  late double toolbarHeight;
  Size? mediaQuery;
  var listChildren = <UserListViewState>[];
  List<AppUserModel> userList = [];
  late FilterRequest filterRequest;
  late StreamSubscription downloadListenerSubscription;
  var pullLoadCtr = pull.RefreshController();


  @override
  void onInitState<E extends State>(E state){
    this.state = state as UserManagementScreenState;

    toolbarHeight = 200.0;
    commonRequester = Requester();
    commonRequester.requestPath = RequestPath.GetData;

    filterRequest = FilterRequest();
    filterRequest.limit = 40;

    prepareTools();

    Session.addLogoffListener(onLogout);
    downloadListenerSubscription = DownloadUpload.downloadManager.addListener(onDownloadListener);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(user == null){
        AppNavigator.pop(state.context);
        return;
      }
      else {
        PermissionTools.requestStoragePermission();
        requestUsers(true);
      }
    });
  }

  @override
  void onBuild(){
    user = Session.getLastLoginUser();
  }

  @override
  void onDispose(){
    Session.removeLogoffListener(onLogout);
    downloadListenerSubscription.cancel();
    HttpCenter.cancelAndClose(commonRequester.httpRequester);
  }

  void onLogout(user){
    HttpCenter.cancelAndClose(commonRequester.httpRequester);
    state.stateController.updateMain();
  }

  void onDownloadListener(DownloadItem di) {
    if(di.isInCategory(DownloadCategory.userProfile.toString())){
      if(!di.isComplete()){
        return;
      }

      AppUserModel model = di.attach;
      final f = FileHelper.getFile(model.profileImagePath!);
      model.profileFile = f;

      for(final v in listChildren){
        if(v.widget.model.userId.toString() == di.subCategory){
          v.update();
          break;
        }
      }
    }
  }

  void prepareTools(){
    filterRequest.addSortView(SortKeys.registrationKey, isAsc: false, isDefault: true);
    filterRequest.addSortView(SortKeys.registrationKey, isAsc: true);
    filterRequest.addSortView(SortKeys.ageKey, isAsc: false);
    filterRequest.addSortView(SortKeys.ageKey, isAsc: true);

    filterRequest.addSearchView(SearchKeys.userNameKey);
    filterRequest.addSearchView(SearchKeys.name);
    filterRequest.addSearchView(SearchKeys.family);
    filterRequest.addSearchView(SearchKeys.mobile);
    filterRequest.selectedSearchKey = SearchKeys.userNameKey;

    final f1 = FilteringViewModel();
    f1.key = FilterKeys.byGender;
    f1.type = FilterType.radio;
    f1.subViews.add(FilterSubViewModel()..key = FilterKeys.maleOp);
    f1.subViews.add(FilterSubViewModel()..key = FilterKeys.femaleOp);

    final f2 = FilteringViewModel();
    f2.key = FilterKeys.byAge;
    f2.type = FilterType.range;
    f2.subViews.add(FilterSubViewModel()..key = FilterKeys.byAge..v1 = 7..v2 = 100);

    final f3 = FilteringViewModel();
    f3.key = FilterKeys.byBlocked;
    f3.type = FilterType.radio;
    f3.subViews.add(FilterSubViewModel()..key = FilterKeys.blockedOp);
    f3.subViews.add(FilterSubViewModel()..key = FilterKeys.noneBlockedOp);

    final f4 = FilteringViewModel();
    f4.key = FilterKeys.byDeleted;
    f4.type = FilterType.radio;
    f4.subViews.add(FilterSubViewModel()..key = FilterKeys.deletedOp);
    f4.subViews.add(FilterSubViewModel()..key = FilterKeys.noneDeletedOp);

    filterRequest.addFilterView(f1);
    filterRequest.addFilterView(f2);
    filterRequest.addFilterView(f3);
    filterRequest.addFilterView(f4);
  }
  ///========================================================================================================
  void tryAgain(State state){
    if(state is UserManagementScreenState) {
      requestUsers(userList.isEmpty);
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
    userList.clear();

    requestUsers(false);
  }

  Future<void> onLoadMore() async{
    requestUsers(false);
    return Future.value();
  }

  void resetRequest(){
    userList.clear();
    pullLoadCtr.resetNoData();

    requestUsers(true);
  }

  String? findLastCaseTs() {
    if(userList.isEmpty){
      return null;
    }

    DateTime? res;
    final comp = userList.first.joinDate!;

    for (final element in userList) {
      if(filterRequest.getSortViewSelectedForce().isASC){
        if (element.joinDate!.compareTo(comp) > 0) {
          res = element.joinDate!;
        }
      }
      else {
        if (element.joinDate!.compareTo(comp) < 0) {
          res = element.joinDate!;
        }
      }
    }

    return DateHelper.toTimestampNullable(res);
  }

  void requestUsers(bool loading) async {
    FocusHelper.hideKeyboardByUnFocus(state.context);

    filterRequest.lastCase = findLastCaseTs();

    final js = <String, dynamic>{};
    js[Keys.request] = 'GetRegisterUsers';
    js[Keys.userId] = user?.userId;
    js[Keys.filtering] = filterRequest.toMap();

    commonRequester.bodyJson = js;

    commonRequester.httpRequestEvents.onNetworkError = (req) async {
      if(loading) {
        state.stateController.mainStateAndUpdate(StateXController.state$netDisconnect);
      }
      else {
        if(pullLoadCtr.isRefresh) {
          pullLoadCtr.refreshFailed();
        }
        else {
          pullLoadCtr.loadFailed();
        }
      }
    };

    commonRequester.httpRequestEvents.onResponseError = (req, isOk) async {
      if(loading) {
        state.stateController.mainStateAndUpdate(StateXController.state$serverNotResponse);
      }
      else {
        if(pullLoadCtr.isRefresh) {
          pullLoadCtr.refreshFailed();
        }
        else {
          pullLoadCtr.loadFailed();
        }
      }
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      if(loading) {
        state.stateController.mainStateAndUpdate(StateXController.state$serverNotResponse);
      }
      else {
        if(pullLoadCtr.isRefresh) {
          pullLoadCtr.refreshFailed();
        }
        else {
          pullLoadCtr.loadFailed();
        }
      }

      return true;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      List? itemList = data[Keys.resultList];
      var domain = data[Keys.domain];

      if(pullLoadCtr.isRefresh){
        userList.clear();
        pullLoadCtr.refreshToIdle();
      }

      if(itemList != null){
        if(itemList.length < filterRequest.limit) {
          pullLoadCtr.loadNoData();
        }
        else{
          pullLoadCtr.loadComplete();
        }

        for(var row in itemList){
          var r = AppUserModel.fromMap(row, domain: domain);
          userList.add(r);
        }
      }

      if(loading) {
        state.stateController.mainStateAndUpdate(StateXController.state$normal);
      }
      else {
        state.stateController.updateMain();
      }
    };

    state.stateController.mainStateAndUpdate(loading? StateXController.state$loading : StateXController.state$normal);
    commonRequester.request(state.context);
  }
}
