import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:badges/badges.dart';
import 'package:iris_tools/api/cache/cacheMap.dart';
import 'package:iris_tools/widgets/irisImageView.dart';
import 'package:iris_tools/widgets/optionsRow/checkRow.dart';
import 'package:iris_tools/widgets/searchBar.dart';
import 'package:iris_tools/widgets/sizePosition/sizeReporter.dart';
import 'package:iris_tools/modules/stateManagers/refresh.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' as pull;

import '/abstracts/stateBase.dart';
import '/models/dataModels/courseModels/courseModel.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/screens/courseManagementPart/withoutSet/itemListViewCtr.dart';
import '/screens/courseManagementPart/withoutSet/managementWithoutSetScreenCtr.dart';
import '/system/enums.dart';
import '/system/extensions.dart';
import '/system/icons.dart';
import '/system/keys.dart';
import '/system/session.dart';
import '/tools/app/appNavigator.dart';
import '/tools/app/appThemes.dart';
import '/tools/centers/dialogCenter.dart';
import '/tools/centers/directoriesCenter.dart';
import '/tools/centers/sheetCenter.dart';
import '/tools/currencyTools.dart';
import '/views/messageViews/communicationErrorView.dart';
import '/views/messageViews/mustLoginView.dart';
import '/views/messageViews/notDataFoundView.dart';
import '/views/messageViews/serverResponseWrongView.dart';
import '/views/preWidgets.dart';

part 'itemListView.dart';

class CManagementWithoutSetScreen extends StatefulWidget {
  static const screenName = 'CManagementWithoutSetScreen';

  CManagementWithoutSetScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CManagementWithoutSetScreenState();
  }
}
///=======================================================================================================
class CManagementWithoutSetScreenState extends StateBase<CManagementWithoutSetScreen> {
  StateXController stateController = StateXController();
  CManagementWithoutSetScreenCtr controller = CManagementWithoutSetScreenCtr();
  RefreshController appBarRefresher = RefreshController();


  @override
  void initState() {
    super.initState();
    controller.onInitState(this);
  }

  @override
  Widget build(BuildContext context) {
    rotateToPortrait();
    controller.onBuild();

    return getMaterial();
  }

  @override
  void dispose() {
    controller.onDispose();
    stateController.dispose();

    super.dispose();
  }

  Widget getMaterial() {
    controller.mediaQuery = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () => onWillBack(this),
      child: Material(
        child: SizedBox(
          width: controller.mediaQuery!.width,
          height: controller.mediaQuery!.height,
          child: getMainBuilder(),
        ),
      ),
    );
  }

  Widget getMainBuilder(){
    return StateX(
        isMain: true,
        controller: stateController,
        builder: (context, ctr, data) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Builder(
                builder: (context) {
                  if(!Session.hasAnyLogin()) {
                    return MustLoginView(this, loginFn: controller.tryLogin);
                  }

                  switch(ctr.mainState){
                    case StateXController.state$loading:
                      return PreWidgets.flutterLoadingWidget$Center();
                    case StateXController.state$netDisconnect:
                      return CommunicationErrorView(this, tryAgain: controller.tryAgain,);
                    case StateXController.state$serverNotResponse:
                      return ServerResponseWrongView(this, tryAgain: controller.tryAgain);
                    default:
                      return getBody();
                  }
                },
              ),
            ],
          );
        }
    );
  }

  Widget getSliverAppBar() {
    return SliverAppBar(
      pinned: false,
      floating: true,
      snap: false,
      centerTitle: true,
      title: Text(tC('courseManagement')!),
      bottom: PreferredSize(
        preferredSize: Size(controller.mediaQuery!.width, controller.toolbarHeight!),
        child: Align(
          alignment: Alignment.topLeft,
          child: SizeReporter(
            onSizeChange: (s){
              controller.toolbarHeight = s.height;
              update();
            },
            child: Refresh(
                controller: appBarRefresher,
                builder: (context, ctr) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        child: SearchBar(
                          iconColor: AppThemes.checkPrimaryByWB(AppThemes.currentTheme.primaryColor, AppThemes.currentTheme.textColor),
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          hint: tInMap('optionsKeys', controller.filterRequest.getSearchSelectedForce().key)?? '',
                          shareTextController: (tCtr){
                            controller.searchEditController = tCtr;
                            tCtr.text = controller.filterRequest.getSearchSelectedForce().text?? '';
                          },
                          searchEvent: (text){
                            if(text == controller.filterRequest.getSearchSelectedForce().text){
                              return;
                            }

                            controller.filterRequest.setTextToSelectedSearch(text);
                            controller.resetRequest();
                          },
                          onClearEvent: (){
                            if(controller.filterRequest.getSearchSelectedForce().text == null){
                              return;
                            }

                            controller.filterRequest.setTextToSelectedSearch(null);
                            controller.resetRequest();
                          },
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                              icon: Icon(IconList.searchOpM).whiteOrDifferentOnPrimary(),
                              onPressed: () async {
                                (await controller.onSearchOptionClick.delay()).call();
                              }
                          ),

                          IconButton(
                              icon: Badge(
                                  padding: EdgeInsets.all(4),
                                  alignment: Alignment.center,
                                  badgeColor: AppThemes.currentTheme.badgeBackColor,
                                  showBadge: controller.filterRequest.toMapFiltering().isNotEmpty,
                                  position: BadgePosition.bottomStart(bottom: 2, start: 2),
                                  child: Icon(IconList.filterM).whiteOrDifferentOnPrimary()),
                              onPressed: () async{
                                (await controller.onFilterOptionClick.delay()).call();

                              }
                          ),

                          IconButton(
                            icon: Icon(IconList.sortAscM).whiteOrDifferentOnPrimary(),
                            onPressed: () async{
                              (await controller.onSortClick.delay()).call();
                            },
                          ),
                        ],
                      )
                    ],
                  );
                }
            ),
          ),
        ),
      ),
    );
  }

  Widget getBody() {
    return pull.RefreshConfiguration(
        headerBuilder: pullHeader,
        footerBuilder: () => pull.ClassicFooter(),
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
          child: CustomScrollView(
            slivers: <Widget>[

              getSliverAppBar(),

              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                sliver: Builder(
                    builder: (context) {
                      if(controller.itemList.isEmpty){
                        return SliverToBoxAdapter(
                            child: Column(
                              children: [
                                SizedBox(height: 180,),
                                NotDataFoundView(),
                              ],
                            )
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final u = controller.itemList.elementAt(index);

                          return ItemListView(u, controller.imageCache, controller.user!, controller.listChildren);
                          //return Text('$index');
                        },
                          childCount: controller.itemList.length,
                        ),
                      );
                    }
                ),
              ),
            ],
          ),
        )
    );
  }
  ///=======================================================================================================
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
