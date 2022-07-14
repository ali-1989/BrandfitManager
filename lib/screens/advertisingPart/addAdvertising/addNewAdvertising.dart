import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/inputFormatter.dart';
import 'package:iris_tools/widgets/irisImageView.dart';
import 'package:iris_tools/widgets/optionsRow/checkRow.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '/abstracts/stateBase.dart';
import '/screens/advertisingPart/addAdvertising/addNewAdvertisingCtr.dart';
import '/system/extensions.dart';
import '/system/icons.dart';
import '/tools/app/appThemes.dart';
import '/tools/centers/sheetCenter.dart';
import '/tools/dateTools.dart';
import '/views/brokenImageView.dart';
import '/views/dateViews/selectDateTimeCalendarView.dart';
import '/views/messageViews/communicationErrorView.dart';
import '/views/messageViews/serverResponseWrongView.dart';
import '/views/preWidgets.dart';

class AddNewAdvertisingScreen extends StatefulWidget {
  static const screenName = 'AddNewAdvertisingScreen';

  AddNewAdvertisingScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AddNewAdvertisingScreenState();
  }
}
///=======================================================================================================
class AddNewAdvertisingScreenState extends StateBase<AddNewAdvertisingScreen> {
  StateXController stateController = StateXController();
  AddNewAdvertisingScreenCtr controller = AddNewAdvertisingScreenCtr();
  late InputDecoration inputDecoration;
  late OutlineInputBorder outlineInputBorder;
  late BorderSide borderSide;

  @override
  void initState() {
    super.initState();
    controller.onInitState(this);

    borderSide = BorderSide(color: AppThemes.currentTheme.textColor.withAlpha(100));
    outlineInputBorder = OutlineInputBorder(borderSide: borderSide);
    inputDecoration = InputDecoration(
      border: outlineInputBorder,
      enabledBorder: outlineInputBorder,
      focusedBorder: outlineInputBorder,
    );
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
      child: Scaffold(
        appBar: getAppBar(),
        body: SafeArea(
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
          /*if(!Session.hasAnyLogin())
                    return MustLoginView(this, loginFn: controller.tryLogin);*/

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

  PreferredSizeWidget getAppBar() {
    return AppBar(
      //backwardsCompatibility: true,
      //centerTitle: true,
      title: Text(tC('AddAnAd')!),
      actions: [
        IconButton(
          icon: Icon(IconList.checkM),
          onPressed: (){
            controller.tickBtn();
          },
        ),
      ],
    );
  }

  Widget getBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20,),
          Text('${tC('title', key2: 'advertising')}').bold().fsR(4),
          const SizedBox(height: 10,),
          Text('${tInMap('addAdvertisingPage', 'titleDescription')}').infoColor(),
          const SizedBox(height: 20,),
          TextField(
            controller: controller.titleCtr,
            textInputAction: TextInputAction.next,
            decoration: inputDecoration,
          ),

          const SizedBox(height: 30,),
          Text('${tC('type')}').bold().fsR(4),
          const SizedBox(height: 10,),
          Text('${tInMap('addAdvertisingPage', 'typeDescription')}').infoColor(),
          const SizedBox(height: 20,),
          ToggleSwitch(
            initialLabelIndex: controller.selectedType,
            cornerRadius: 12.0,
            //minWidth: 100,
            radiusStyle: false,
            activeBgColor: [AppThemes.currentTheme.activeItemColor],
            activeFgColor: Colors.white,
            totalSwitches: 3,
            textDirectionRTL: true,
            inactiveBgColor: AppThemes.currentTheme.inactiveBackColor,
            inactiveFgColor: AppThemes.currentTheme.inactiveTextColor,
            labels: controller.typeTranslates,
            onToggle: (index) {
              controller.selectedType = index!;
              stateController.updateMain();
            },
          ),

          const SizedBox(height: 30,),
          Text('${tC('tag')}').bold().fsR(4),
          const SizedBox(height: 10,),
          Text('${tInMap('addAdvertisingPage', 'tagDescription')}').infoColor(),
          const SizedBox(height: 20,),
          TextField(
            controller: controller.tagCtr,
            textInputAction: TextInputAction.next,
            decoration: inputDecoration,
          ),

          const SizedBox(height: 30,),
          Text('${tC('order')}').bold().fsR(4),
          const SizedBox(height: 10,),
          Text('${tInMap('addAdvertisingPage', 'orderDescription')}').infoColor(),
          const SizedBox(height: 20,),
          SizedBox(
            width: 50,
            child: TextField(
              controller: controller.orderCtr,
              textInputAction: TextInputAction.next,
              inputFormatters: [InputFormatter.inputFormatterDigitsOnly()],
              keyboardType: TextInputType.number,
              decoration: inputDecoration,
            ),
          ),


          const SizedBox(height: 30,),
          Text('${tC('link')}').bold().fsR(4),
          const SizedBox(height: 10,),
          Text('${tInMap('addAdvertisingPage', 'linkDescription')}').infoColor(),
          const SizedBox(height: 20,),
          TextField(
            controller: controller.linkCtr,
            minLines: 1,
            maxLines: 1,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.url,
            decoration: inputDecoration,
          ),

          const SizedBox(height: 30,),
          Text('${tC('status')}').bold().fsR(4),
          const SizedBox(height: 10,),
          Text('${tInMap('addAdvertisingPage', 'presentableDescription')}').infoColor(),
          const SizedBox(height: 20,),
          CheckBoxRow(
            value: controller.showToUser$op,
            description: Text(tC('presentable')!),
            onChanged: (v){
              controller.showToUser$op = v;
              stateController.updateMain();
            },
          ),

          const SizedBox(height: 30,),
          Text('${tC('startDate')}').bold().fsR(4),
          const SizedBox(height: 10,),
          Text('${tInMap('addAdvertisingPage', 'startDateDescription')}').infoColor(),
          const SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton(
                child: Text(t('set')!),
                onPressed: (){
                  SheetCenter.showSheetCustom(
                      context,
                    SelectDateTimeCalendarView(currentDate: controller.startShow$op,),
                    routeName: 'ChooseStartDate',
                  ).then((value){
                    if(value == null){
                      return;
                    }

                    controller.startShow$op = value;
                    controller.startShowText = DateTools.dateAndHmRelative(controller.startShow$op, isUtc: false);
                    stateController.updateMain();
                  });
                },
              ),

              const SizedBox(width: 10,),
              Text(controller.startShowText),
              const SizedBox(width: 10,),
              if(controller.startShow$op != null)
                TextButton(
                  child: Text('${t('delete')}'),
                  onPressed: (){
                    controller.startShow$op = null;
                    controller.startShowText = '';
                    stateController.updateMain();
                  },
                ),
            ],
          ),

