import 'package:flutter/material.dart';

import 'package:animate_do/animate_do.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/models/dataModels/colorTheme.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';
import 'package:iris_tools/widgets/text/autoDirection.dart';

import '/abstracts/stateBase.dart';
import '/models/dataModels/foodModels/materialModel.dart';
import '/screens/foodManagerPart/editMaterial/FundamentalView.dart';
import '/screens/foodManagerPart/editMaterial/editPropertiesScreenCtr.dart';
import '/system/extensions.dart';
import '/system/icons.dart';
import '/tools/app/appSizes.dart';
import '/tools/app/appThemes.dart';
import '/views/topErrorView.dart';
import '/views/topInfoView.dart';

class EditPropertiesScreen extends StatefulWidget {
  static const screenName = 'EditPropertiesScreen';
  final MaterialModel materialModel;

  EditPropertiesScreen(this.materialModel, {Key? key}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EditPropertiesScreenState();
  }
}
///=====================================================================================================
class EditPropertiesScreenState extends StateBase<EditPropertiesScreen> {
  var stateController = StateXController();
  var controller = EditPropertiesScreenCtr();
  late Color itemColor;
  late InputDecoration inputDecoration;
  int animCounter = 0;
  bool isFirstRun = true;

  @override
  void initState() {
    super.initState();
    controller.onInitState(this);

    itemColor = AppThemes.currentTheme.whiteOrBlackOn(AppThemes.currentTheme.primaryWhiteBlackColor);

    inputDecoration = ColorTheme.noneBordersInputDecoration.copyWith(
      hintText: t('value'),
      hintStyle: TextStyle(color: itemColor),
      border: UnderlineInputBorder(borderSide: BorderSide(color: itemColor)),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: itemColor)),
      constraints: BoxConstraints.tightFor(height: 40),
      contentPadding: EdgeInsets.all(0),
    );

    final c = widget.materialModel.mainFundamentals.length + widget.materialModel.otherFundamentals.length;

    Future.delayed(Duration(milliseconds: c * 150), (){
      animCounter = 0;
      isFirstRun = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    controller.onBuild();

    return getScaffold();
  }

  @override
  void dispose() {
    controller.onDispose();

    super.dispose();
  }

  Widget getScaffold(){
    return WillPopScope(
      onWillPop: () => onWillBack(this),
      child: SizedBox(
          width: AppSizes.getScreenWidth(context),
          height: AppSizes.getScreenHeight(context),
          child: Scaffold(
            appBar: AppBar(),
            body: SafeArea(
              child: getMainBuilder()
            )
          )
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

  Widget getBody(){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          SizedBox(height: 50,),

          Card(
            color: AppThemes.currentTheme.primaryWhiteBlackColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: EdgeInsets.all(9.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${tInMap('foodProgramScreen','valueIn')}')
                      .bold().fsR(2)
                      .color(itemColor),

                  SizedBox(width: 10,),

                  SizedBox(
                    width: 50,
                    child: AutoDirection(
                        builder: (context, dCtr) {
                          return TextField(
                            controller: controller.measureCtr,
                            style: TextStyle(color: itemColor),
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.number,
                            decoration: inputDecoration,
                            onTap: (){
                              dCtr.manageSelection(controller.measureCtr);
                            },
                            onChanged: (txt){
                              controller.measureModel.unitValue = MathHelper.clearToInt(txt).toString();
                            },
                          );
                        }
                    ),
                  ),
                  SizedBox(width: 16,),

                  Theme(
                    data: AppThemes.dropdownTheme(context),
                    child: Container(
                      width: 110,
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: AppThemes.dropdownDecoration(color: Colors.grey.withAlpha(100)),

                      child: DropdownButton<String>(
                        items: controller.getDropdownMeasureItems(),
                        value: controller.measureModel.unit,
                        iconEnabledColor: Colors.white,
                        iconDisabledColor: Colors.white,
                        underline: SizedBox(),
                        isExpanded: true,
                        onChanged: (String? v){
                          controller.measureModel.unit = v?? 'gram';

                          stateController.updateMain();
                        },
                      ),
                    ),
                  ),


                ],
              ),
            ),
          ),

          Expanded(
            child: ListView(
              children: [
                ...mainFundamentalViews(),
                ...otherFundamentalViews(),

                SizedBox(height: 20,),

                Visibility(
                  visible: controller.selectedFundamentals.length < controller.allFundamentals.length,
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: (){
                              controller.onAddOtherFundamentalClick();
                            },
                            child: SizedBox(
                              height: 50,
                              child: Center(
                                child: Text('+ ${t('otherThings')}').bold(),
                              ),
                            ).wrapDotBorder(stroke: 1.2),
                          ),
                        )
                      ],
                    )
                ),

                SizedBox(height: 20,),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: Text('${t('save')}'),
                    onPressed: (){
                      controller.onSaveClick();
                    },
                  ),
                ),

                SizedBox(height: 30,),
              ],
            ),
          ),
        ],
      ),
    );
  }
  ///===============================================================================================
  Widget getTopOverlay(BuildContext ctx){
    if(controller.sumCaloriesState == 1){
      return TopInfoView(
        Text('${tInMap('foodProgramScreen', 'notCaloriesValueOk')}',
          textAlign: TextAlign.center,)
            .color(Colors.black)
            .fsR(1)
            .bold(weight: FontWeight.w800),
      );
    }

    if(controller.sumCaloriesState == 2){
      // Flash, Pulse (zoom), Swing(alaKolang), Bounce(up then down)
      return Bounce(
          animate: false,
          manualTrigger: true,
          controller: (ctr){
            stateController.setObject('errorOverlayAnim', ctr);
          },
          child: TopErrorView(
            Text('${tInMap('foodProgramScreen', 'notCaloriesValueOk')}',
              textAlign: TextAlign.center,)
                .color(Colors.white)
                .fsR(1)
                .bold(weight: FontWeight.w800),
          )
      );
    }

    return SizedBox();
  }

  List<Widget> mainFundamentalViews(){
    final res = <Widget>[];

    if(!controller.materialModel.isMatter()){
      return res;
    }

    //for(var i=0; i< Keys.mainMaterialFundamentals.length; i++){
    for(final holder in controller.selectedFundamentals){

      if(!holder.isMain){
        continue;
      }

      final r = FadeInUp(
        delay: Duration(milliseconds: animCounter * 150),
        child: Card(
          color: AppThemes.currentTheme.primaryWhiteBlackColor,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                SizedBox(
                    width: 85,
                    child: Text('${controller.allFundamentals[holder.fundamental.key]}:')
                        .color(itemColor).bold()
                ),

                SizedBox(width: 16,),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0,0,0,5),
                  child: SizedBox(
                    width: 50,
                    child: FundamentalView(
                        fundamentalHolder: holder,
                        builder: (ec){
                          if(holder.fundamental.value != null) {
                            ec.text = holder.fundamental.value!;
                          }

                          return AutoDirection(
                              builder: (context, dCtr) {
                                return TextField(
                                  controller: ec,
                                  style: TextStyle(color: itemColor),
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.number,
                                  decoration: inputDecoration,
                                  onTap: (){
                                    dCtr.manageSelection(ec);
                                  },
                                  onChanged: (txt){
                                    holder.fundamental.value = txt;

                                    controller.checkSumCalories();
                                  },
                                );
                              }
                          );
                        }
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      if(isFirstRun) {
        animCounter++;
      }

      res.add(r);
    }

    return res;
  }

  List<Widget> otherFundamentalViews(){
    List<Widget> res = [];

    for(final holder in controller.selectedFundamentals){

      if(holder.isMain){
        continue;
      }

      final r = FadeInUp(
          delay: Duration(milliseconds: animCounter * 150),
          child: Card(
            color: AppThemes.currentTheme.primaryWhiteBlackColor,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Theme(
                    data: AppThemes.dropdownTheme(context),
                    child: Container(
                      width: 110,
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: AppThemes.dropdownDecoration(color: Colors.grey.withAlpha(100)),

                      child: DropdownButton<String>(
                        items: controller.getDropdownItems(holder.fundamental.key),
                        value: holder.fundamental.key,
                        iconEnabledColor: Colors.white,
                        iconDisabledColor: Colors.white,
                        underline: SizedBox(),
                        isExpanded: true,
                        onChanged: (String? v){
                          holder.fundamental.key = v?? '';
                          controller.checkRepeatSelected();
                          stateController.updateMain();
                        },
                      ),
                    ),
                  ),

                  SizedBox(width: 16,),
                  SizedBox(
                    width: 50,
                    child: FundamentalView(
                      fundamentalHolder: holder,
                      builder: (ec) {
                        if(holder.fundamental.value != null) {
                          ec.text = holder.fundamental.value!;
                        }

                        return AutoDirection(
                          builder: (context, dCtr) {
                            return TextField(
                              controller: ec,
                              style: TextStyle(color: itemColor),
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.number,
                              decoration: inputDecoration,
                              onTap: (){
                                dCtr.manageSelection(ec);
                              },
                              onChanged: (txt){
                                holder.fundamental.value = txt;

                                //controller.checkSumCalories();
                              },
                            );
                          }
                        );
                      }
                    ),
                  ),

                  Expanded(child: SizedBox(),),
                  IconButton(
                      icon: Icon(IconList.delete).toColor(itemColor),
                      onPressed: (){
                        controller.selectedFundamentals.remove(holder);
                        stateController.updateMain();
                      }
                  ),
                ],
              ),
            ),
          )
      );

      if(isFirstRun) {
        animCounter++;
      }

      res.add(r);
    }

    return res;
  }
}
