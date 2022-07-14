import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:badges/badges.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:iris_tools/modules/propertyNotifier/propertyChangeConsumer.dart';
import 'package:iris_tools/widgets/drawer/stackDrawer.dart';
import 'package:iris_tools/widgets/icon/circularIcon.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';

import '/abstracts/stateBase.dart';
import '/constants.dart';
import '/managers/settingsManager.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/screens/advertisingPart/advertisingScreen.dart';
import '/screens/chatPart/chatScreen.dart';
import '/screens/courseManagementPart/courseManagementScreen.dart';
import '/screens/drawerMenu.dart';
import '/screens/foodManagerPart/foodManagementScreen.dart';
import '/screens/home/homeScreenCtr.dart';
import '/screens/profile/mainProfileScreen.dart';
import '/screens/requestCoursePart/requestScreen.dart';
import '/screens/supportPart/supportScreen.dart';
import '/screens/trainerManagementPart/trainerManagementScreen.dart';
import '/screens/userManagementPart/userManagementScreen.dart';
import '/system/extensions.dart';
import '/system/icons.dart';
import '/system/session.dart';
import '/tools/app/appNavigator.dart';
import '/tools/app/appThemes.dart';
import '/tools/centers/dialogCenter.dart';

class HomeScreen extends StatefulWidget {
  static const screenName = '/home_page';

  HomeScreen({Key? key}) :super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomeScreenState();
  }
}
///====================================================================================================
class HomeScreenState extends StateBase<HomeScreen> with TickerProviderStateMixin {
  StateXController stateController = StateXController();
  HomeScreenCtr controller = HomeScreenCtr();
  late AnimationController menuButtonAnimController;
  String drawerName = 'homePage';

  HomeScreenState();

  @override
  void initState() {
    super.initState();

    menuButtonAnimController =
        AnimationController(vsync: this, duration: Duration(milliseconds: SettingsManager.drawerMenuTimeMill));

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
    menuButtonAnimController.dispose();
    stateController.dispose();
    controller.onDispose();

    super.dispose();
  }

  /*@override no need
  void onBackButton<s extends StateBase>(s state, {dynamic result}) {
    SystemNavigator.pop();
  }*/

  @override
  Future<bool> onWillBack<s extends StateBase>(s state) {
    //old: state.scaffoldKey.currentState
    if(DrawerStacks.isOpen(drawerName)){
      //old: Navigator.of(state.context).pop();
      controller.toggleDrawer();
      return Future<bool>.value(false);
    }

    if(SettingsManager.settingsModel.confirmOnExit) {
      return DialogCenter().showDialog$wantClose(context);
    } else {
      return Future<bool>.value(true);
    }
    //SystemNavigator.pop();   this is close system
  }

  Widget getScaffold() {
    return WillPopScope(
        onWillPop: () => onWillBack(this),
        child: StateX(
          isMain: true,
            controller: stateController,
            builder: (ctx, ctr, data) {
              return DrawerStack(
                name: drawerName,
                factor: 220,
                gestureThreshold: 10,
                backgroundColor: Colors.grey[800],
                rtlDirection: AppThemes.isRtlDirection(),
                drawer: getDrawerView(),
                body: Scaffold(
                  key: scaffoldKey,
                  appBar: getAppBar(),
                  body: getBody(),
                  //drawer: getDrawer(state),
                  drawerEdgeDragWidth: 20.0,
                  drawerDragStartBehavior: DragStartBehavior.start,
                ),

                onStartOpen: (){
                  menuButtonAnimController.forward();
                },

                onStartClose: (){
                  menuButtonAnimController.reverse();
                },
              );
            })
    );
  }

  PreferredSizeWidget getAppBar() {
    return AppBar(
      primary: true,
      title: Text(Constants.appTitle),
      automaticallyImplyLeading: false, // false: remove (backBtn or drawer menu)

      leading: RotatedBox(
        quarterTurns: AppThemes.isRtlDirection()? 2:0,
        child: IconButton(
          icon: AnimatedIcon(
            textDirection: TextDirection.ltr,
            icon: AnimatedIcons.menu_arrow,
            progress: menuButtonAnimController,
          ),
          onPressed: (){
            controller.toggleDrawer();
          },),
      ),

      actions: <Widget>[
        if(Session.hasAnyLogin())
          GestureDetector(
            onTap: (){
              AppNavigator.pushNextPage(context, UserProfileScreen(), name: UserProfileScreen.screenName);
            },
            child: SizedBox(
              width: 34, height: 34,
              child: PropertyChangeConsumer<UserModel, UserModelNotifierMode>(
                model: Session.getLastLoginUser()!,
                properties: [UserModelNotifierMode.profilePath],
                builder: (context, model, properties){
                  if(model!.profileProvider != null && Session.hasAnyLogin()) {
                    return CircleAvatar(
                      backgroundImage: model.profileProvider,
                    );
                  }

                  return IconButton(
                    onPressed: (){
                      AppNavigator.pushNextPage(context, UserProfileScreen(), name: UserProfileScreen.screenName);
                    },
                    icon: Icon(IconList.accountDoubleCircle, size: 34,),
                    iconSize: 34,
                    padding: EdgeInsets.zero,
                  );
                },
              ),
            ),
          ),

        SizedBox(
          width: 20,
        ),
      ],
      //leading:
    );
  }