          const SizedBox(height: 30,),
          Text('${tC('finishDate')}').bold().fsR(4),
          const SizedBox(height: 10,),
          Text('${tInMap('addAdvertisingPage', 'finishDateDescription')}').infoColor(),
          const SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton(
                child: Text(t('set')!),
                onPressed: (){
                  SheetCenter.showSheetCustom(
                      context,
                    SelectDateTimeCalendarView(currentDate: controller.finishShow$op,),
                      routeName: 'ChooseFinishDate',
                  ).then((value){
                    if(value == null){
                      return;
                    }

                    controller.finishShow$op = value;
                    controller.finishShowText = DateTools.dateAndHmRelative(controller.finishShow$op, isUtc: false);
                    stateController.updateMain();
                  });
                },
              ),

              const SizedBox(width: 10,),
              Text(controller.finishShowText),
              const SizedBox(width: 10,),
              if(controller.finishShow$op != null)
                TextButton(
                  child: Text('${t('delete')}'),
                  onPressed: (){
                    controller.finishShow$op = null;
                    controller.finishShowText = '';
                    stateController.updateMain();
                  },
                ),
            ],
          ),

          const SizedBox(height: 30,),
          Text('${tC('image')}').bold().fsR(4),
          if(controller.photoPath == null)
            SizedBox(
              width: 170,
              height: 170,
              child: Center(
                child: IconButton(
                    iconSize: 80,
                    icon: const Icon(Icons.add).siz(80),
                    onPressed: (){
                      controller.addPhoto();
                    }
                ).wrapDotBorder(color: AppThemes.currentTheme.textColor),
              ),
            ),

          if(controller.photoPath != null)
            SizedBox(
              width: 250,
              height: 170,
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: GestureDetector(
                  onTap: (){
                  },
                  onLongPress: (){
                    controller.deleteDialog();
                  },
                  child: IrisImageView(
                    beforeLoadWidget: PreWidgets.flutterLoadingWidget$Center(),
                    errorWidget: BrokenImageView(),
                    imagePath: controller.photoPath?? '',
                  ),
                ),
              ),
            ),

          const SizedBox(height: 30,),
        ],
      ),
    );
  }
  ///==========================================================================================================
}
