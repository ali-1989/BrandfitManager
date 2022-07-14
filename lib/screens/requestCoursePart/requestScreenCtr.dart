import 'package:brandfit_manager/managers/foodMaterialManager.dart';
import 'package:brandfit_manager/managers/foodProgramManager.dart';
import 'package:brandfit_manager/models/dataModels/foodModels/materialModel.dart';
import 'package:brandfit_manager/models/dataModels/programModels/foodProgramModel.dart';
import 'package:brandfit_manager/screens/requestCoursePart/showPrograms/programViewScreen.dart';
import 'package:brandfit_manager/tools/centers/sheetCenter.dart';

import '/database/models/requestHybridModelDb.dart';
import '/managers/userRequestManager.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' as pull;

import '/abstracts/viewController.dart';
import '/database/models/userAdvancedModelDb.dart';
import '/managers/userAdvancedManager.dart';
import '/models/dataModels/courseModels/courseQuestionModel.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/screens/loginPart/loginScreen.dart';
import '/screens/requestCoursePart/requestDataShowScreen.dart';
import '/screens/requestCoursePart/requestScreen.dart';
import '/system/keys.dart';
import '/system/multiViewDialog.dart';
import '/system/queryFiltering.dart';
import '/system/requester.dart';
import '/system/session.dart';
import '/tools/app/appNavigator.dart';
import '/tools/centers/directoriesCenter.dart';
import '/tools/centers/httpCenter.dart';
import '/views/filterViews/searchPanelView.dart';

class RequestScreenCtr implements ViewController {
  late RequestScreenState state;
  late Requester commonRequester;
  UserModel? user;
  late FilterRequest filterRequest;
  late TextEditingController searchEditController;
  UserRequestManager? requestManager;
  pull.RefreshController pullLoadCtr = pull.RefreshController();
  bool pendingRequestOp = true;
  bool acceptRequestOp = true;
  bool rejectRequestOp = false;

  @override
  void onInitState<E extends State>(E state){
    this.state = state as RequestScreenState;

    filterRequest = FilterRequest();
    filterRequest.limit = 40;
    commonRequester = Requester();

    Session.addLoginListener(onLogin);
    Session.addLogoffListener(onLogout);

    if(Session.hasAnyLogin()){
      userActions(Session.getLastLoginUser()!);
    }

    prepareFilterOptions();
  }

  @override
  void onBuild(){
  }

  @override
  void onDispose(){
    HttpCenter.cancelAndClose(commonRequester.httpRequester);
    Session.removeLoginListener(onLogin);
    Session.removeLogoffListener(onLogout);
  }

  void onLogin(UserModel user){
    userActions(user);

    state.stateController.updateMain();
  }

  void onLogout(UserModel user){
    HttpCenter.cancelAndClose(commonRequester.httpRequester);
    this.user = null;
    requestManager = null;

    state.stateController.updateMain();
  }

  void userActions(UserModel user){
    this.user = user;
    requestManager = UserRequestManager.managerFor(user.userId);
    state.stateController.mainState = StateXController.state$loading;

    state.addPostOrCall(() {
      requestListRequest();
    });
  }

  void prepareFilterOptions(){
    filterRequest.addSortView(SortKeys.registrationKey, isAsc: false,  isDefault: true);
    filterRequest.addSortView(SortKeys.registrationKey, isAsc: true);

    filterRequest.addSearchView(SearchKeys.userNameKey);
    filterRequest.addSearchView(SearchKeys.titleKey);

    filterRequest.selectedSearchKey = SearchKeys.titleKey;

    final f1 = FilteringViewModel();
    f1.key = FilterKeys.pendingRequestOp;
    f1.type = FilterType.checkbox;
    f1.hasNotView = true;

    final f2 = FilteringViewModel();
    f2.key = FilterKeys.acceptedRequestOp;
    f2.type = FilterType.checkbox;
    f2.hasNotView = true;

    final f3 = FilteringViewModel();
    f3.key = FilterKeys.rejectedRequestOp;
    f3.type = FilterType.checkbox;
    f3.hasNotView = true;

    filterRequest.addFilterView(f1);
    filterRequest.addFilterView(f2);
    filterRequest.addFilterView(f3);
  }
  ///========================================================================================================
  void tryAgain(State state){
    if(state is RequestScreenState) {
      state.stateController.mainStateAndUpdate(StateXController.state$loading);
      requestListRequest();
    }
  }

