import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/stateX.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' as pull;

import '/abstracts/stateBase.dart';
import '/screens/supportPart/allTicketsPageCtr.dart';
import '/screens/supportPart/listChildTicket.dart';
import '/screens/supportPart/supportScreenCtr.dart';
import '/screens/supportPart/unSeenTicketsPageCtr.dart';
import '/system/icons.dart';
import '/tools/app/appThemes.dart';
import '/views/messageViews/mustLoginView.dart';
import '/views/messageViews/notDataFoundView.dart';
import '/views/preWidgets.dart';

part 'unSeenTicketsPage.dart';
part 'allTicketsPage.dart';

class SupportScreen extends StatefulWidget {
  static const screenName = 'SupportScreen';

  SupportScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SupportScreenState();
  }
}
///=======================================================================================================
class SupportScreenState extends StateBase<SupportScreen> with SingleTickerProviderStateMixin {
  var stateController = StateXController();
  var controller = SupportScreenCtr();
  late TabController tabController;

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this);
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
      child: StateX(
          isMain: true,
          //id: SupportScreen.stateX_mainStateId,
          controller: stateController,
          builder: (context, ctr, data) {
            return Scaffold(
              key: scaffoldKey,
              appBar: getAppbar(),
              body: SafeArea(
                child: getMainBuilder(),
              ),
            );
        }
      ),
    );
  }

  getMainBuilder() {
    return StateX(
        isSubMain: true,
        controller: stateController,
        builder: (context, ctr, data) {
          return Builder(
            builder: (context) {
              if(controller.user == null){
                return MustLoginView(this);
              }

              return getBody();
            },
          );
        }
    );
  }

  PreferredSizeWidget getAppbar() {
    return AppBar(
      title: Text('${tC('supportSection')}'),
      bottom: TabBar(
        controller: tabController,
        tabs: [
          Tab(icon: Icon(IconList.itemListM),),
          Tab(icon: Icon(IconList.eye),),
        ],
        labelColor: AppThemes.currentTheme.whiteOrAppBarItemOnPrimary(),
        onTap: (i){},
      ),
    );
  }

  getBody() {
    return TabBarView(
        controller: tabController,
        children: [
          AllTicketsPage(parentState: this),
          UnSeenTicketsPage(parentState: this),
        ]
    );
  }
  ///=======================================================================================================
}
