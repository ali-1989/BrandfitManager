import 'dart:async';

import 'package:flutter/material.dart';

import 'package:iris_tools/api/extendValueNotifier.dart';
import 'package:iris_tools/modules/stateManagers/refresh.dart';

import '/database/models/userAdvancedModelDb.dart';
import '/models/dataModels/chatModels/chatMessageModel.dart';
import '/models/dataModels/chatModels/chatModel.dart';
import '/models/dataModels/ticketModels/ticketMessageModel.dart';
import '/models/dataModels/ticketModels/ticketModel.dart';
import '/screens/commons/patternLock.dart';
import '/screens/home/homeScreen.dart';
import '/tools/app/appThemes.dart';

class BroadcastCenter {
  BroadcastCenter._();

  static final StreamController<bool> materialUpdaterStream = StreamController<bool>();
  static final StreamController<String> pageRouterStream = StreamController<String>();
  static final RefreshController drawerMenuRefresher = RefreshController();
  static final ValueNotifier<UserAdvancedModelDb?> chatUserChangeNotifier = ValueNotifier<UserAdvancedModelDb?>(null);
  //static final ExtendValueNotifier<int> newNotifyNotifier = ExtendValueNotifier<int>(0);
  static final LocalKey materialAppKey = UniqueKey();
  static final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  static final rootNavigatorStateKey = GlobalKey<NavigatorState>();
  static final lockController = PatternLockController();
  static final homeScreenKey = GlobalKey<HomeScreenState>();
  //static final centerPageScreenKey = GlobalKey<CenterPageScreenState>();
  //----------- ticket
  static final ValueNotifier<Map?> ticketMessageSeenNotifier = ValueNotifier<Map?>(null);
  static final ExtendValueNotifier<TicketModel?> ticketUpdateNotifier = ExtendValueNotifier<TicketModel?>(null);
  static final ValueNotifier<TicketMessageModel?> ticketMessageUpdateNotifier = ValueNotifier<TicketMessageModel?>(null);
  static final ValueNotifier<Map?> ticketUserTypingNotifier = ValueNotifier<Map?>(null);//{user_id, ticket_id}
  static final ValueNotifier<Map?> ticketUserVoiceNotifier = ValueNotifier<Map?>(null);//{user_id, ticket_id}
  //----------- chat
  static final ValueNotifier<Map?> chatMessageSeenNotifier = ValueNotifier<Map?>(null);
  static final ExtendValueNotifier<ChatModel?> chatUpdateNotifier = ExtendValueNotifier<ChatModel?>(null);
  static final ValueNotifier<ChatMessageModel?> chatMessageUpdateNotifier = ValueNotifier<ChatMessageModel?>(null);
  static final ValueNotifier<Map?> chatUserTypingNotifier = ValueNotifier<Map?>(null);
  static final ValueNotifier<Map?> chatUserVoiceNotifier = ValueNotifier<Map?>(null);

  static final homePageBadges = <int, int>{};
  static bool isNetConnected = true;
  static bool isWsConnected = false;
  static int? openedTicketId;
  static int? openedChatId;
  static int newTicketNotificationId = 1235456;
  static int newChatNotificationId = 1235458;


  /// this call build() method of all widgets
  /// this is effect on First Widgets tree, not rebuild Pushed pages
  static void reBuildMaterialBySetTheme() {
    AppThemes.applyTheme(AppThemes.currentTheme);
    materialUpdaterStream.sink.add(true);
  }

  static void reBuildMaterial() {
    materialUpdaterStream.sink.add(true);
  }

  /*static void prepareBadgesAndRefresh() async {
    final user = Session.getLastLoginUser();

    if(user == null){
      homePageBadges.clear();
      return;
    }

    //------ notify --------------------------------------------------------------
    final list = NotifierModelDb.fetchUnSeenRecords(user.userId);

    if(list.isEmpty){
      homePageBadges[0] = 0;
    }
    else {
      homePageBadges[0] = list.length;
    }
    //------ chat --------------------------------------------------------------
    final manager = ChatManager.managerFor(user.userId);
    var chatCount = 0;

    for(final chat in manager.allChatList){
      chatCount += chat.unReadCount();
    }

    if(chatCount == 0){
      homePageBadges[4] = 0;
    }
    else {
      homePageBadges[4] = chatCount;
    }
    //--------------------------------------------------------------------
    homeScreenKey.currentState?.navBarRefresher.update();
  }*/
}
