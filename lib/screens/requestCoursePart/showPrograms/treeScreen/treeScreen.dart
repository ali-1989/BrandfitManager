import 'package:brandfit_manager/database/models/requestHybridModelDb.dart';
import 'package:brandfit_manager/screens/requestCoursePart/showPrograms/treeScreen/treeScreenCtr.dart';

import '/tools/dateTools.dart';
import 'package:flutter/material.dart';

import 'package:flutter_treeview/flutter_treeview.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';

import '/abstracts/stateBase.dart';
import '/models/dataModels/programModels/foodDay.dart';
import '/models/dataModels/programModels/foodMeal.dart';
import '/models/dataModels/programModels/foodProgramModel.dart';
import '/models/dataModels/programModels/foodSuggestion.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/system/extensions.dart';
import '/system/icons.dart';
import '/tools/app/appSizes.dart';
import '/tools/app/appThemes.dart';
import '/views/messageViews/communicationErrorView.dart';
import '/views/messageViews/serverResponseWrongView.dart';
import '/views/preWidgets.dart';

class TreeFoodProgramScreen extends StatefulWidget {
  static const screenName = 'TreeFoodProgramScreen';
  final RequestHybridModelDb requestHybridModel;
  final UserModel pupilUser;
  final FoodProgramModel programModel;

  TreeFoodProgramScreen({
    required this.requestHybridModel,
    required this.pupilUser,
    required this.programModel,
    Key? key,
    }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TreeFoodProgramScreenState();
  }
}
///=========================================================================================================
class TreeFoodProgramScreenState extends StateBase<TreeFoodProgramScreen> {
  final stateController = StateXController();
  final controller = TreeFoodProgramCtr();

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
          appBar: getAppbar(),
          body: SafeArea(
            child: getMainBuilder(),
          ),
        ),
      ),
    );
  }

  Widget getMainBuilder(){
    return StateX(
        isMain: true,
        controller: stateController,
        builder: (context, ctr, data) {
          switch(ctr.mainState){
            case StateXController.state$loading:
              return PreWidgets.flutterLoadingWidget$Center();
            case StateXController.state$netDisconnect:
              return CommunicationErrorView(this, tryAgain: controller.tryAgain);
            case StateXController.state$serverNotResponse:
              return ServerResponseWrongView(this, tryAgain: controller.tryAgain);
            default:
              return getBody();
          }
        }
    );
  }

  PreferredSizeWidget getAppbar(){
    return AppBar(
      title: Text(controller.requestHybridModel.title),
      actions: [
        TextButton(
          child: Text('${t('guide')}')
              .color(Colors.white),
          onPressed: controller.showHelp,
        ),
      ],
    );
  }

  Widget getBody(){
    return Column(
      children: [
        getHeader(),
        SizedBox(height: 10,),
        Expanded(child: getTreeView()),
        SizedBox(height: 10,),
      ],
    );
  }
  ///==========================================================================================================
  Widget getHeader(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                        onPressed: (){
                          controller.showBaseChart();
                        },
                        child: Text('${tInMap('treeFoodProgramPage', 'chart')}')
                    ),
                  ],
                )
              ],
            ),
          ),

          Divider(color: Colors.grey.shade300, indent: 20, endIndent: 20,),
        ],
      ),
    );
  }

  Widget getTreeView(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TreeView(
        //key: ValueKey(Generator.generateName(10)),
        controller: controller.treeViewController,
        theme: controller.treeViewTheme,
        allowParentSelect: true,
        onNodeTap: onNodeTap,
        nodeBuilder: genNodeView,
        onExpansionChanged: (key, state){
          Node? node = controller.treeViewController.getNode(key);

          if (node != null) {
            node.expanded = state;
            stateController.updateMain();
          }
        },
      ),
    );
  }

  Widget genNodeView(BuildContext ctx, Node node){
    Color color;
    final isDay = node.data is FoodDay;
    final isMeal = node.data is FoodMeal;

    if(isDay){
      color = AppThemes.currentTheme.infoColor;
      final day = node.data as FoodDay;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Text(node.label)
                .boldFont().fsR(3).color(color),
            SizedBox(width: 10),

            Visibility(
              visible: day.getReportDate() != null,
              child: Text(DateTools.dateOnlyRelative(day.getReportDate()))
                .subFont(),
            )
          ],
        ),
      );
    }
    else if(isMeal) {
      color = AppThemes.currentTheme.textColor;
      final meal = node.data as FoodMeal;

      return Row(
        children: [
          SizedBox(width: 30,),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Text(meal.title?? node.label).boldFont().color(color),
                SizedBox(width: 5,),
                /*IconButton(
                    onPressed: (){
                      controller.showFoodMealPrompt(node);
                    },
                    icon: Icon(IconList.settings, color: AppThemes.currentTheme.primaryColor,)
                ),
                SizedBox(width: 5,),*/
                Text('(${meal.percentOfCalories(controller.programModel.getPlanCalories()!)} % ${tInMap('materialFundamentals', 'calories')})').alpha(),
              ],
            ),
          ),
        ],
      );
    }
    else {
      color = AppThemes.currentTheme.textColor.withAlpha(150);
      final suggestion = node.data as FoodSuggestion;
      var name = node.label;

      if(suggestion.title != null){
        name += ' (${suggestion.title})';
      }

      return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: Row(
          children: [
            SizedBox(width: 60,),
            Row(
              children: [
                Text(name).boldFont().color(color),

                SizedBox(width: 4,),
                Visibility(
                    visible: suggestion.isBase,
                    child: Icon(IconList.pushPin, size: 18,).toColor(Colors.orange)
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  void onNodeTap(String nodeKey){
    controller.currentNodeKey = nodeKey;
    Node node = controller.treeViewController.getNode(nodeKey)!;
    //controller.treeViewController = controller.treeViewController.copyWith(selectedKey: nodeKey);

    void resetExpand(List<Node> list){
      for (var element in list) {
        element.expanded = false;
      }
    }

    if(node.data is FoodDay){
      if(!node.expanded) {
        resetExpand(controller.nodeList);
      }

      node.expanded = !node.expanded;
      stateController.updateMain();
    }
    else if(node.data is FoodMeal){
      if(!node.expanded) {
        resetExpand(controller.getParent(node.key)!.children);
      }

      node.expanded = !node.expanded;
      stateController.updateMain();
    }
    else if(node.data is FoodSuggestion){
      //controller.showFoodSuggestionPrompt(node);
    }
  }
}
