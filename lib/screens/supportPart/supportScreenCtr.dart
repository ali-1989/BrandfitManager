import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';

import '/abstracts/viewController.dart';
import '/managers/ticketManager.dart';
import '/managers/userAdvancedManager.dart';
import '/models/dataModels/ticketModels/ticketMessageModel.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/screens/supportPart/supportScreen.dart';
import '/system/session.dart';
import '/tools/app/appNavigator.dart';
import '/tools/centers/broadcastCenter.dart';
import '/tools/netListenerTools.dart';

class SupportScreenCtr implements ViewController {
  late SupportScreenState state;
  UserModel? user;
  TicketManager? ticketManager;
  bool waitingToPrepare = true;
  int limit = 200;

  @override
  void onInitState<E extends State>(E state){
    this.state = state as SupportScreenState;

    if(Session.hasAnyLogin()){
      user = Session.getLastLoginUser();
      ticketManager = TicketManager.managerFor(user!.userId);

      NetListenerTools.addNetListener(onNetStatus);
      NetListenerTools.addWsListener(onWsStatus);
      BroadcastCenter.ticketMessageUpdateNotifier.addListener(onNewMessage);

      fetchTickets().then((value) {
        state.stateController.mainStateAndUpdate(StateXController.state$normal);

        if (BroadcastCenter.isNetConnected) {
          requestTopTickets();
        }
      });
    }
    else {
      state.addPostOrCall((){
        AppNavigator.pop(state.context);
      });
    }
  }

  @override
  void onBuild(){
  }

  @override
  void onDispose(){
    NetListenerTools.removeNetListener(onNetStatus);
    NetListenerTools.removeWsListener(onWsStatus);
    BroadcastCenter.ticketMessageUpdateNotifier.removeListener(onNewMessage);
  }

  void onNewMessage(){
    //TicketMessageModel? msg = BroadcastCenter.newTicketMessageNotifier.value;
    state.stateController.updateMain();
  }

  void onNetStatus(ConnectivityResult cr){
    if(cr != ConnectivityResult.none) {
      requestTopTickets();
    }
  }

  void onWsStatus(bool connected){
    if(connected) {
      requestTopTickets();
    }
  }
  ///========================================================================================================
  void tryAgain(State state){
  }

  Future<int> fetchTickets({String? littleTs}) async {
    var ticketIds1 = await ticketManager!.fetchTickets(limit: limit, lastTs: littleTs);
    var ticketIds2 = await ticketManager!.fetchUnSeenTickets(limit: limit, lastTs: littleTs);
    var ids = <int>{};
    ids.addAll(ticketIds1);
    ids.addAll(ticketIds2);

    var messageIds = await TicketManager.fetchTicketMessageByTicketIds(ids.toList());

    var mediaIds = TicketManager.takeMediaIdsByMessageIds(messageIds);
    await TicketManager.fetchMediaMessageByIds(mediaIds);

    var userIds = TicketManager.takeUserIdsByMessageIds(messageIds);
    await UserAdvancedManager.loadByIds(userIds);

    waitingToPrepare = false;

    ticketManager!.sortList(false);
    state.stateController.updateMain();
    return ids.length;
  }

  Future requestTopTickets() async {
    FocusHelper.hideKeyboardByUnFocusRoot();

    final res = await ticketManager!.requestTopTickets();
    waitingToPrepare = false;

    if(res){
      BroadcastCenter.ticketMessageUpdateNotifier.value = TicketMessageModel();
    }
    else {
      state.stateController.updateMain();
    }
  }
}
