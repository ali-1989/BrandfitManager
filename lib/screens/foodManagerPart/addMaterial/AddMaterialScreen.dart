import 'package:flutter/material.dart';

import 'package:animate_do/animate_do.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/api/tools.dart';
import 'package:iris_tools/models/dataModels/colorTheme.dart';
import 'package:iris_tools/widgets/optionsRow/checkRow.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';
import 'package:iris_tools/widgets/text/autoDirection.dart';

import '/abstracts/stateBase.dart';
import '/screens/foodManagerPart/addMaterial/AddMaterialScreenCtr.dart';
import '/screens/foodManagerPart/editMaterial/FundamentalView.dart';
import '/system/extensions.dart';
import '/system/icons.dart';
import '/tools/app/appSizes.dart';
import '/tools/app/appThemes.dart';
import '/views/messageViews/communicationErrorView.dart';
import '/views/messageViews/serverResponseWrongView.dart';
import '/views/preWidgets.dart';
import '/views/topErrorView.dart';
import '/views/topInfoView.dart';

class AddFoodMaterialScreen extends StatefulWidget {
  static const String screenName = 'AddFoodMaterialScreen';

  const AddFoodMaterialScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AddFoodMaterialScreenState();
  }
}
///=======================================================================================================
class AddFoodMaterialScreenState extends StateBase<AddFoodMaterialScreen> {
  AddMaterialScreenCtr controller = AddMaterialScreenCtr();
  var stateController = StateXController();
  late Color itemColor;
  late InputDecoration inputDecoration;
  late OutlineInputBorder border;


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

