import 'package:flutter/material.dart';

import 'package:iris_tools/widgets/optionsRow/checkRow.dart';
import 'package:iris_tools/widgets/searchBar.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' as pull;

import '/abstracts/stateBase.dart';
import '/screens/requestCoursePart/requestScreenCtr.dart';
import '/system/extensions.dart';
import '/system/icons.dart';
import '/tools/app/appThemes.dart';
import '/tools/dateTools.dart';
import '/views/messageViews/mustLoginView.dart';
import '/views/messageViews/notDataFoundView.dart';
import '/views/messageViews/serverResponseWrongView.dart';
import '/views/preWidgets.dart';

class RequestScreen extends StatefulWidget {
  static const screenName = 'RequestScreen';

  RequestScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RequestScreenState();
  }
}
///=========================================================================================================
class RequestScreenState extends StateBase<RequestScreen> {
  StateXController stateController = StateXController();
  RequestScreenCtr controller = RequestScreenCtr();

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

  Widget getScaffold(){
    return WillPopScope(
        onWillPop: () => onWillBack(this),
      child: Scaffold(
        appBar: AppBar(title: Text('${tInMap('navNames', 'requests')}'),),
        body: getMainBuilder(),
      ),
    );
  }

  Widget getMainBuilder(){
    return StateX(
        isMain: true,
        controller: stateController,
        builder: (context, ctr, data) {
            if(controller.user == null) {
              return MustLoginView(this, loginFn: controller.tryLogin,);
            }
          switch(ctr.mainState){
              case StateXController.state$loading:
                return PreWidgets.flutterLoadingWidget$Center();
              case StateXController.state$netDisconnect:
              case StateXController.state$serverNotResponse:
                return ServerResponseWrongView(this, tryAgain: controller.tryAgain,);
              default:
              return getBody();
          }
        }
    );
  }

  Widget getBody() {
    return Column(
      children: [
        ColoredBox(
          color: AppThemes.currentTheme.appBarBackColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal:8.0),
                child: Row(
                  children: [
                    IconButton(
                        icon: Icon(IconList.searchOpM).whiteOrDifferentOnPrimary(),
                        onPressed: () async{
                          (await controller.onSearchOptionClick.delay()).call();
                        }
                    ),

                    Expanded(
                      child: SearchBar(
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
                  ],
                ),
              ),

              Row(
                children: [
                  CheckBoxRow(
                    value: controller.pendingRequestOp,
                    tickColor: AppThemes.currentTheme.appBarBackColor,
                    borderColor: Colors.white,
                    description: Text('${tInMap('optionsKeys', 'pendingRequestMode')}').color(Colors.white),
                    onChanged: (v) {
                      controller.pendingRequestOp = v;

                      stateController.mainStateAndUpdate(StateXController.state$loading);
                      controller.resetRequest();
                    },
                  ),
                  CheckBoxRow(
                    value: controller.acceptRequestOp,
                    tickColor: AppThemes.currentTheme.appBarBackColor,
                    borderColor: Colors.white,
                    description: Text('${tInMap('optionsKeys', 'acceptedRequestMode')}').color(Colors.white),
                    onChanged: (v) {
                      controller.acceptRequestOp = v;

                      stateController.mainStateAndUpdate(StateXController.state$loading);
                      controller.resetRequest();
                    },
                  ),
                  CheckBoxRow(
                    value: controller.rejectRequestOp,
                    tickColor: AppThemes.currentTheme.appBarBackColor,
                    borderColor: Colors.white,
                    description: Text('${tInMap('optionsKeys', 'rejectRequestMode')}').color(Colors.white),
                    onChanged: (v) {
                      controller.rejectRequestOp = v;

                      stateController.mainStateAndUpdate(StateXController.state$loading);
                      controller.resetRequest();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: StateX(
            isSubMain: true,
            controller: stateController,
            builder: (ctx, ctr, data) {
              if (controller.requestManager!.requestList.isEmpty) {
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
                        itemCount: controller.requestManager!.requestList.length,
                        itemBuilder: (ctx, idx) {
                          return genListItem(idx);
                        })
                  )
              );
            },
          ),
        ),
      ],
    );
  }
  ///==========================================================================================================
  Widget genListItem(int idx){
    final cr = controller.requestManager!.requestList[idx];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(IconList.apps2, color: AppThemes.currentTheme.primaryColor,),
                const SizedBox(width: 8,),
                Text(cr.title).bold().fsR(2),
              ],
            ),

            const SizedBox(height: 15,),
            Text('${t('trainer')}: ${cr.trainerName()}').bold(),

            const SizedBox(height: 5,),
            Text('${t('pupil')}: ${cr.requesterName()}').bold(),

            const SizedBox(height: 5,),
            Text('${t('requestDate')}: ${DateTools.dateOnlyRelative(cr.requestDate)}').bold(),

            const SizedBox(height: 5,),
            Text('${t('status')}: ${cr.getStatusText(context)}')
                .bold().color(cr.getStatusColor()),

            const SizedBox(height: 5,),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Visibility(
                    visible: cr.isAccept,
                    child: ElevatedButton(
                        onPressed: (){
                          controller.gotoProgramsScreen(cr);
                        }, child: Text('  ${t('programs')}  ')
                    )
                ),

                SizedBox(width: 8,),

                ElevatedButton(
                    onPressed: (){
                      controller.requestCourseInfo(cr);
                    }, child: Text('  ${t('information')}  ')
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

