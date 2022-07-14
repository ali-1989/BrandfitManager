import 'package:flutter/material.dart';

import 'package:badges/badges.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';
import 'package:iris_tools/widgets/avatarChip.dart';
import 'package:iris_tools/widgets/searchBar.dart';
import 'package:iris_tools/widgets/sizePosition/sizeReporter.dart';
import 'package:iris_tools/modules/stateManagers/refresh.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';
import 'package:loadany/loadany.dart';

import '/abstracts/stateBase.dart';
import '/models/dataModels/usersModels/appUserModel.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/screens/commons/imageFullScreen.dart';
import '/screens/trainerManagementPart/trainerListViewCtr.dart';
import '/screens/trainerManagementPart/trainerManagementScreenCtr.dart';
import '/system/downloadUpload.dart';
import '/system/enums.dart';
import '/system/extensions.dart';
import '/system/icons.dart';
import '/system/keys.dart';
import '/system/session.dart';
import '/tools/app/appNavigator.dart';
import '/tools/app/appThemes.dart';
import '/tools/centers/directoriesCenter.dart';
import '/tools/permissionTools.dart';
import '/views/messageViews/communicationErrorView.dart';
import '/views/messageViews/mustLoginView.dart';
import '/views/messageViews/notDataFoundView.dart';
import '/views/messageViews/serverResponseWrongView.dart';
import '/views/preWidgets.dart';

part 'trainerListView.dart';

class TrainerManagementScreen extends StatefulWidget {
  static const screenName = 'TrainerManagementScreen';

  TrainerManagementScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TrainerManagementScreenState();
  }
}
///=======================================================================================================
class TrainerManagementScreenState extends StateBase<TrainerManagementScreen> {
  RefreshController appBarRefresher = RefreshController();
  StateXController stateController = StateXController();
  TrainerManagementScreenCtr controller = TrainerManagementScreenCtr();


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
    stateController.dispose();
    controller.onDispose();

    super.dispose();
  }

  Widget getMaterial() {
    controller.mediaQuery ??= MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () => onWillBack(this),
      child: Material(
        child: SizedBox(
          width: controller.mediaQuery?.width,
          height: controller.mediaQuery?.height,
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
      title: Text(tC('coachManagement')!),
      bottom: PreferredSize(
        preferredSize: Size(controller.mediaQuery!.width, controller.toolbarHeight),
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
                              onPressed: () async{
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
      /*flexibleSpace: FlexibleSpaceBar(
      title: Text(state.tC('managementUsers')!),
      centerTitle: true,
      collapseMode: CollapseMode.pin,
    ),*/
    );
  }

  Widget getBody() {
    return LoadAny(
      status: controller.loadStatus,
      footerHeight: 80,
      endLoadMore: controller.endLoadMore,
      bottomTriggerDistance: 400,
      onLoadMore: () => controller.onLoadMore(),
      loadMoreBuilder: (ctx, state){
        if(state == LoadStatus.loading) {
          return SizedBox(
            height: 80,
            child: PreWidgets.flutterLoadingWidget$Center(),
          );
        }

        if(state == LoadStatus.completed || state == LoadStatus.normal) {
          return SizedBox();
        }

        return null;
      },
      child: CustomScrollView(
        slivers: <Widget>[

          getSliverAppBar(),

          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            sliver: Builder(
                builder: (context) {
                  if(controller.userList.isEmpty){
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
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final u = controller.userList.elementAt(index);

                        return TrainerListView(u, controller.user!, controller.listChildren);
                        //return Text('$index');
                      },
                      childCount: controller.userList.length,
                    ),
                  );
                }
            ),
          ),
        ],
      ),
    );
  }
  ///=======================================================================================================
}


/*
@override
  void update() {

    if(controller.renderBoxContext != null && !controller.sliverDetected) {
      var renderBox = controller.renderBoxContext?.findRenderObject() as RenderBox;
      controller.toolbarHeight = renderBox.size.height;
      prit(controller.toolbarHeight);
      controller.sliverDetected = true;
    }
    else if(stateController.mainState == StateXController.state$normal && !controller.sliverDetected){
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        ///update for sliverAppBar
        update();
      });
    }

    super.update();
  }
 */
