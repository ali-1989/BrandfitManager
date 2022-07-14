import 'package:flutter/material.dart';

import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:iris_tools/widgets/attribute.dart';
import 'package:iris_tools/widgets/horizontalPicker.dart';
import 'package:iris_tools/widgets/maxWidth.dart';
import 'package:iris_tools/widgets/multiSelect/multiSelect.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';
import 'package:simple_html_css/simple_html_css.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '/abstracts/stateBase.dart';
import '/screens/bmiPart/bmiScreenCtr.dart';
import '/system/extensions.dart';
import '/tools/app/appSizes.dart';
import '/tools/app/appThemes.dart';
import '/tools/centers/infoDisplayCenter.dart';

// https://drnematihonar.com/about-bmi/

class BmiScreen extends StatefulWidget {
  static const screenName = 'BmiScreen';

  BmiScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BmiScreenState();
  }
}
///=======================================================================================================
class BmiScreenState extends StateBase<BmiScreen> with SingleTickerProviderStateMixin {
  StateXController stateController = StateXController();
  BmiScreenCtr controller = BmiScreenCtr();
  late TabController tabController;
  String bmrResultRefresherKey = 'bmrResultRefresher';

  @override
  void initState() {
    super.initState();

    tabController = TabController(vsync: this, length: 2);
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
    tabController.dispose();
    controller.onDispose();

    super.dispose();
  }

  Widget getScaffold(){
    return ConstrainedBox(
      constraints: BoxConstraints.expand(),
      child: Scaffold(
        appBar: getAppBar(),
        body: SafeArea(
          child: getMainBuilder(),
        ),
      ),
    );
  }

  PreferredSizeWidget getAppBar(){
    return AppBar(
      title: Text(tC('bmi&bmr')!),
      bottom: TabBar(
        controller: tabController,
        isScrollable: false,
        mouseCursor: SystemMouseCursors.noDrop,
        padding: EdgeInsets.zero,
        automaticIndicatorColorAdjustment: true,
        //labelColor: AppThemes.currentTheme.infoTextColor,
        //unselectedLabelColor: AppThemes.currentTheme.infoTextColor,
        labelColor: AppThemes.currentTheme.whiteOrAppBarItemOnPrimary(),
        tabs: [
          Tab(
            text: tC('bmi'),
            height: 50,
            icon: Icon(CommunityMaterialIcons.human_male_height, size: 17,)
            .whiteOrAppBarItemOnPrimary()
                .alpha(),
          ),

          Tab(
            text: tC('bmr'),
            height: 50,
            icon: Icon(CommunityMaterialIcons.human_male_height_variant, size: 17,)
                .whiteOrAppBarItemOnPrimary()
                .alpha()
          ),
        ],
      ),
    );
  }

  Widget getMainBuilder(){
    return StateX(
      controller: stateController,
      isMain: true,
      builder: (context, ctr, data) {
        switch(ctr.mainState){
          default:
            return getBody();
        }
      },
    );
  }

