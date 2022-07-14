import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/stateX.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import '/abstracts/stateBase.dart';
import '/screens/chatPart/filteringPart/FilteringCtr.dart';
import '/system/extensions.dart';
import '/system/queryFiltering.dart';
import '/tools/app/appThemes.dart';

class FilteringScreen extends StatefulWidget {
  static const screenName = 'FilteringScreen';

  final FilterRequest filterRequest;

  const FilteringScreen({
    required this.filterRequest,
    Key? key,
  }) : super(key: key);

  @override
  State<FilteringScreen> createState() => FilteringScreenState();
}
///================================================================================================
class FilteringScreenState extends StateBase<FilteringScreen> {
  StateXController stateController = StateXController();
  FilteringCtr controller = FilteringCtr();


  @override
  void initState() {
    super.initState();

    controller.onInitState(this);
  }

  @override
  Widget build(BuildContext context) {
    controller.onBuild();

    return Scaffold(
      //appBar: getAppBar(),
      body: StateX(
          controller: stateController,
          isMain: true,
          builder: (context, ctr, data) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: 85,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Builder(
                      builder: (context) {
                        if(controller.userList.isEmpty){
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Text('${tInMap('chatPage', 'searchUserDescription')}', textAlign: TextAlign.center,)
                                  .boldFont().alpha(),
                            ),
                          );
                        }

                        return Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                  itemCount: controller.userList.length,
                                  shrinkWrap: false,
                                  itemBuilder: (ctx, idx){
                                    return genListItem(idx);
                                  }
                              ),
                            ),
                          ],
                        );
                      }
                  ),
                ),

                Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    height: 85,
                    width: double.infinity,
                    child: ColoredBox(
                      color: AppThemes.currentTheme.appBarBackColor,
                    ),
                  ),
                ),

                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: getSearchBar(),
                ),
              ],
            );
          }
      ),
    );
  }

  @override
  void dispose() {
    stateController.dispose();
    controller.onDispose();

    super.dispose();
  }

  PreferredSizeWidget getAppBar(){
    return AppBar();
  }

  Widget getSearchBar(){
    return FloatingSearchBar(
      hint: '${t('search')}...',
      controller: controller.searchBarCtr,
      scrollPadding: const EdgeInsets.only(top: 20, bottom: 30),
      transitionDuration: const Duration(milliseconds: 500),
      debounceDelay: const Duration(milliseconds: 800),//delay char type to call query
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: 0.0,
      openAxisAlignment: 0.0,
      automaticallyImplyBackButton: true,
      clearQueryOnClose: false,
      closeOnBackdropTap: true,
      actions: [],
      leadingActions: [],
      progress: controller.showProgress,
      onQueryChanged: (query) {
        controller.requestUser(query);
      },
      //transition: CircularFloatingSearchBarTransition(),
      transition: SlideFadeFloatingSearchBarTransition(),
      builder: (context, transition) {
        if(true){
          return SizedBox();
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: controller.userList.length,
                itemBuilder: (ctx, idx){
                  return genSearchItem(idx);
                }
            ),
          ),
        );
      },
    );
  }

  Widget genSearchItem(int idx){
    final user = controller.userList[idx];

    return GestureDetector(
      onTap: (){
        controller.onClickOnUser(user);
      },
      child: Card(
          color: AppThemes.currentTheme.accentColor,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.userName)
                        .fsR(6).bold()
                        .whiteOrAppBarItemOn(AppThemes.currentTheme.accentColor),
                    SizedBox(height: 8,),
                  ],
                ),
              ],
            ),
          )
      ),
    );
  }

  Widget genListItem(int idx){
    final user = controller.userList[idx];

    return GestureDetector(
      onTap: (){
        controller.onClickOnUser(user);
      },
      child: Card(
          color: AppThemes.currentTheme.accentColor,
          child: Padding(
            padding: EdgeInsets.all(7.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(user.userName)
                              .fsR(5).bold()
                              .whiteOrAppBarItemOn(AppThemes.currentTheme.accentColor),

                          Text(user.userType == 1? '${tInMap('chatPage', 'by_pupil_user')}' : '${tInMap('chatPage', 'by_trainer_user')}')
                              .subFont()
                              .whiteOrAppBarItemOn(AppThemes.currentTheme.accentColor),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(user.nameFamily)
                              .bold()
                              .whiteOrAppBarItemOn(AppThemes.currentTheme.accentColor),

                          Text(user.mobileNumber?? '')
                              .bold()
                              .whiteOrAppBarItemOn(AppThemes.currentTheme.accentColor),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 2,),
              ],
            ),
          )
      ),
    );
  }
}
