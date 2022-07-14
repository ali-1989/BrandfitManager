import 'package:flutter/material.dart';

import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:iris_tools/api/helpers/ClipboardHelper.dart';
import 'package:iris_tools/widgets/horizontalPicker.dart';
import 'package:iris_tools/widgets/icon/circularIcon.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '/abstracts/stateBase.dart';
import '/screens/commons/countrySelect.dart';
import '/screens/profile/personalInfoCtr.dart';
import '/system/extensions.dart';
import '/system/session.dart';
import '/tools/app/appNavigator.dart';
import '/tools/app/appSizes.dart';
import '/tools/app/appThemes.dart';
import '/tools/centers/sheetCenter.dart';
import '/tools/centers/snackCenter.dart';
import '/views/dateViews/selectDateCalendarView.dart';

class PersonalInfoScreen extends StatefulWidget {
  static const screenName = 'PersonalInfoScreen';

  PersonalInfoScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PersonalInfoScreenState();
  }
}
///========================================================================================================
class PersonalInfoScreenState extends StateBase<PersonalInfoScreen> {
  StateXController stateController = StateXController();
  PersonalInfoCtr controller = PersonalInfoCtr();

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
      child: Scaffold(
        key: scaffoldKey,
        appBar: getAppbar(),
        body: getMainBuilder(),
      ),
    );
  }

  PreferredSizeWidget getAppbar() {
    return AppBar(
      title: Text(tC('personalInformation')!),
    );
  }

  Widget getMainBuilder(){
    return StateX(
        controller: stateController,
        isMain: true,
        builder: (ctx, ctr, data){
      return getBody();
    });
  }

  Widget getBody() {
    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(),
      //height: AppSizes.getScreenHeight(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: AppThemes.currentTheme.activeItemColor.withAlpha(150),
              width: 0.8,
            ),
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            children: <Widget>[
              getUserNameOp(),
              const Divider(indent: 10, endIndent: 10,),
              getMobileNumberOp(),
              const Divider(indent: 10, endIndent: 10,),
              getNameFamilyOp(),
              const Divider(indent: 10, endIndent: 10,),
              getSexOp(),
              const Divider(indent: 10, endIndent: 10,),
              getAgeOp(),
              const Divider(indent: 10, endIndent: 10,),
              getHeightOp(),
              const Divider(indent: 10, endIndent: 10,),
              getWeightOp(),
              const Divider(indent: 10, endIndent: 10,),
              getCountryOp(),
            ],
          ),
        ),
      ),
    );
  }
  ///========================================================================================================
  Widget getUserNameOp(){
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        ClipboardHelper.insert(controller.user.userName);
        SnackCenter.showSnack(context, tC('copiedToClipboard')!);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 22),
        child: Row(
          children: [
            Text('${t('userName')}').infoColor(),
            const SizedBox(width: 8,),
            Expanded(
              child: AutoSizeText(controller.user.userName,
                maxLines: 1,
                softWrap: false,
                textAlign: TextAlign.end,
                style: AppThemes.baseTextStyle().copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8,),
            Icon(Icons.copy,
              size: 18,
              textDirection: AppThemes.getOppositeDirection(),
            )
          ],
        ),
      ),
    );
  }

  Widget getMobileNumberOp(){
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        ClipboardHelper.insert(controller.user.mobileNumber?? '');
        //SnackCenter.showSnack(context, tC('copiedToClipboard')!);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 22),
        child: Row(
          children: [
            Text('${t('mobileNumber')}').infoColor(),
            const SizedBox(width: 8,),
            Expanded(
              child: AutoSizeText(controller.user.mobileNumber?? '',
                overflow: TextOverflow.fade,
                maxLines: 1,
                softWrap: false,
                textAlign: TextAlign.end,
                style: AppThemes.baseTextStyle().copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8,),
          ],
        ),
      ),
    );

  }

  Widget getNameFamilyOp(){
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        controller.showEditNameScreen('EditNameScreen');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 22),
        child: Row(
          children: [
            Text('${t('name')}').infoColor(),
            const SizedBox(width: 8,),
            Expanded(
                child: AutoSizeText(controller.user.nameFamily,
                  maxLines: 1,
                  softWrap: false,
                  textAlign: TextAlign.end,
                  style: AppThemes.baseTextStyle().copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                )
            ),
            const SizedBox(width: 8,),
            Icon(Icons.arrow_back_ios,
              size: 12,
              textDirection: AppThemes.getOppositeDirection(),
            )
          ],
        ),
      ),
    );
  }

  Widget getSexOp(){
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        showChangeSex('ChangeSexSheet');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 22),
        child: Row(
          children: [
            Text('${t('gender')}').infoColor(),
            const SizedBox(width: 8,),
            const Expanded(
              child: SizedBox(width: 8),
            ),
            Text(Session.getSexEquivalent(controller.user.sex)).bold(),
            const SizedBox(width: 8,),
            Icon(Icons.arrow_back_ios,
              size: 12,
              textDirection: AppThemes.getOppositeDirection(),
            )
          ],
        ),
      ),
    );
  }

  Widget getHeightOp(){
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        showChangeHeight('ChangeHeightSheet');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 22),
        child: Row(
          children: [
            Text('${t('heightMan')}').infoColor(),
            const SizedBox(width: 8,),
            const Expanded(
              child: SizedBox(width: 8),
            ),
            Builder(builder: (ctx){
              if(controller.user.fitnessDataModel.height == null) {
                return Text('${t('select')}',).bold().color(Colors.blue);
              }
              else {
                return Row(
                    children: [
                      Text('${controller.user.fitnessDataModel.height}',).bold(),
                      const SizedBox(width: 8,),
                      Icon(Icons.arrow_back_ios,
                        size: 12,
                        textDirection: AppThemes.getOppositeDirection(),
                      )
                    ]
                );
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget getWeightOp(){
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        showChangeWeight('ChangeWeightSheet');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 22),
        child: Row(
          children: [
            Text('${t('weight')}').infoColor(),
            const SizedBox(width: 8,),
            const Expanded(
              child: SizedBox(width: 8),
            ),
            Builder(builder: (ctx){
              if(controller.user.fitnessDataModel.weight == null) {
                return Text('${t('select')}',).bold().color(Colors.blue);
              }
              else {
                return Row(
                    children: [
                      Text('${controller.user.fitnessDataModel.weight}',).bold(),
                      const SizedBox(width: 8,),
                      Icon(Icons.arrow_back_ios,
                        size: 12,
                        textDirection: AppThemes.getOppositeDirection(),
                      )
                    ]
                );
              }
            }
            ),
          ],
        ),
      ),
    );
  }

  Widget getAgeOp(){
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        showChangeAge('ChangeAgeSheet');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 22),
        child: Row(
          children: [
            Text('${t('age')}').infoColor(),
            const SizedBox(width: 8,),
            const Expanded(
              child: SizedBox(width: 8),
            ),
            Text('${controller.user.age}',).bold(),
            const SizedBox(width: 8,),
            Icon(Icons.arrow_back_ios,
              size: 12,
              textDirection: AppThemes.getOppositeDirection(),
            )
          ],
        ),
      ),
    );
  }

  Widget getCountryOp(){
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        showChangeCountryScreen();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 22),
        child: Row(
          children: [
            Text('${t('country')}').infoColor(),
            const SizedBox(width: 8,),
            Expanded(
              child: Text(controller.countryName,
                overflow: TextOverflow.fade,
                softWrap: false,
                maxLines: 1,
                textAlign: TextAlign.end,
              ).bold(),
            ),
            const SizedBox(width: 8,),
            Icon(Icons.arrow_back_ios,
              size: 12,
              textDirection: AppThemes.getOppositeDirection(),
            )
          ],
        ),
      ),
    );
  }

  void showChangeSex(String screenName){
    var selectedGender = controller.user.sex-1; //1 man, 2 woman

    if(selectedGender < 0){
      selectedGender = 0;
    }

    final Widget view = SizedBox(
      width: AppSizes.getScreenWidth(context),
      child:  Column(
        children: [
          Transform.translate(
            offset: const Offset(0, -18),
            child: GestureDetector(
              onTap: (){AppNavigator.pop(context);},
              child: CircularIcon(
                icon: Icons.close,
                size: 38,
                padding: 6,
                backColor: AppThemes.currentTheme.backgroundColor,
                itemColor: AppThemes.currentTheme.textColor,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: FlipInX(
              delay: const Duration(milliseconds: 300),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('${tC('gender')}:').bold().fs(16),
                  SizedBox(height: AppSizes.fwSize(16),),
                  ToggleSwitch(
                    initialLabelIndex: selectedGender,
                    cornerRadius: 12.0,
                    //minWidth: 100,
                    activeBgColor: [AppThemes.currentTheme.activeItemColor],
                    inactiveBgColor: Colors.grey[400],
                    activeFgColor: Colors.white,
                    inactiveFgColor: AppThemes.currentTheme.inactiveTextColor,
                    totalSwitches: 2,
                    textDirectionRTL: true,
                    labels: [tC('male')!, tC('female')!],
                    onToggle: (index) {
                      selectedGender = index!;
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    SheetCenter.showSheetCustom(
      context,
      view,
      useExpanded: false,
      positiveButton: ElevatedButton(
        child: Text('${tC('apply')}'),
        onPressed: (){
          controller.uploadGender(selectedGender+1);
        },
      ),
      routeName: 'ChangeSex',
      backgroundColor: AppThemes.currentTheme.backgroundColor,
      contentColor: AppThemes.currentTheme.backgroundColor,
    ).then((value){
      update();
    });
  }

  void showChangeHeight(String screenName){
    var selectedHeight = controller.user.fitnessDataModel.height?? 170;

    final Widget view = SizedBox(
      width: AppSizes.getScreenWidth(context),
      child:  Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: const Offset(0, -18),
            child: GestureDetector(
              onTap: (){AppNavigator.pop(context);},
              child: CircularIcon(
                icon: Icons.close,
                size: 38,
                padding: 6,
                backColor: AppThemes.currentTheme.backgroundColor,
                itemColor: AppThemes.currentTheme.textColor,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: FlipInX(
              delay: const Duration(milliseconds: 300),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('${tC('heightMan')}:').bold().fs(16),
                  SizedBox(height: AppSizes.fwSize(16),),
                  HorizontalPicker(
                    //controller: hBmiController,
                    minValue: 40,
                    maxValue: 220,
                    suffix: ' cm',
                    showCursor: true,
                    cursorValue: selectedHeight,
                    cellWidth: 70,
                    height: 70,
                    backgroundColor: AppThemes.currentTheme.backgroundColor,
                    itemBackgroundColor: AppThemes.currentTheme.backgroundColor,
                    selectedStyle: AppThemes.baseTextStyle().copyWith(
                        color: AppThemes.currentTheme.activeItemColor),
                    cursorColor: AppThemes.currentTheme.activeItemColor.withAlpha(150),
                    onChanged: (value) {
                      selectedHeight = value as double;
                      //update();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    SheetCenter.showSheetCustom(
      context,
      view,
      useExpanded: false,
      positiveButton: ElevatedButton(
        child: Text('${tC('apply')}'),
        onPressed: (){
          controller.uploadHeight(selectedHeight);
        },
      ),
      routeName: 'ChangeHeight',
      backgroundColor: AppThemes.currentTheme.backgroundColor,
      contentColor: AppThemes.currentTheme.backgroundColor,
    ).then((value){
      update();
    });
  }

  void showChangeWeight(String screenName){
    var selectedWeight = controller.user.fitnessDataModel.weight?? 80;

    final Widget view = SizedBox(
      width: AppSizes.getScreenWidth(context),
      child:  Column(
        children: [
          Transform.translate(
            offset: const Offset(0, -18),
            child: GestureDetector(
              onTap: (){AppNavigator.pop(context);},
              child: CircularIcon(
                icon: Icons.close,
                size: 38,
                padding: 6,
                backColor: AppThemes.currentTheme.backgroundColor,
                itemColor: AppThemes.currentTheme.textColor,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: FlipInX(
              delay: const Duration(milliseconds: 300),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('${tC('weight')}:').bold().fs(16),
                  SizedBox(height: AppSizes.fwSize(16),),
                  HorizontalPicker(
                    //controller: wBmiController,
                    minValue: 10,
                    maxValue: 200,
                    subStepsCount: 0,
                    suffix: ' kg',
                    showCursor: true,
                    cursorValue: selectedWeight,
                    height: 70,
                    backgroundColor: AppThemes.currentTheme.backgroundColor,
                    itemBackgroundColor: AppThemes.currentTheme.backgroundColor,
                    selectedStyle: AppThemes.baseTextStyle().copyWith(
                        color: AppThemes.currentTheme.activeItemColor),
                    cursorColor: AppThemes.currentTheme.activeItemColor.withAlpha(150),
                    onChanged: (value) {
                      selectedWeight = value as double;
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    SheetCenter.showSheetCustom(
      context,
      view,
      useExpanded: false,
      positiveButton: ElevatedButton(
        child: Text('${tC('apply')}'),
        onPressed: (){
          controller.uploadWeight(selectedWeight);
        },
      ),
      routeName: 'ChangeWeight',
      backgroundColor: AppThemes.currentTheme.backgroundColor,
      contentColor: AppThemes.currentTheme.backgroundColor,
    ).then((value){
      update();
    });
  }

  void showChangeAge(String screenName){
    final birthDate = controller.user.birthDate ?? DateTime(DateTime.now().year - 20);
    final Widget view = SelectDateCalendarView(
      currentDate: birthDate,
      minYear: 1925,
      maxYear: DateTime.now().year - 5,
      onSelect: (date) {
        controller.uploadBirthDate(date);
      },
    );

    SheetCenter.showSheetCustom(
      context,
      view,
      useExpanded: false,
      routeName: 'ChangeAge',
      backgroundColor: AppThemes.currentTheme.backgroundColor,
      contentColor: AppThemes.currentTheme.backgroundColor,
    ).then((value){
      stateController.updateMain();
    });
  }

  void showChangeCountryScreen(){
    AppNavigator.pushNextPage(context, CountrySelectScreen(), name: CountrySelectScreen.screenName).then((value) {
      final country = value as Map;

      if(country.isNotEmpty){
        final String countryName = country['name'] + (country['native_name']!= null? ' (${country['native_name']})': '');
        final String countryCode = country['phone_code'];
        final String countryIso = country['iso'];

        controller.uploadCountryIso(countryCode,  countryIso, countryName);
      }
    });
  }
}



