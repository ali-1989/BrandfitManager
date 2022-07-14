import 'package:flutter/material.dart';

import 'package:iris_tools/widgets/icon/circularIcon.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';

import '/abstracts/stateBase.dart';
import '/screens/foodManagerPart/addMaterial/AddMaterialScreen.dart';
import '/screens/foodManagerPart/foodManagementScreenCtr.dart';
import '/screens/foodManagerPart/materialList/foodMaterialListScreen.dart';
import '/system/extensions.dart';
import '/system/icons.dart';
import '/tools/app/appNavigator.dart';
import '/tools/app/appSizes.dart';
import '/tools/app/appThemes.dart';

class FoodManagementScreen extends StatefulWidget {
  static const screenName = 'FoodManagementScreen';

  FoodManagementScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FoodManagementScreenState();
  }
}
///=======================================================================================================
class FoodManagementScreenState extends StateBase<FoodManagementScreen> {
  var stateController = StateXController();
  var controller = FoodManagementScreenCtr();

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
    controller.onDispose();
    stateController.dispose();

    super.dispose();
  }

  Widget getScaffold() {
    return WillPopScope(
      onWillPop: () => onWillBack(this),
      child: SizedBox(
        width: AppSizes.getScreenWidth(context),
        height: AppSizes.getScreenHeight(context),
        child: Scaffold(
          key: scaffoldKey,
          appBar: AppBar(title: Text(tC('dietPlanManagement')!),),
          body: SafeArea(
              child: getMainBuilder(),
          ),
        ),
      ),
    );
  }

  Widget getMainBuilder(){
    return StateX(
      controller: stateController,
      isMain: true,
      builder: (context, ctr, data) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Builder(
              builder: (context) {
                switch(ctr.mainState){
                  default:
                    return getBody();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget getBody() {
    return ListView(
      children: [
        ...getMainItems(),
      ],
    );
  }
  ///========================================================================================================
  List<Widget> getMainItems(){
    List<Map> items = [];

    items.add({
      'title': tInMap('foodProgramScreen','addFoodMaterial')!,
      'icon': CircularIcon(
        icon: IconList.addCircle,
        backColor: AppThemes.currentTheme.primaryWhiteBlackColor.withAlpha(70),
        itemColor: AppThemes.currentTheme.primaryWhiteBlackColor,
      ),
      'fn': (){
        AppNavigator.pushNextPage(context, AddFoodMaterialScreen(), name: AddFoodMaterialScreen.screenName);
      },
    });

    items.add({
      'title': tInMap('foodProgramScreen','listOfFood')!,
      'icon': CircularIcon(
        icon: IconList.list,
        backColor: AppThemes.currentTheme.primaryWhiteBlackColor.withAlpha(70),
        itemColor: AppThemes.currentTheme.primaryWhiteBlackColor,
      ),
      'fn': (){
        AppNavigator.pushNextPage(context, FoodMaterialListScreen(), name: FoodMaterialListScreen.screenName);
      },
    });

    Widget genView(elm){
      return Card(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: InkWell(
          onTap: (){
            Function? fn = elm['fn'];

            fn?.delay().then((v) => v.call());
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(
              children: [
                elm['icon'],
                SizedBox(width: 10,),
                Text(elm['title'])
                    .bold(weight: FontWeight.w800)
                    .fsR(2).primaryOrAppBarItemOnBackColor(),
              ],
            ),
          ),
        ),
      );
    }

    return items.map(genView).toList();
  }
}