  Widget getBody() {
    return TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [
          getBmiView(),
          getBmrView(),
        ]);
  }
  ///==========================================================================================
  Widget getBmiView(){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Center(
        child: MaxWidth(
          maxWidth: 400,
          child: SingleChildScrollView(
            child: Column(
              key: ValueKey(controller.bmiCodeGen.getCurrent()),
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: AppSizes.fwSize(30),),
                AutoSizeText(tC('calculateBMI')!).bold().fsR(2),

                SizedBox(height: AppSizes.fwSize(16),),
                Row(
                  children: [
                    Text('${tC('weight')}:').bold(),
                    SizedBox(width: 8,),

                    Expanded(
                      child: Row(
                        textDirection: TextDirection.ltr,
                        children: [
                          IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 12,
                              constraints: BoxConstraints.tight(Size(30,30)),
                              icon: Icon(Icons.arrow_back_ios, size: 12, textDirection: TextDirection.ltr,),
                              onPressed: (){
                                controller.wBmiController.back();
                              }
                          ),
                          Expanded(
                            child: HorizontalPicker(
                              controller: controller.wBmiController,
                              minValue: 10,
                              maxValue: 200,
                              subStepsCount: 0,
                              suffix: '',
                              showCursor: true,
                              cursorValue: controller.selectedWeight,
                              height: 70,
                              backgroundColor: AppThemes.currentTheme.backgroundColor,
                              itemBackgroundColor: AppThemes.currentTheme.backgroundColor,
                              selectedStyle: AppThemes.baseTextStyle().copyWith(
                                  color: AppThemes.currentTheme.activeItemColor),
                              cursorColor: AppThemes.currentTheme.activeItemColor.withAlpha(150),
                              onChanged: (value) {
                                controller.selectedWeight = value as double;
                                controller.calculateBmi();
                                stateController.updateMain();
                              },
                            ),
                          ),

                          Text(' kg', textDirection: TextDirection.ltr),
                          IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 12,
                              constraints: BoxConstraints.tight(Size(30,30)),
                              icon: Icon(Icons.arrow_back_ios, size: 12, textDirection: TextDirection.rtl,),
                              onPressed: (){
                                controller.wBmiController.forward();
                              }
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSizes.fwSize(16),),
                Row(
                  children: [
                    Text('${tC('heightMan')}:').bold(),
                    SizedBox(width: 8,),

                    Expanded(
                      child: Row(
                        textDirection: TextDirection.ltr,
                        children: [
                          IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 12,
                              constraints: BoxConstraints.tight(Size(30,30)),
                              icon: Icon(Icons.arrow_back_ios, size: 12, textDirection: TextDirection.ltr,),
                              onPressed: (){
                                controller.hBmiController.back();
                              }
                          ),
                          Expanded(
                            child: HorizontalPicker(
                              controller: controller.hBmiController,
                              minValue: 40,
                              maxValue: 220,
                              //subValues: [0.44, 0.75],
                              suffix: '',
                              showCursor: true,
                              cursorValue: controller.selectedHeight,
                              cellWidth: 70,
                              height: 70,
                              backgroundColor: AppThemes.currentTheme.backgroundColor,
                              itemBackgroundColor: AppThemes.currentTheme.backgroundColor,
                              selectedStyle: AppThemes.baseTextStyle().copyWith(
                                  color: AppThemes.currentTheme.activeItemColor),
                              cursorColor: AppThemes.currentTheme.activeItemColor.withAlpha(150),
                              onChanged: (value) {
                                controller.selectedHeight = value as double;
                                controller.calculateBmi();
                                stateController.updateMain();
                              },
                            ),
                          ),

                          Text(' cm', textDirection: TextDirection.ltr),
                          IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 12,
                              constraints: BoxConstraints.tight(Size(30,30)),
                              icon: Icon(Icons.arrow_back_ios, size: 12, textDirection: TextDirection.rtl,),
                              onPressed: (){
                                controller.hBmiController.forward();
                              }
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSizes.fwSize(35),),
                Column(
                  children: [
                    Text(t('yourBmi')!.replaceFirst(RegExp('#1'), controller.bmiResultNum.toString())).bold().fsR(2),
                    SizedBox(height: AppSizes.fwSize(3),),
                    Text(controller.bmiResultText).bold().fsR(2),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getBmrView(){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: MaxWidth(
          maxWidth: 400,
          child: SingleChildScrollView(
            child: Column(
              key: ValueKey(controller.bmrCodeGen.getCurrent()),
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: AppSizes.fwSize(30),),
                AutoSizeText(tC('calculateBMR')!).bold().fsR(2),

                SizedBox(height: AppSizes.fwSize(16),),
                Row(
                  children: [
                    Text('${tC('weight')}:').bold(),
                    SizedBox(width: 8,),

                    Expanded(
                      child: Row(
                        textDirection: TextDirection.ltr,
                        children: [
                          IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 12,
                              constraints: BoxConstraints.tight(Size(30,30)),
                              icon: Icon(Icons.arrow_back_ios, size: 12, textDirection: TextDirection.ltr,),
                              onPressed: (){
                                controller.wBmrController.back();
                              }
                          ),
                          Expanded(
                            child: HorizontalPicker(
                              controller: controller.wBmrController,
                              minValue: 10,
                              maxValue: 200,
                              subStepsCount: 0,
                              suffix: '',// kg
                              showCursor: true,
                              cursorValue: controller.selectedWeight,
                              height: 70,
                              backgroundColor: AppThemes.currentTheme.backgroundColor,
                              itemBackgroundColor: AppThemes.currentTheme.backgroundColor,
                              selectedStyle: AppThemes.baseTextStyle().copyWith(
                                  color: AppThemes.currentTheme.activeItemColor),
                              cursorColor: AppThemes.currentTheme.activeItemColor.withAlpha(150),
                              onChanged: (value) {
                                controller.selectedWeight = value as double;
                                controller.calculateBmr();
                                stateController.updateMain();
                              },
                            ),
                          ),

                          Text(' kg', textDirection: TextDirection.ltr),
                          IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 12,
                              constraints: BoxConstraints.tight(Size(30,30)),
                              icon: Icon(Icons.arrow_back_ios, size: 12, textDirection: TextDirection.rtl,),
                              onPressed: (){
                                controller.wBmrController.forward();
                              }
                          ),
                        ],
                      ),
                    )
                  ],
                ),

                SizedBox(height: AppSizes.fwSize(16),),
                Row(
                  children: [
                    Text('${tC('heightMan')}:').bold(),
                    SizedBox(width: 8,),

                    Expanded(
                      child: Row(
                        textDirection: TextDirection.ltr,
                        children: [
                          IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 12,
                              constraints: BoxConstraints.tight(Size(30,30)),
                              icon: Icon(Icons.arrow_back_ios, size: 12, textDirection: TextDirection.ltr,),
                              onPressed: (){
                                controller.hBmrController.back();
                              }
                          ),
                          Expanded(
                            child: HorizontalPicker(
                              controller: controller.hBmrController,
                              minValue: 40,
                              maxValue: 220,
                              //subValues: [0.44, 0.75],
                              suffix: '',
                              showCursor: true,
                              cursorValue: controller.selectedHeight,
                              cellWidth: 70,
                              height: 70,
                              backgroundColor: AppThemes.currentTheme.backgroundColor,
                              itemBackgroundColor: AppThemes.currentTheme.backgroundColor,
                              selectedStyle: AppThemes.baseTextStyle().copyWith(
                                  color: AppThemes.currentTheme.activeItemColor),//AppThemes.currentTheme.intelli$PrimaryOrDifferent),
                              cursorColor: AppThemes.currentTheme.activeItemColor.withAlpha(150),
                              onChanged: (value) {
                                controller.selectedHeight = value as double;
                                controller.calculateBmr();
                                stateController.updateMain();
                              },
                            ),
                          ),

                          Text(' cm', textDirection: TextDirection.ltr,),
                          IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 12,
                              constraints: BoxConstraints.tight(Size(30,30)),
                              icon: Icon(Icons.arrow_back_ios, size: 12, textDirection: TextDirection.rtl,),
                              onPressed: (){
                                controller.hBmrController.forward();
                              }
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSizes.fwSize(16),),
                Row(
                  children: [
                    Text('${tC('age')}:').bold(),
                    SizedBox(width: 8,),

                    Expanded(
                      child: HorizontalPicker(
                        controller: controller.aBmrController,
                        minValue: 7,
                        maxValue: 90,
                        suffix: '',
                        useIntOnly: true,
                        showCursor: true,
                        cursorValue: controller.selectedAge,
                        cellWidth: 40,
                        height: 70,
                        backgroundColor: AppThemes.currentTheme.backgroundColor,
                        itemBackgroundColor: AppThemes.currentTheme.backgroundColor,
                        selectedStyle: AppThemes.baseTextStyle().copyWith(
                            color: AppThemes.currentTheme.activeItemColor),
                        cursorColor: AppThemes.currentTheme.activeItemColor.withAlpha(150),
                        onChanged: (value) {
                          controller.selectedAge = value as int;
                          controller.calculateBmr();
                          stateController.update(bmrResultRefresherKey);
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSizes.fwSize(20),),
                Text('${tC('gender')}:').bold(),

                SizedBox(height: AppSizes.fwSize(12),),
                ToggleSwitch(
                  initialLabelIndex: controller.selectedGender,
                  cornerRadius: 12.0,
                  //minWidth: 100,
                  radiusStyle: false,
                  activeBgColor: [AppThemes.currentTheme.activeItemColor],
                  activeFgColor: Colors.white,
                  totalSwitches: 2,
                  textDirectionRTL: true,
                  inactiveBgColor: AppThemes.currentTheme.inactiveBackColor,
                  inactiveFgColor: AppThemes.currentTheme.inactiveTextColor,
                  labels: [tC('male')!, tC('female')!],//, '< ${state.tC('gender')} >'
                  onToggle: (index) {
                    controller.selectedGender = index!;
                    controller.calculateBmr();
                    stateController.update(bmrResultRefresherKey);
                  },
                ),

                SizedBox(height: AppSizes.fwSize(20),),
                Text('${tC('activityRate')}:').bold(),
                SizedBox(height: AppSizes.fwSize(5),),
                MultiSelect(
                  spacing: 4,
                  runSpacing: 0,
                  isRadio: true,
                  borderRadius: BorderRadius.circular(25.0),
                  selectedColor: AppThemes.currentTheme.activeItemColor,
                  unselectedColor: AppThemes.currentTheme.activeItemColor.withAlpha(90),
                  buttons: [
                    tC('bmrActivity1')!,
                    tC('bmrActivity2')!,
                    tC('bmrActivity3')!,
                    tC('bmrActivity4')!,
                  ],
                  selectedButton: controller.selectedActivityRate,
                  //selectedButtons: [state.selectedActivityRate],
                  onChangeState: (idx, value, isSelected){
                    controller.selectedActivityRate = idx;
                    controller.calculateBmr();
                    stateController.updateMain();
                  },
                ),

                SizedBox(height: AppSizes.fwSize(10),),
                Attribute(
                  childBuilder: (ctx, ctr){
                    return IconButton(
                      icon: Icon(CommunityMaterialIcons.help_circle),
                      color: AppThemes.currentTheme.activeItemColor,
                      onPressed: (){
                        InfoDisplayCenter.showMiniInfo(context,
                            HTML.toRichText(ctx,
                              tJoin('bmrDescriptionsInfo')!,
                              defaultTextStyle: AppThemes.baseTextStyle(),
                            ),
                          bottom: (AppSizes.getScreenHeight(ctx) - ctr.getPositionY()!) + 20,
                        center: false
                        );
                      },
                    );
                  },
                ),

                SizedBox(height: AppSizes.fwSize(10),),
                StateX(
                  id: bmrResultRefresherKey,
                    controller: stateController,
                    builder: (ctx, ctr, data){
                      return Column(
                        children: [
                          Text(t('yourBmr')!.replaceFirst(RegExp('#1'), controller.bmrResultNum.toInt().toString())).bold().fsR(2),
                          SizedBox(height: AppSizes.fwSize(2),),
                          Text(t('yourRegBmr')!.replaceFirst(RegExp('#1'), controller.bmrRegResultNum.toInt().toString())).bold().fsR(2),
                          SizedBox(height: AppSizes.fwSize(3),),
                          //Text('${state.t('yourBmr')!.replaceFirst(RegExp('#1'), state.bmrResultNum2.toString())}').bold().fsR(2),
                          //SizedBox(height: AppSizes.rSize(3),),
                        ],
                      );
                    }),

                SizedBox(height: AppSizes.fwSize(20),),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