  Widget getDrawerView() {
    return SizedBox(
      width: 250,
      child: DrawerMenuTool.getDrawerMenu(context, controller.onDrawerMenuClick),
    );
  }

  Widget getBody() {
    return SingleChildScrollView(
      child: Table(
        defaultColumnWidth: FractionColumnWidth(0.5),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        textDirection: TextDirection.ltr,
        children: [
          ...generateTiles()
        ],
      ),
    );
  }
  ///==========================================================================================================
  List<TableRow> generateTiles(){
    //double height = AppSizes.getScreenWidth(state.context)/2;
    final height = 130.0;
    final res = <TableRow>[];

    final t1 = TableRow(
        children: [
          generateTile(height, CommunityMaterialIcons.account_multiple, tC('managementUsers')!, null, (){
            AppNavigator.pushNextPage(context, UserManagementScreen(), name: UserManagementScreen.screenName);
          }),
          generateTile(height, CommunityMaterialIcons.account_tie_voice, tC('coachManagement')!, null, (){
            AppNavigator.pushNextPage(context, TrainerManagementScreen(), name: TrainerManagementScreen.screenName);
          }),
        ]
    );

    final t2 = TableRow(
        children: [
          generateTile(height, CommunityMaterialIcons.food_fork_drink, tC('dietPlanManagement')!, null, (){
            AppNavigator.pushNextPage(context, FoodManagementScreen(), name: FoodManagementScreen.screenName);
          }),
          generateTile(height, CommunityMaterialIcons.hiking, tC('exercisePlanManagement')!, null, (){}),
        ]
    );

    final t3 = TableRow(
        children: [
          generateTile(height, CommunityMaterialIcons.chat_processing, tC('manageChats')!, null, (){
            AppNavigator.pushNextPage(context, ChatScreen(), name: ChatScreen.screenName);
          }),
          generateTile(height, CommunityMaterialIcons.check_box_multiple_outline, tC('supportSection')!, null, (){
            AppNavigator.pushNextPage(context, SupportScreen(), name: SupportScreen.screenName);
          }),
        ]
    );

    final t4 = TableRow(
        children: [
          generateTile(height, CommunityMaterialIcons.barcode, tC('advertisingManagement')!, null, (){
            AppNavigator.pushNextPage(context, AdvertisingScreen(), name: AdvertisingScreen.screenName);
          }),
          generateTile(height, CommunityMaterialIcons.ballot_recount, tInMap('navNames', 'courseManagement')!, null, (){
            AppNavigator.pushNextPage(context, CourseManagementScreen(), name: CourseManagementScreen.screenName);
          }),
        ]
    );

    final t5 = TableRow(
        children: [
          generateTile(height, IconList.report2, tInMap('navNames', 'requests')!, null, (){
            AppNavigator.pushNextPage(context, RequestScreen(), name: RequestScreen.screenName);
          }),

          SizedBox(),
        ]
    );

    /*TableRow t5 = TableRow(
      children: [
        generateTile(height, CommunityMaterialIcons.book, state.tC('termsConditionsSection')!, null, (){}),
        generateTile(height, CommunityMaterialIcons.android_messages, state.tC('aboutUsSection')!, null, (){}),
      ]
  );*/

    res.add(t1);
    res.add(t2);
    res.add(t3);
    res.add(t4);
    res.add(t5);

    return res;
  }

  Widget generateTile(double height, IconData icon, String text, dynamic badge, Function onTap){

    return SizedBox(
      height: height,
      child: Card(
        margin: EdgeInsets.all(8),
        child: InkWell(
          splashColor: AppThemes.currentTheme.fabBackColor,
          onTap: (){
            onTap.delay().then((value) => value.call());
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8,),
                Badge(
                  showBadge: badge != null,
                  animationType: BadgeAnimationType.fade,
                  badgeColor: AppThemes.currentTheme.badgeBackColor,
                  position: BadgePosition.topEnd(),
                  shape: BadgeShape.circle,
                  badgeContent: Text('$badge').color(AppThemes.currentTheme.badgeTextColor),
                  child: CircularIcon(
                    backColor: AppThemes.currentTheme.fabBackColor.withAlpha(70),
                    itemColor: AppThemes.currentTheme.fabBackColor,
                    icon: icon,
                    size: 42,
                    padding: 15,
                  ),
                ),

                SizedBox(height: 20,),
                Text(text).bold().fs(14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
