import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' as pull;

import '/abstracts/viewController.dart';
import '/models/dataModels/foodModels/materialModel.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/screens/foodManagerPart/materialList/foodItemRow.dart';
import '/screens/foodManagerPart/materialList/foodMaterialListScreen.dart';
import '/screens/loginPart/loginScreen.dart';
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

class FoodMaterialListScreenCtr implements ViewController {
  late FoodMaterialListScreenState state;
  late Requester commonRequester;
  late UserModel? user;
  List<MaterialModel> foodMaterialList = [];
  var rowViewList = <FoodItemRowState>[];
  var pullLoadCtr = pull.RefreshController();
  late TextEditingController searchEditController;
  late FilterRequest filterRequest;
  double? toolbarHeight;
  Size? mediaQuery;
  //late StreamSubscription downloadListenerSubscription;
  //final imageCache = CacheMap<String, Uint8List>(10);


  @override
  void onInitState<E extends State>(E state){
    this.state = state as FoodMaterialListScreenState;

    toolbarHeight = 200.0;
    Session.addLogoffListener(onLogout);
    user = Session.getLastLoginUser();
    //downloadListenerSubscription = DownloadUpload.downloadManager.addListener(onDownloadListener);

    state.stateController.mainState = StateXController.state$loading;

    filterRequest = FilterRequest();
    commonRequester = Requester();
    commonRequester.requestPath = RequestPath.GetData;

    prepareTools();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(user == null){
        AppNavigator.pop(state.context);
        return;
      }
      else {
        requestMaterials();
      }
    });
  }

  @override
  void onBuild(){
    user = Session.getLastLoginUser();
  }

  @override
  void onDispose(){
    HttpCenter.cancelAndClose(commonRequester.httpRequester);
    Session.removeLogoffListener(onLogout);
    //downloadListenerSubscription.cancel();
  }

  void onLogout(user){
    HttpCenter.cancelAndClose(commonRequester.httpRequester);
    //AppNavigator.popRoutesUntilRoot(state.context);
    state.update();
  }

  void prepareTools(){
    filterRequest.addSortView(SortKeys.registrationKey, isAsc: false, isDefault: true);
    filterRequest.addSortView(SortKeys.registrationKey, isAsc: true);

    filterRequest.addSearchView(SearchKeys.titleKey);
    filterRequest.addSearchView(SearchKeys.sameWordKey);
    filterRequest.selectedSearchKey = SearchKeys.titleKey;

    final f1 = FilteringViewModel();
    f1.key = FilterKeys.byVisibleState;
    f1.type = FilterType.radio;
    f1.subViews.add(FilterSubViewModel()..key = FilterKeys.isVisibleOp);
    f1.subViews.add(FilterSubViewModel()..key = FilterKeys.isNotVisibleOp);

    final f2 = FilteringViewModel();
    f2.key = FilterKeys.byType;
    f2.type = FilterType.radio;
    f2.subViews.add(FilterSubViewModel()..key = FilterKeys.matterOp);
    f2.subViews.add(FilterSubViewModel()..key = FilterKeys.complementOp);
    f2.subViews.add(FilterSubViewModel()..key = FilterKeys.herbalTeaOp);

    filterRequest.addFilterView(f1);
    filterRequest.addFilterView(f2);
  }
  ///========================================================================================================
  void tryAgain(State state){
    if(state is FoodMaterialListScreenState) {
      state.stateController.mainStateAndUpdate(StateXController.state$loading);

      requestMaterials();
    }
  }

  void tryLogin(State state){
    if(state is FoodMaterialListScreenState){
      AppNavigator.replaceCurrentRoute(state.context, LoginScreen(), name: LoginScreen.screenName);
    }
  }

  void onMainStateChange(dynamic data){
    switch (state.stateController.mainState){
      case StateXController.state$normal:
        break;
      case StateXController.state$error:
        break;
      case StateXController.state$loading:
        break;
      case StateXController.state$netDisconnect:
        break;
      case StateXController.state$serverNotResponse:
        break;
      case StateXController.state$emptyData:
        break;
    }
  }

  void onRefresh() async {
    foodMaterialList.clear();

    requestMaterials();
  }

  void onLoadMore() async {
    requestMaterials();
  }

  void resetRequest(){
    foodMaterialList.clear();
    pullLoadCtr.resetNoData();
    state.stateController.mainStateAndUpdate(StateXController.state$loading);

    requestMaterials();
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

  String? findLastCaseTs() {
    if(foodMaterialList.isEmpty){
      return null;
    }

    DateTime? res;
    final comp = foodMaterialList.first.registerDate!;

    for (final element in foodMaterialList) {
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

  void requestMaterials() {
    FocusHelper.hideKeyboardByUnFocus(state.context);

    filterRequest.lastCase = findLastCaseTs();

    final js = <String, dynamic>{};
    js[Keys.request] = 'SearchOnFoodMaterial';
    js[Keys.userId] = user!.userId;
    js[Keys.filtering] = filterRequest.toMap();

    commonRequester.bodyJson = js;

    commonRequester.httpRequestEvents.onNetworkError = (req) async {
      state.stateController.mainStateAndUpdate(StateXController.state$netDisconnect);
      //SheetCenter.showSheet$ErrorCommunicatingServer(state.context);
    };

    commonRequester.httpRequestEvents.onResponseError = (req, isOk) async {
      state.stateController.mainStateAndUpdate(StateXController.state$serverNotResponse);
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      state.stateController.mainStateAndUpdate(StateXController.state$serverNotResponse);
      return true;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      List? itemList = data[Keys.resultList];

      if(pullLoadCtr.isRefresh){
        foodMaterialList.clear();
        pullLoadCtr.refreshToIdle();
      }

      if(itemList != null) {
        if(itemList.length < filterRequest.limit) {
          pullLoadCtr.loadNoData();
        }
        else{
          pullLoadCtr.loadComplete();
        }

        for (final row in itemList) {
          final r = MaterialModel.fromMap(row);

          foodMaterialList.add(r);
        }
      }

      state.stateController.mainStateAndUpdate(StateXController.state$normal);
    };

    //state.stateController.mainStateAndUpdate(StateXController.state$loading);
    commonRequester.request(state.context);
  }
}
