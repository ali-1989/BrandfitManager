import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:iris_download_manager/downloadManager/downloadManager.dart';
import 'package:iris_tools/api/cache/cacheMap.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' as pull;

import '/abstracts/viewController.dart';
import '/models/dataModels/advertisingModel.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/screens/advertisingPart/advertisingScreen.dart';
import '/screens/advertisingPart/viewAdvertising/advertisingListView.dart';
import '/screens/loginPart/loginScreen.dart';
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

class AdvertisingScreenCtr implements ViewController {
  late AdvertisingScreenState state;
  late Requester commonRequester;
  late UserModel? userAdmin;
  List<AdvertisingListViewState> listChildren = <AdvertisingListViewState>[];
  List<AdvertisingModel> advertisingList = [];
  pull.RefreshController pullLoadCtr = pull.RefreshController();
  late TextEditingController searchEditController;
  late FilterRequest filterRequest;
  double? toolbarHeight;
  Size? mediaQuery;
  late StreamSubscription downloadListenerSubscription;
  final imageCache = CacheMap<String, Uint8List>(10);


  @override
  void onInitState<E extends State>(E state){
    this.state = state as AdvertisingScreenState;

    toolbarHeight = 200.0;
    Session.addLogoffListener(onLogout);
    userAdmin = Session.getLastLoginUser();
    downloadListenerSubscription = DownloadUpload.downloadManager.addListener(onDownloadListener);

    state.stateController.mainState = StateXController.state$loading;

    filterRequest = FilterRequest();
    filterRequest.limit = 40;
    commonRequester = Requester();
    commonRequester.requestPath = RequestPath.GetData;

    prepareTools();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(userAdmin == null){
        AppNavigator.pop(state.context);
        return;
      }
      else {
        requestAdvertising();
      }
    });
  }

  @override
  void onBuild(){
    userAdmin = Session.getLastLoginUser();
  }

  @override
  void onDispose(){
    HttpCenter.cancelAndClose(commonRequester.httpRequester);
    Session.removeLogoffListener(onLogout);
    downloadListenerSubscription.cancel();
  }

  void onLogout(UserModel user){
    HttpCenter.cancelAndClose(commonRequester.httpRequester);
    //AppNavigator.popRoutesUntilRoot(state.context);
    state.stateController.updateMain();
  }

  void onDownloadListener(DownloadItem di) {
    if(di.isInCategory(DownloadCategory.advertisingManager.toString())){
      if(!di.isComplete()){
        return;
      }

      final AdvertisingModel model = di.attach;
      final f = FileHelper.getFile(model.imagePath!);
      model.advFile = f;

      for(final v in listChildren){
        if(v.widget.model.id.toString() == di.subCategory){

          v.update();
          break;
        }
      }
    }
  }

  void prepareTools(){
    filterRequest.addSortView(SortKeys.registrationKey, isAsc: false, isDefault: true);
    filterRequest.addSortView(SortKeys.registrationKey, isAsc: true);
    filterRequest.addSortView(SortKeys.showDateKey, isAsc: false);
    filterRequest.addSortView(SortKeys.showDateKey, isAsc: true);
    filterRequest.addSortView(SortKeys.orderNumberKey, isAsc: false);
    filterRequest.addSortView(SortKeys.orderNumberKey, isAsc: true);

    //filterRequest.addSearchView(SearchKeys.userNameKey);
    filterRequest.addSearchView(SearchKeys.titleKey);
    filterRequest.addSearchView(SearchKeys.tagKey);
    //filterRequest.addSearchView(SearchKeys.typeKey);
    filterRequest.selectedSearchKey = SearchKeys.titleKey;

    final f1 = FilteringViewModel();
    f1.key = FilterKeys.byVisibleState;
    f1.type = FilterType.radio;
    f1.subViews.add(FilterSubViewModel()..key = FilterKeys.isVisibleOp);
    f1.subViews.add(FilterSubViewModel()..key = FilterKeys.isNotVisibleOp);

    filterRequest.addFilterView(f1);
  }
  ///========================================================================================================
  void tryAgain(State state){
    if(state is AdvertisingScreenState) {
      state.stateController.mainStateAndUpdate(StateXController.state$loading);

      requestAdvertising();
    }
  }

  void tryLogin(State state){
    if(state is AdvertisingScreenState){
      AppNavigator.replaceCurrentRoute(state.context, LoginScreen(), name: LoginScreen.screenName);
    }
  }

  void onSearchBarSearch(String text) {
    if(text == filterRequest.getSearchSelectedForce().text){
      return;
    }

    filterRequest.setTextToSelectedSearch(text);
    resetRequest();
  }

  void onSearchBarClear() {
    if(filterRequest.getSearchSelectedForce().text == null){
      return;
    }

    filterRequest.setTextToSelectedSearch(null);
    resetRequest();
  }

  void onRefresh() async {
    advertisingList.clear();

    requestAdvertising();
  }

  void onLoadMore() async {
    requestAdvertising();
  }

  void resetRequest(){
    advertisingList.clear();
    pullLoadCtr.resetNoData();
    state.stateController.mainStateAndUpdate(StateXController.state$loading);

    requestAdvertising();
  }

  void onSortClick(){
    var oldItem = filterRequest.getSortViewSelected();

    MultiViewDialog fd = MultiViewDialog(
      SortPanelView(filterRequest),
      'Sort',
      screenBackground: Colors.black.withAlpha(100),
      useExpanded: true,
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

  String? findLastCaseTs() {
    if(advertisingList.isEmpty){
      return null;
    }

    DateTime? res;
    final comp = advertisingList.first.registerDate!;

    for (final element in advertisingList) {
      if(filterRequest.getSortViewSelectedForce().isASC){
        if (element.registerDate!.compareTo(comp) > 0) {
          res = element.registerDate!;
        }
      }
      else {
        if (element.registerDate!.compareTo(comp) < 0) {
          res = element.registerDate!;
        }
      }
    }

    return DateHelper.toTimestampNullable(res);
  }

  void requestAdvertising() {
    FocusHelper.hideKeyboardByUnFocus(state.context);

    filterRequest.lastCase = findLastCaseTs();

    final js = <String, dynamic>{};
    js[Keys.request] = 'GetAdvertisingList';
    js[Keys.userId] = userAdmin!.userId;
    js[Keys.filtering] = filterRequest.toMap();

    commonRequester.bodyJson = js;

    commonRequester.httpRequestEvents.onNetworkError = (req) async {
      state.stateController.mainStateAndUpdate(StateXController.state$serverNotResponse);
      //SheetCenter.showSheet$ErrorCommunicatingServer(state.context);
    };

    commonRequester.httpRequestEvents.onResponseError = (req, isOk) async {
      state.stateController.mainStateAndUpdate(StateXController.state$serverNotResponse);
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      state.stateController.mainStateAndUpdate(StateXController.state$serverNotResponse);
      return false;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      final List? itemList = data[Keys.resultList];
      final domain = data[Keys.domain];

      if(pullLoadCtr.isRefresh){
        advertisingList.clear();
        pullLoadCtr.refreshToIdle();
      }

      if(itemList != null){
        if(itemList.length < filterRequest.limit) {
          pullLoadCtr.loadNoData();
        }
        else{
          pullLoadCtr.loadComplete();
        }

        for (final row in itemList) {
          final r = AdvertisingModel.fromMap(row, domain: domain);

          advertisingList.add(r);
        }
      }

      state.stateController.mainStateAndUpdate(StateXController.state$normal);
    };

    state.stateController.mainStateAndUpdate(StateXController.state$loading);
    commonRequester.request(state.context);
  }
}
