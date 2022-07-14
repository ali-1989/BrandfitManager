import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' as pull;

import '/abstracts/viewController.dart';
import '/managers/ticketManager.dart';
import '/managers/userAdvancedManager.dart';
import '/models/dataModels/ticketModels/ticketModel.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/screens/supportPart/supportScreen.dart';
import '/system/keys.dart';
import '/system/queryFiltering.dart';
import '/system/requester.dart';
import '/tools/centers/broadcastCenter.dart';
import '/tools/centers/httpCenter.dart';

class AllTicketsPageCtr implements ViewController {
  late AllTicketsPageState state;
  late SupportScreenState parentState;
  Requester? commonRequester;
  late UserModel user;
  late TicketManager ticketManager;
  List<TicketModel> myTicketList = [];
  late FilterRequest filterRequest;
  var pullLoadCtr = pull.RefreshController();


  @override
  void onInitState<E extends State>(E state){
    this.state = state as AllTicketsPageState;

    parentState = state.widget.parentState;
    user = parentState.controller.user!;
    ticketManager = TicketManager.managerFor(user.userId);
    myTicketList = ticketManager.allTicketList;

    commonRequester = Requester();
    filterRequest = FilterRequest();
    filterRequest.limit = 100;

    BroadcastCenter.ticketUpdateNotifier.addListener(onTicketUpdater);
    BroadcastCenter.ticketMessageUpdateNotifier.addListener(onMessageUpdater);
  }

  @override
  void onBuild(){
  }

  @override
  void onDispose(){
    HttpCenter.cancelAndClose(commonRequester?.httpRequester);
    BroadcastCenter.ticketUpdateNotifier.removeListener(onTicketUpdater);
    BroadcastCenter.ticketMessageUpdateNotifier.removeListener(onMessageUpdater);
  }

  void onTicketReadNotifier(){
    state.stateController.updateMain();
  }

  void onTicketUpdater(){
    //TicketModel? ticket = BroadcastCenter.ticketChangeNotifier.value;
    state.stateController.updateMain();
  }

  void onMessageUpdater(){
    //TicketMessageModel? msg = BroadcastCenter.newTicketMessageNotifier.value;
    state.stateController.updateMain();
  }
  ///========================================================================================================
  void tryAgain(State state){
    if(state is AllTicketsPageState) {
      state.stateController.mainStateAndUpdate(StateXController.state$loading);
    }
  }

  void onRefresh() async {
    myTicketList.clear();

    await parentState.controller.fetchTickets();
    ticketManager.sortList(false);
    state.stateController.updateMain();

    if(BroadcastCenter.isNetConnected) {
      await parentState.controller.requestTopTickets();
    }
    else {
      hideRefreshLoader();
    }
  }

  Future<void> onLoadMore() async {
    final lastCase = ticketManager.findTicketLittleTs();

    return parentState.controller.fetchTickets(littleTs: lastCase).then((value) {
      ticketManager.sortList(false);
      state.stateController.updateMain();

      if(BroadcastCenter.isNetConnected){
        requestMoreTickets();
      }
      else {
        if(value < filterRequest.limit){
          pullLoadCtr.loadNoData();
        }
        else {
          pullLoadCtr.loadComplete();
        }
      }
    });
  }

  void hideRefreshLoader(){
    pullLoadCtr.refreshToIdle();
  }

  void resetRequest(){
    myTicketList.clear();
    pullLoadCtr.resetNoData();

    parentState.controller.fetchTickets().then((value) async {
      ticketManager.sortList(false);
      state.stateController.updateMain();

      if(BroadcastCenter.isNetConnected){
        await ticketManager.requestTopTickets();

        if(pullLoadCtr.isRefresh) {
          pullLoadCtr.refreshToIdle();
        }
      }
      else {
        if(pullLoadCtr.isRefresh) {
          pullLoadCtr.refreshToIdle();
        }
        else {
          if (value < filterRequest.limit) {
            pullLoadCtr.loadNoData();
          }
          else {
            pullLoadCtr.loadComplete();
          }
        }
      }
    });
  }

  void requestMoreTickets() async {
    FocusHelper.hideKeyboardByUnFocusRoot();

    //filterRequest.addTextSearchKey(text, key);
    filterRequest.lastCase = ticketManager.findTicketLittleTs(); //findTicketLittleId();

    final js = <String, dynamic>{};
    js[Keys.request] = Keys.adminCommand;
    js[Keys.subRequest] = 'GetTicketsForManager';
    js[Keys.requesterId] = user.userId;
    js[Keys.forUserId] = user.userId;
    js[Keys.filtering] = filterRequest.toMap();

    commonRequester?.bodyJson = js;
    commonRequester?.requestPath = RequestPath.GetData;

    commonRequester?.httpRequestEvents.onFailState = (req) async {
      if(pullLoadCtr.isRefresh) {
        pullLoadCtr.refreshFailed();
      }
      else {
        pullLoadCtr.loadFailed();
      }
    };

    commonRequester?.httpRequestEvents.onResultError = (req, data) async {
      return true;
    };

    commonRequester?.httpRequestEvents.onResultOk = (req, data) async {
      List? ticketMap = data['ticket_list'];
      List? messageMap = data['message_list'];
      List? mediaMap = data['media_list'];
      List? userList = data['user_list'];
      var domain = data[Keys.domain];

      if(pullLoadCtr.isRefresh) {
        pullLoadCtr.refreshToIdle();
      }
      else {
        int l = ticketMap?.length?? 0;

        if(l < filterRequest.limit) {
          pullLoadCtr.loadNoData();
        }
        else {
          pullLoadCtr.loadComplete();
        }
      }

      var uList = UserAdvancedManager.addItemsFromMap(userList, domain: domain);
      UserAdvancedManager.sinkItems(uList);

      var m2List = TicketManager.addMediaMessagesFromMap(mediaMap);
      var mList = TicketManager.addTicketMessagesFromMap(messageMap);
      var tList = ticketManager.addItemsFromMap(ticketMap);

      ticketManager.sortList(false);

      TicketManager.sinkTicketMedia(m2List);
      TicketManager.sinkTicketMessages(mList);
      TicketManager.sinkTickets(tList);

      state.stateController.updateMain();
    };

    state.stateController.updateMain();
    commonRequester?.request(state.context);
  }
}
