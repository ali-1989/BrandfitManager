import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:iris_tools/net/netManager.dart';

import '/managers/ticketManager.dart';
import '/screens/drawerMenu.dart';
import '/system/session.dart';
import '/tools/centers/broadcastCenter.dart';
import '/tools/centers/cacheCenter.dart';
import '/tools/centers/wsCenter.dart';
import '/tools/serverTimeTools.dart';
import '/tools/userLoginTools.dart';

/// this listener not work on start app, work on new event

class NetListenerTools {
  NetListenerTools._();

  static final List<void Function(bool isConnected)> _wsConnectListeners = [];

  static void addNetListener(void Function(ConnectivityResult) fn){
    NetManager.addChangeListener(fn);
  }

  static void removeNetListener(void Function(ConnectivityResult) fn){
    NetManager.removeChangeListener(fn);
  }

  static void addWsListener(void Function(bool) fn){
    if(!_wsConnectListeners.contains(fn)) {
      _wsConnectListeners.add(fn);
    }
  }

  static void removeWsListener(void Function(bool) fn){
    _wsConnectListeners.remove(fn);
  }

  // this call if (wifi/cell data) is connected(is on), else not call
  static void onNetListener(ConnectivityResult connectivityResult) async {

    if(connectivityResult != ConnectivityResult.none) {
      BroadcastCenter.isNetConnected = true;

      WsCenter.connect();

      await ServerTimeTools.requestUtcTimeOfServer();
      //Settings.prepareRequestAppLanguages();
      //AdvertisingTools.callRequestAdvertising();

      TicketManager.sendFailLastSeen();
      TicketManager.sendFailMessages();

      if (Session.hasAnyLogin()) {
        final user = Session.getLastLoginUser()!;

        if (user.isSetProfileImage) {
          DrawerMenuTool.prepareAvatar(user);
        }
      }
    }
    else {
      BroadcastCenter.isNetConnected = false;
      CacheCenter.clearDownloading();
    }
  }

  static void onWsConnectedListener(){
    BroadcastCenter.isWsConnected = true;

    if (Session.hasAnyLogin()) {
      //final user = Session.getLastLoginUser()!;

      UserLoginTools.prepareRequestUsersProfileData();

      /*UserNotifierManager.managerFor(user.userId).requestNotifiers().then((value){
        BroadcastCenter.prepareBadgesAndRefresh();
      });*/
    }

    for(final fn in _wsConnectListeners){
      fn.call(true);
    }
  }

  static void onWsDisConnectedListener(){
    BroadcastCenter.isWsConnected = false;

    for(final fn in _wsConnectListeners){
      fn.call(false);
    }
  }
}