    border = OutlineInputBorder(borderSide: BorderSide(color: AppThemes.currentTheme.textColor));
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
          appBar: AppBar(title: Text(tInMap('foodProgramScreen','addFoodMaterial')!),),
          body: SafeArea(
            child: getBuilder()
          ),
        ),
      ),
    );
  }

  getBuilder() {
    return StateX(
        isMain: true,
        controller: stateController,
        builder: (context, ctr, data) {
          //if(!Session.hasAnyLogin())
          //return PreWidgets.embed$mustLogin(state, tryLogin);

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
        }
    );
  }

  Widget getBody() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: StateX(
        isSubMain: true,
          controller: stateController,
          builder: (ctx, ctr, data){
            return ListView(
              children: [
                SizedBox(height: 25,),

                TextField(
                  controller: controller.titleEditCtr,
                  enabled: controller.inCheckTitle,
                  textInputAction: TextInputAction.done,
                  maxLines: 1,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: t('title'),
                    hintStyle: AppThemes.infoTextStyle(),
                    border: border,
                    disabledBorder: border,
                    enabledBorder: border,
                    focusedBorder: border,
                    errorBorder: border,
                  ),
                ),

                SizedBox(height: 20,),

                SizedBox(
                  child: ElevatedButton(
                    child: Text('${controller.inCheckTitle? tC('check') : tC('change', key2: 'title')}'),
                    onPressed: (){
                      if(controller.inCheckTitle){
                        if(controller.titleEditCtr.text.trim().isNotEmpty) {
                          controller.requestCheckName();
                        }
                      }
                      else {
                        controller.sumCaloriesState = 0;
                        controller.inCheckTitle = true;
                        AnimationController? anim = stateController.object('ShowOptionsAnim');
                        anim?.reset();
                        stateController.updateMain();
                      }
                    },
                  ),
                ),

                FadeInUp(
                  duration: Duration(seconds: 1),
                  manualTrigger: true,
                  animate: false,
                  controller: (anim){
                    stateController.setObject('ShowOptionsAnim', anim);
                  },

                  child: Column(
                    children: [
                      SizedBox(height: 20,),
                      StateX(
                          id: 'ToggleButtons',
                          controller: stateController,
                          builder: (ctx, ctr, data) {
                            return LayoutBuilder(
                              builder: (ctx, layout){
                                var color = AppThemes.currentTheme.textColorOn(AppThemes.themeData.backgroundColor);
                                var selectedColor = AppThemes.currentTheme.whiteOrBlackOn(AppThemes.themeData.indicatorColor);
                                return ToggleButtons(
                                  constraints: BoxConstraints.expand(width: calcToggleWid(layout), height: 50),
                                  color: color,
                                  selectedColor: selectedColor,
                                  borderColor: AppThemes.themeData.textTheme.bodyText2?.color,
                                  selectedBorderColor: AppThemes.themeData.textTheme.bodyText2?.color,
                                  fillColor: AppThemes.themeData.indicatorColor,
                                  splashColor: AppThemes.themeData.colorScheme.secondary,
                                  highlightColor: AppThemes.themeData.colorScheme.secondary,
                                  disabledColor: AppThemes.themeData.disabledColor,
                                  disabledBorderColor: AppThemes.themeData.disabledColor,
                                  borderWidth: 1,
                                  //renderBorder: true,
                                  children: [
                                    Text(tInMap('foodProgramScreen','matter')!),
                                    Text(tInMap('foodProgramScreen','complement')!),
                                    Text(tInMap('foodProgramScreen','herbal_tea')!),
                                  ],
                                  isSelected: Tools.getTogglesSelected(controller.typeSelected),
                                  onPressed: (idx){
                                    controller.sumCaloriesState = 0;
                                    stateController.setOverlay(getTopOverlay);

                                    Tools.setToggleStateByIndex(controller.typeSelected, idx);

                                    if(Tools.getToggleSelectedName(controller.typeSelected) == 'matter'){
                                      controller.prepareMainFundamental();
                                    }
                                    else {
                                      controller.selectedFundamentals.removeWhere((element) => element.isMain);
                                    }

                                    stateController.updateSubMain();
                                  },
                                );
                              },
                            );
                          }
                      ),

                      SizedBox(height: 10,),
                      Card(
                        color: Colors.grey.shade300,
                        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${tInMap('foodProgramScreen','sameWords')}:')
                                      .boldFont(),

                                  IconButton(
                                      icon: Icon(IconList.addCircle),
                                      onPressed: (){
                                        controller.onAddSameWordClick();
                                      }),
                                ],
                              ),

                              Wrap(
                                alignment: WrapAlignment.start,
                                crossAxisAlignment: WrapCrossAlignment.start,
                                runAlignment: WrapAlignment.start,
                                direction: Axis.horizontal,
                                spacing: 2,
                                children: [
                                  ...genAlternativesItems()
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20,),
                      Card(
                        color: AppThemes.currentTheme.primaryWhiteBlackColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        child: Padding(
                          padding: EdgeInsets.all(9.0),//?.localeNum()
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

                                      stateController.updateSubMain();
                                    },
                                  ),
                                ),
                              ),


                            ],
                          ),
                        ),
                      ),

                      ...mainFundamentalViews(),

                      ...fundamentalViews(),

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
                                  child: Text('+ ${t('otherThings')}').boldFont().alpha(),
                                ),
                              ).wrapDotBorder(stroke: 1.2, color: Colors.black54),
                            ),
                          )
                        ],
                      )
                      ),

                      SizedBox(height: 10,),
                      CheckBoxRow(
                        mainAxisSize: MainAxisSize.max,
                          value: !controller.canShowFlag,
                          description: Text(t('temporaryStorage')!),
                          onChanged: (flag){
                            controller.canShowFlag = !flag;
                            stateController.updateSubMain();
                          }
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
            );
          }
      ),
    );
  }
  ///========================================================================================================
  List<Widget> genAlternativesItems(){
    List<Widget> res = [];

    for(var i in controller.alternatives){
      var w = Chip(
        backgroundColor: Colors.black54,
        label: Text(i),
        onDeleted: (){
          controller.alternatives.remove(i);
          stateController.updateSubMain();
        },
      );

      res.add(w);
    }

    return res;
  }

  List<Widget> mainFundamentalViews(){
    List<Widget> res = [];

    if(Tools.getToggleSelectedName(controller.typeSelected) != 'matter'){
      return res;
    }

    for(final holder in controller.selectedFundamentals){

      if(!holder.isMain){
        continue;
      }

      final r = Card(
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
                    builder: (ec) {
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
      );

      res.add(r);
    }

    return res;
  }

  List<Widget> fundamentalViews(){
    List<Widget> res = [];

    for(final holder in controller.selectedFundamentals){

      if(holder.isMain){
        continue;
      }

      final r = FadeInUp(
          child: Card(
            color: AppThemes.currentTheme.primaryWhiteBlackColor,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Theme(
                    data: AppThemes.dropdownTheme(context),
                    child: Container(
                      width: 100,
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

                          stateController.updateSubMain();
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
                        stateController.updateSubMain();
                      }
                  ),
                ],
              ),
            ),
          )
      );

      res.add(r);
    }

    return res;
  }

  double calcToggleWid(BoxConstraints constraints){
    var len = controller.typeSelected.length;

    if(constraints.hasBoundedWidth) {
      return (constraints.maxWidth / len) - (len*2);
    }

    return (AppSizes.getScreenWidth(context)) / len - (len*2);
  }

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
}