  void tryLogin(State state){
    if(state is RequestScreenState) {
      AppNavigator.pushNextPage(state.context, LoginScreen(), name: LoginScreen.screenName);
    }
  }

  void onSearchOptionClick(){
    final fd = MultiViewDialog(
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
      state.stateController.updateMain();
    });
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
    requestManager?.requestList.clear();

    requestListRequest();
  }

  void onLoadMore() async {
    requestListRequest();
  }

  void resetRequest(){
    requestManager?.requestList.clear();
    pullLoadCtr.resetNoData();
    state.stateController.mainStateAndUpdate(StateXController.state$loading);

    requestListRequest();
  }

  void checkFiltering(){
    final f1 = filterRequest.getFilterViewFor(FilterKeys.pendingRequestOp);
    final f2 = filterRequest.getFilterViewFor(FilterKeys.acceptedRequestOp);
    final f3 = filterRequest.getFilterViewFor(FilterKeys.rejectedRequestOp);
    f1?.selectedValue = null;
    f2?.selectedValue = null;
    f3?.selectedValue = null;

    if(pendingRequestOp){
      f1?.selectedValue = FilterKeys.pendingRequestOp;
    }

    if(acceptRequestOp){
      f2?.selectedValue = FilterKeys.acceptedRequestOp;
    }

    if(rejectRequestOp){
      f3?.selectedValue = FilterKeys.rejectedRequestOp;
    }
  }

  String? findLastCaseTs() {
    if(requestManager!.requestList.isEmpty){
      return null;
    }

    String? res;
    final comp = DateHelper.tsToSystemDate(requestManager!.requestList.first.creationDate!)!;

    for (final element in requestManager!.requestList) {
      final lDate = DateHelper.tsToSystemDate(element.creationDate!)!;

      if(filterRequest.getSortViewSelectedForce().isASC){
        if (lDate.compareTo(comp) > 0) {
          res = element.creationDate;
        }
      }
      else {
        if (lDate.compareTo(comp) < 0) {
          res = element.creationDate;
        }
      }
    }

    return res;
  }

  void gotoProgramsScreen(RequestHybridModelDb model) {
    requestCoursePrograms(model);
  }

  void requestCoursePrograms(RequestHybridModelDb model) {
    final js = <String, dynamic>{};
    js[Keys.request] = 'GetCourseRequestProgramsForManager';
    js[Keys.requesterId] = user!.userId;
    js['course_id'] = model.courseId;
    js['request_id'] = model.id;

    commonRequester.bodyJson = js;
    commonRequester.requestPath = RequestPath.GetData;

    commonRequester.httpRequestEvents.onFailState = (req) async {
      await state.hideLoading();
      SheetCenter.showSheet$ServerNotRespondProperly(state.context);
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      return true;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      await state.hideLoading();

      final List programList = data['program_list'];
      final List materialList = data['material_list'];
      final domain = data[Keys.domain];

      for(final m in materialList){
        final mat = MaterialModel.fromMap(m, domain: domain);
        FoodMaterialManager.addItem(mat);
        FoodMaterialManager.sinkItems([mat]);
      }

      final pManager = FoodProgramManager.managerFor(user!.userId);

      for(final p in programList){
        final pro = FoodProgramModel.fromMap(p);
        pManager.addItem(pro);
        //pManager.sinkItems([pro]);
      }

      AppNavigator.pushNextPage(
          state.context,
          ProgramViewScreen(requestHybridModel: model,),
          name: ProgramViewScreen.screenName
      );
    };

    state.showLoading();
    commonRequester.request(state.context);
  }

  void requestListRequest() {
    FocusHelper.hideKeyboardByService();

    checkFiltering();
    filterRequest.lastCase = findLastCaseTs();

    final js = <String, dynamic>{};
    js[Keys.request] = 'GetCourseRequestsForManager';
    js[Keys.requesterId] = user!.userId;
    js[Keys.filtering] = filterRequest.toMap();

    commonRequester.bodyJson = js;
    commonRequester.requestPath = RequestPath.GetData;

    commonRequester.httpRequestEvents.onFailState = (req) async {
      state.stateController.mainStateAndUpdate(StateXController.state$error);
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      return true;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      final List? courseList = data[Keys.resultList];
      final List? advanceUsers = data['advance_users'];
      final domain = data[Keys.domain];

      if(pullLoadCtr.isRefresh){
        requestManager!.requestList.clear();
        pullLoadCtr.refreshToIdle();
      }

      if(courseList != null){
        if(courseList.length < filterRequest.limit) {
          pullLoadCtr.loadNoData();
        }
        else{
          pullLoadCtr.loadComplete();
        }

        if(advanceUsers != null) {
          for(final u in advanceUsers){
            final user = UserAdvancedModelDb.fromMap(u, domain: domain);
            UserAdvancedManager.addItem(user);
          }
        }

        for(final m in courseList){
          final cr = RequestHybridModelDb.fromMap(m, domain: domain);
          requestManager?.addItem(cr);
        }
      }

      state.stateController.mainStateAndUpdate(StateXController.state$normal);
    };

    commonRequester.request(state.context);
  }

  void requestCourseInfo(RequestHybridModelDb model) {
    final js = <String, dynamic>{};
    js[Keys.request] = 'GetCourseRequestInfoForManager';
    js[Keys.requesterId] = user!.userId;
    js['course_id'] = model.courseId;
    js['course_requester_id'] = model.requesterUserId;
    js['course_creator_id'] = model.courseCreatorUserId;

    commonRequester.bodyJson = js;
    commonRequester.requestPath = RequestPath.GetData;

    commonRequester.httpRequestEvents.onFailState = (req) async {
      await state.hideLoading();
      state.stateController.mainStateAndUpdate(StateXController.state$netDisconnect);
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      return true;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      await state.hideLoading();

      final userProfile = data[Keys.userData];
      final trainerProfile = data['trainer_profile_data'];
      final questions = data['questions_data'];
      final domain = data[Keys.domain];

      final u = UserAdvancedModelDb.fromMap(userProfile, domain: domain);
      final t = UserAdvancedModelDb.fromMap(trainerProfile, domain: domain);
      final q = CourseQuestionModel.fromMap(questions['questions_js'], domain: domain);

      for (var element in q.experimentPhotos) {element.genPath(DirectoriesCenter.getCourseDir$ex());}
      for (var element in q.bodyPhotos) {element.genPath(DirectoriesCenter.getCourseDir$ex());}
      for (var element in q.bodyAnalysisPhotos) {element.genPath(DirectoriesCenter.getCourseDir$ex());}

      if(q.cardPhoto != null){
        q.cardPhoto!.genPath(DirectoriesCenter.getCourseDir$ex());
      }

      UserAdvancedManager.addItem(u);
      UserAdvancedManager.sinkItems([u]);

      // ignore: unawaited_futures
      AppNavigator.pushNextPage(
          state.context,
          RequestDataShowScreen(
            requestModel: model,
            userInfo: u,
            trainerInfo: t,
            questionInfo: q,
          ), name: RequestDataShowScreen.screenName);
    };

    state.showLoading();
    commonRequester.request(state.context);
  }
}
