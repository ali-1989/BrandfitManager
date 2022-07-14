import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/stateX.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' as pull;

import '/abstracts/stateBase.dart';
import '/managers/userAdvancedManager.dart';
import '/screens/chatPart/chatScreenCtr.dart';
import '/screens/chatPart/listBuilder/listChildItem.dart';
import '/system/icons.dart';
import '/tools/app/appSizes.dart';
import '/tools/app/appThemes.dart';
import '/views/messageViews/serverResponseWrongView.dart';
import '/views/messageViews/notDataFoundView.dart';
import '/views/preWidgets.dart';

class ChatScreen extends StatefulWidget {
  static const screenName = 'ChatScreen';

  ChatScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ChatScreenState();
  }
}
///=========================================================================================================
class ChatScreenState extends StateBase<ChatScreen> {
  StateXController stateController = StateXController();
  ChatScreenCtr controller = ChatScreenCtr();

  @override
  void initState() {
    super.initState();

    controller.onInitState(this);
  }

  @override
  Widget build(BuildContext context) {
    rotateToPortrait();

    controller.onBuild();
    return getScaffold();
  }

  @override
  void dispose() {
    stateController.dispose();
    controller.onDispose();

    super.dispose();
  }

  Widget getScaffold() {
    return WillPopScope(
      onWillPop: () => onWillBack(this),
      child: SizedBox(
        width: AppSizes.getScreenWidth(context),
        height: AppSizes.getScreenHeight(context),
        child: Scaffold(
          appBar: getAppBar(),
          body: SafeArea(
              child: getMainBuilder()
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget getAppBar(){
    return AppBar(
      actions: [
        IconButton(
          onPressed: (){
            controller.showFilterPrompt();
          },
          icon: Icon(IconList.filterM),
        )
      ],
    );
  }

  Widget getMainBuilder(){
    return StateX(
        isMain: true,
        controller: stateController,
        builder: (context, ctr, data) {
          if(controller.user == null){
            return PreWidgets.flutterLoadingWidget$Center();
          }

          return getBody();
        }
    );
  }

  Widget getBody(){
    return Column(
      children: [
        Visibility(
          visible: controller.filterRequest.filterViewList.isNotEmpty,
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...genFilterItems()
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        Divider(color: Colors.grey.shade300,),

        Expanded(
          child: Builder(
            builder: (context) {
              switch(stateController.mainState){
                case StateXController.state$serverNotResponse:
                case StateXController.state$netDisconnect:
                case StateXController.state$error:
                  return SizedBox.expand(
                      child: Center(
                          child: ServerResponseWrongView(this, tryAgain: controller.tryAgain,)
                      )
                  );
                case StateXController.state$loading:
                  return PreWidgets.flutterLoadingWidget$Center();
              }

              if(controller.chatManager.allChatList.isEmpty){
                return NotDataFoundView();
              }

              return pull.RefreshConfiguration(
                  headerBuilder: pullHeader,
                  footerBuilder: () => const pull.ClassicFooter(),
                  headerTriggerDistance: 80.0,
                  footerTriggerDistance: 200.0,
                  //springDescription: SpringDescription(stiffness: 170, damping: 16, mass: 1.9),
                  maxOverScrollExtent: 100,
                  maxUnderScrollExtent: 0,
                  enableScrollWhenRefreshCompleted: true, // incompatible with PageView and TabBarView.
                  enableLoadingWhenFailed: true,
                  hideFooterWhenNotFull: true,
                  enableBallisticLoad: false,
                  enableBallisticRefresh: false,
                  skipCanRefresh: true,
                  child: pull.SmartRefresher(
                      enablePullDown: true,
                      enablePullUp: true,
                      controller: controller.pullLoadCtr,
                      onRefresh: () => controller.onRefresh(),
                      onLoading: () => controller.onLoadMore(),
                      footer: pullFooter(),
                      child: ListView.builder(
                        itemCount: controller.chatManager.allChatList.length,
                        itemBuilder: (ctx, idx){
                          final itm = controller.chatManager.allChatList[idx];
                          return ChatListItem(chatModel: itm,);
                        },
                  )
              )
              );
            }
          ),
        ),
      ],
    );
  }
///==========================================================================================================
  List<Widget> genFilterItems(){
    final res = <Widget>[];

    for(final k in controller.filterRequest.filterViewList) {
      for (final i in k.selectedList) {
        final user = UserAdvancedManager.getById(i);

        final chip = Padding(
          padding: EdgeInsets.symmetric(horizontal: 3),
          child: Chip(
            label: Text('${tInMap('chatPage', k.key)}: ${user?.userName}'),
            onDeleted: () {
              controller.removeFiltering(k, i);
            },
          ),);

        res.add(chip);
      }
    }

    return res;
  }

  Widget pullHeader(){
    return pull.MaterialClassicHeader(
      color: AppThemes.checkPrimaryByWB(AppThemes.currentTheme.primaryColor, AppThemes.currentTheme.differentColor),
      //refreshStyle: pull.RefreshStyle.Follow,
    );
  }

  Widget pullFooter(){
    return pull.CustomFooter(
      loadStyle: pull.LoadStyle.ShowWhenLoading,
      builder: (BuildContext context, pull.LoadStatus? state) {
        if (state == pull.LoadStatus.loading) {
          return SizedBox(
            height: 80,
            child: PreWidgets.flutterLoadingWidget$Center(),
          );
        }

        if (state == pull.LoadStatus.noMore || state == pull.LoadStatus.idle) {
          return SizedBox();
        }

        return SizedBox();
      },
    );
  }
}

