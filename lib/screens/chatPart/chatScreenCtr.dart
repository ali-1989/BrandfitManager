import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' as pull;

import '/abstracts/viewController.dart';
import '/database/models/userAdvancedModelDb.dart';
import '/managers/chatManager.dart';
import '/managers/userAdvancedManager.dart';
import '/models/dataModels/chatModels/chatMediaModel.dart';
import '/models/dataModels/chatModels/chatMessageModel.dart';
import '/models/dataModels/chatModels/chatModel.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/screens/chatPart/chatScreen.dart';
import '/screens/chatPart/filteringPart/filteringPage.dart';
import '/system/keys.dart';
import '/system/multiViewDialog.dart';
import '/system/queryFiltering.dart';
import '/system/requester.dart';
import '/system/session.dart';
import '/tools/app/appNavigator.dart';
import '/tools/centers/httpCenter.dart';

/// note: for manager, chats not fetch and only get from net

class ChatScreenCtr implements ViewController {
  late ChatScreenState state;
  late Requester commonRequester;
  late FilterRequest filterRequest;
  late ChatManager chatManager;
  pull.RefreshController pullLoadCtr = pull.RefreshController();
  UserModel? user;


  @override
  void onInitState<E extends State>(E state){
    this.state = state as ChatScreenState;

    state.stateController.mainState = StateXController.state$loading;
    commonRequester = Requester();
    //commonRequester.requestPath = RequestPath.GetData;

    Session.addLogoffListener(onLogout);
    filterRequest = FilterRequest();
    prepareFiltering();

    state.addPostOrCall((){
      if(Session.hasAnyLogin()){
        user = Session.getLastLoginUser()!;
        chatManager = ChatManager.managerFor(user!.userId);
        chatManager.allChatList.clear();
        requestChats();
      }
      else {
        AppNavigator.pop(state.context);
      }
    });
  }

  @override
  void onBuild(){
  }

  @override
  void onDispose(){
    HttpCenter.cancelAndClose(commonRequester.httpRequester);
    Session.removeLogoffListener(onLogout);
  }

  void onLogout(UserModel user){
    HttpCenter.cancelAndClose(commonRequester.httpRequester);
    AppNavigator.pop(state.context);
  }

  void prepareFiltering(){
  }
  ///========================================================================================================
  void tryAgain(State state){
    if(state is ChatScreenState) {
      state.stateController.mainStateAndUpdate(StateXController.state$loading);
    }
  }

  void removeFiltering(FilteringViewModel fvm, int userId){
    FilteringViewModel? filter = filterRequest.getFilterViewFor(fvm.key);

    if(filter != null){
      if(filter.selectedList.length < 2){
        filterRequest.removeFilterView(fvm.key);
      }
      else {
        filter.selectedList.removeWhere((element) => element == userId);
      }
    }

    chatManager.allChatList.clear();

    requestChats();
  }

  void showFilterPrompt(){
    final dialog = MultiViewDialog(
        FilteringScreen(filterRequest: filterRequest,),
      'filtering'
    );

    dialog.showFullscreen(state.context, canBack: true).then((value){
      if(value is! UserAdvancedModelDb){
        return;
      }

      String key = value.userType == 1? FilterKeys.byTrainerUser : FilterKeys.byPupilUser;
      FilteringViewModel? filter = filterRequest.getFilterViewFor(key);

      if(filter == null) {
        filter = FilteringViewModel();
        filter.type = FilterType.string;
        filter.key = key;
        filter.hasNotView = true;

        filterRequest.addFilterView(filter);
      }

      if(filter.addToSelectedList(value.userId)){
        chatManager.allChatList.clear();

        requestChats();
      }
    });
  }

  void onRefresh() async {
    chatManager.allChatList.clear();

    requestChats();
  }

  void onLoadMore() async {
    requestChats();
  }

  void resetRequest(){
    chatManager.allChatList.clear();
    pullLoadCtr.resetNoData();
    state.stateController.mainStateAndUpdate(StateXController.state$loading);

    requestChats();
  }

  String? findLastCaseTs() {
    if(chatManager.allChatList.isEmpty){
      return null;
    }

    DateTime? res;
    final comp = chatManager.allChatList.first.creationDate!;

    for (final element in chatManager.allChatList) {
      final lDate = element.creationDate!;

      if (lDate.compareTo(comp) > 0) {
        res = element.creationDate;
      }
    }

    return DateHelper.toTimestampNullable(res);
  }

  void requestChats() {
    FocusHelper.hideKeyboardByUnFocus(state.context);

    filterRequest.lastCase = findLastCaseTs();

    final js = <String, dynamic>{};
    js[Keys.request] = 'GetChatsForManager';
    js[Keys.requesterId] = user!.userId;
    js[Keys.filtering] = filterRequest.toMap();

    commonRequester.bodyJson = js;
    commonRequester.requestPath = RequestPath.GetData;

    commonRequester.httpRequestEvents.onFailState = (req) async {
      state.stateController.mainStateAndUpdate(StateXController.state$serverNotResponse);
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      return true;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      final List? chatList = data['chat_list'];
      final List messageList = data['message_list'];
      final List mediaList = data['media_list'];
      final List userList = data['user_list'];

      if(pullLoadCtr.isRefresh){
        chatManager.allChatList.clear();
        pullLoadCtr.refreshToIdle();
      }
      else {
        int l = chatList?.length?? 0;

        if (l < filterRequest.limit) {
          pullLoadCtr.loadNoData();
        }
        else {
          pullLoadCtr.loadComplete();
        }
      }

      for(final k in userList){
        final user = UserAdvancedModelDb.fromMap(k);

        UserAdvancedManager.addItem(user);
      }

      for(final k in mediaList){
        final media = ChatMediaModel.fromMap(k);

        ChatManager.addMediaMessage(media);
      }

      for(final k in messageList){
        final message = ChatMessageModel.fromMap(k);

        ChatManager.addMessage(message);
      }

      if(chatList != null){
        for(final k in chatList){
          final chat = ChatModel.fromMap(k);
          chat.isClose = true;

          chatManager.addItem(chat);
          //chatManager.sinkItems([chat]);
        }
      }

      state.stateController.mainStateAndUpdate(StateXController.state$normal);
    };

    commonRequester.request(state.context);
  }
}
