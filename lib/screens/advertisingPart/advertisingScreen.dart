import 'dart:async';

import 'package:flutter/material.dart';

import 'package:badges/badges.dart';
import 'package:iris_tools/widgets/searchBar.dart';
import 'package:iris_tools/widgets/sizePosition/sizeReporter.dart';
import 'package:iris_tools/modules/stateManagers/refresh.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' as pull;

import '/abstracts/stateBase.dart';
import '/screens/advertisingPart/addAdvertising/addNewAdvertising.dart';
import '/screens/advertisingPart/advertisingScreenCtr.dart';
import '/screens/advertisingPart/viewAdvertising/advertisingListView.dart';
import '/system/extensions.dart';
import '/system/icons.dart';
import '/system/keys.dart';
import '/system/session.dart';
import '/tools/app/appNavigator.dart';
import '/tools/app/appThemes.dart';
import '/views/messageViews/communicationErrorView.dart';
import '/views/messageViews/mustLoginView.dart';
import '/views/messageViews/notDataFoundView.dart';
import '/views/messageViews/serverResponseWrongView.dart';
import '/views/preWidgets.dart';

class AdvertisingScreen extends StatefulWidget {
  static const screenName = 'AdvertisingScreen';

  AdvertisingScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AdvertisingScreenState();
  }
}
///=======================================================================================================
class AdvertisingScreenState extends StateBase<AdvertisingScreen> {
  RefreshController appBarRefresher = RefreshController();
  StateXController stateController = StateXController();
  AdvertisingScreenCtr controller = AdvertisingScreenCtr();


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
    controller.mediaQuery ??= MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () => onWillBack(this),
      child: Material(
        child: SizedBox(
          width: controller.mediaQuery?.width,
          height: controller.mediaQuery?.height,
          child: getMainBuilder()
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
      title: Text(tC('advertisingManagement')!),
      bottom: PreferredSize(
        preferredSize: Size(controller.mediaQuery!.width, controller.toolbarHeight!),
        child: Builder(
          builder: (ctx){
            return Align(
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            child: SearchBar(
                              iconColor: AppThemes.checkPrimaryByWB(AppThemes.currentTheme.primaryColor, AppThemes.currentTheme.textColor),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                              hint: tInMap('optionsKeys', controller.filterRequest.getSearchSelectedForce().key)?? '',
                              shareTextController: (tCtr){
                                controller.searchEditController = tCtr;
                                tCtr.text = controller.filterRequest.getSearchSelectedForce().text?? '';
                              },
                              searchEvent: (text){
                                controller.onSearchBarSearch(text);
                              },
                              onClearEvent: (){
                                controller.onSearchBarClear();
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                                child: InkWell(
                                  child: Text(' ${tC('create')} ',
                                  ).whiteOrDifferentOnPrimary().bold(),
                                  onTap: () async {
                                    await Future.delayed(const Duration(milliseconds: 200));

                                    // ignore: unawaited_futures
                                    AppNavigator.pushNextPage(context, AddNewAdvertisingScreen(), name: AddNewAdvertisingScreen.screenName).then((value){
                                      if(value == null || value != Keys.ok){
                                        return;
                                      }

                                      controller.resetRequest();
                                    });
                                  },
                                ),
                              ),

                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                      icon: Icon(IconList.searchOpM).whiteOrDifferentOnPrimary(),
                                      onPressed: () async{
                                        (await controller.onSearchOptionClick.delay()).call();
                                      }
                                  ),

                                  IconButton(
                                      icon: Badge(
                                          padding: const EdgeInsets.all(4),
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
                              ),
                            ],
                          )
                        ],
                      );
                    }
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget getBody() {
    return pull.RefreshConfiguration(
        headerBuilder: () => pull.MaterialClassicHeader(
          color: AppThemes.checkPrimaryByWB(AppThemes.currentTheme.primaryColor, AppThemes.currentTheme.differentColor),
          //refreshStyle: pull.RefreshStyle.Follow,
        ),
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
          footer: pull.CustomFooter(
            loadStyle: pull.LoadStyle.ShowWhenLoading,
            builder: (BuildContext context, pull.LoadStatus? state){
              if(state == pull.LoadStatus.loading) {
                return SizedBox(
                  height: 80,
                  child: PreWidgets.flutterLoadingWidget$Center(),
                );
              }

              return const SizedBox();
            },
          ),
          child: CustomScrollView(
            slivers: <Widget>[

              getSliverAppBar(),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                sliver: Builder(
                    builder: (context) {
                      if(controller.advertisingList.isEmpty){
                        return SliverToBoxAdapter(
                            child: Column(
                              children: [
                                const SizedBox(height: 180,),
                                NotDataFoundView(),
                              ],
                            )
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final u = controller.advertisingList.elementAt(index);

                            return AdvertisingListView(u, this, key: ValueKey(u.id),);
                            //return Text('$index');
                          },
                          childCount: controller.advertisingList.length,
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
}
