import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:iris_tools/modules/stateManagers/stateX.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' as pull;

import '/abstracts/viewController.dart';
import '/managers/ticketManager.dart';
import '/models/dataModels/ticketModels/ticketModel.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/screens/supportPart/supportScreen.dart';
import '/tools/centers/broadcastCenter.dart';

class UnSeenTicketsPageCtr implements ViewController {
  late UnSeenTicketsPageState state;
  late SupportScreenState parentState;
  late UserModel user;
  late TicketManager ticketManager;
  List<TicketModel> unSeenList = [];
  var pullLoadCtr = pull.RefreshController();


  @override
  void onInitState<E extends State>(E state){
    this.state = state as UnSeenTicketsPageState;

    parentState = state.widget.parentState;
    user = parentState.controller.user!;
    ticketManager = TicketManager.managerFor(user.userId);
    prepareList();

    BroadcastCenter.ticketUpdateNotifier.addListener(onTicketReadNotifier);
    BroadcastCenter.ticketMessageUpdateNotifier.addListener(onMessageUpdater);
  }

  @override
  void onBuild(){
  }

  @override
  void onDispose(){
    BroadcastCenter.ticketUpdateNotifier.removeListener(onTicketReadNotifier);
    BroadcastCenter.ticketMessageUpdateNotifier.removeListener(onMessageUpdater);
  }

  void onTicketReadNotifier(){
    prepareList();
    state.stateController.updateMain();
  }

  void prepareList(){
    unSeenList = ticketManager.getUnSeenList();
    sortUnSeenTicketsByServerTs(true);
  }

  void onMessageUpdater(){
    state.stateController.updateMain();
  }
  ///========================================================================================================
  void tryAgain(State state){
    if(state is UnSeenTicketsPageState) {
      state.stateController.mainStateAndUpdate(StateXController.state$loading);
    }
  }

  void sortUnSeenTicketsByServerTs(bool desc){
    unSeenList.sort((e1, e2){
      var m1 = e1.lastMessage;
      var m2 = e2.lastMessage;

      if(m1 == null && m2 == null){
        return 0;
      }

      if(m1 == null || m2 == null){
        return -1;
      }

      var d1 = m1.serverReceiveDate?? m1.sendDate;
      var d2 = m2.serverReceiveDate?? m2.sendDate;

      if(desc) {
        return d2!.compareTo(d1!);
      }

      return d1!.compareTo(d2!);
    });
  }

  int findUnSeenTicketLittleId() {
    int res = unSeenList.first.id?? 0;

    for (var element in unSeenList) {
      if(element.id! < res){
        res = element.id!;
      }
    }

    return res;
  }

  String findUnSeenTicketLittleTs() {
  String res = '';
  DateTime ch = unSeenList.first.startDate!;

    for (var element in unSeenList) {
      if(element.startDate!.compareTo(ch) < 0){
        res = element.startDateTs!;
      }
    }

    return res;
  }

  void onRefresh() async {
    //unSeenList.clear();
    hideRefreshLoader();
  }

  Future<void> onLoadMore() async {
    final lastCase = ticketManager.findTicketLittleTs();

    return parentState.controller.fetchTickets(littleTs: lastCase).then((value) {
      prepareList();

      state.stateController.updateMain();
    });
  }

  void hideRefreshLoader(){
    pullLoadCtr.refreshToIdle();
  }

  void resetRequest(){
    unSeenList.clear();
    pullLoadCtr.resetNoData();

    parentState.controller.fetchTickets().then((value) {
      prepareList();

      state.stateController.updateMain();
    });
  }
}
