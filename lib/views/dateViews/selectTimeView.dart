import 'package:flutter/material.dart';

import 'package:iris_tools/dateSection/ADateStructure.dart';
import 'package:iris_tools/dateSection/calendarTools.dart';
import 'package:iris_tools/modules/stateManagers/selfRefresh.dart';
import 'package:numberpicker/numberpicker.dart';

import '/managers/settingsManager.dart';
import '/system/extensions.dart';
import '/tools/app/appNavigator.dart';
import '/tools/app/appSizes.dart';
import '/tools/app/appThemes.dart';
import '/tools/centers/snackCenter.dart';

class SelectTimeView extends StatelessWidget {
  final String? title;
  final Color? iconColor;
  final TextStyle? textStyle;
  final DateTime? currentTime;
  final bool lockHour;
  final bool lockMin;

  SelectTimeView({
    this.title,
    this.currentTime,
    this.lockHour = false,
    this.lockMin = false,
    this.iconColor,
    this.textStyle,
    Key? key,
    }): super(key: key);

  @override
  Widget build(BuildContext context) {
    var selectedHour = 0;
    var selectedMin = 0;
    var isGregorian = true;
    ADateStructure current;

    isGregorian = SettingsManager.settingsModel.calendarType.type == TypeOfCalendar.gregorian;

    if(isGregorian) {
      current = currentTime == null? GregorianDate()
          : GregorianDate.hm(currentTime!.year, currentTime!.month, currentTime!.day, currentTime!.hour, currentTime!.minute);
    }
    else {
      current = currentTime == null? SolarHijriDate()
          : SolarHijriDate.from(currentTime!);

      current.changeTime(currentTime!.hour, currentTime!.minute, 0, 0);
    }

    selectedHour = current.hoursOfToday();
    selectedMin = current.minutesOfToday();

    //Color itemColor = iconColor?? AppThemes.currentTheme.textColor;

    return SizedBox(
      child: ColoredBox(
        color: AppThemes.currentTheme.backgroundColor,
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            child: SelfRefresh(
                builder: (context, ctr) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(),
                            ElevatedButton(
                              child: Text('${context.t('apply')}'),
                              onPressed: (){
                                ADateStructure date;

                                if(isGregorian) {
                                  date = GregorianDate.hm(2000, 1, 1, selectedHour, selectedMin);
                                }
                                else {
                                  date = SolarHijriDate.hm(1380, 1, 1, selectedHour, selectedMin);
                                }

                                if(!date.isValidDate()){
                                  SnackCenter.showFlashBarError(context, context.tC('dateIsNotValid')!);
                                  return;
                                }

                                final sd = date.convertToSystemDate();

                                AppNavigator.pop(context, result: sd);
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10,),

                      if(title != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                          child: Text('$title').color(AppThemes.currentTheme.textColor),
                        ),

                      const SizedBox(height: 20,),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: SizedBox(
                          height: AppSizes.fwSize(120),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IgnorePointer(
                                ignoring: lockHour,
                                child: NumberPicker(
                                  minValue: 0,
                                  maxValue: 23,
                                  value: selectedHour,
                                  axis: Axis.vertical,
                                  haptics: true,
                                  zeroPad: true,
                                  infiniteLoop: true,
                                  itemWidth: 50,
                                  itemHeight: 40,
                                  textStyle: AppThemes.baseTextStyle().copyWith(
                                    fontSize: AppSizes.fwFontSize(16),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  selectedTextStyle: TextStyle(
                                    fontSize: AppSizes.fwFontSize(16),
                                    fontWeight: FontWeight.bold,
                                    color: AppThemes.currentTheme.activeItemColor,
                                  ),
                                  textMapper: (t){
                                    return t.toString().localeNum();
                                  },
                                  onChanged: (val){
                                    selectedHour = val;
                                    ctr.update();
                                  },
                                ),
                              ),

                              ///--- minutes
                              IgnorePointer(
                                ignoring: lockMin,
                                child: NumberPicker(
                                  minValue: 0,
                                  maxValue: 59,
                                  value: selectedMin,
                                  axis: Axis.vertical,
                                  haptics: true,
                                  zeroPad: true,
                                  infiniteLoop: true,
                                  itemWidth: 50,
                                  itemHeight: 40,
                                  textStyle: AppThemes.baseTextStyle().copyWith(
                                    fontSize: AppSizes.fwFontSize(15),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  selectedTextStyle: TextStyle(
                                    fontSize: AppSizes.fwFontSize(16),
                                    fontWeight: FontWeight.bold,
                                    color: AppThemes.currentTheme.activeItemColor,
                                  ),
                                  textMapper: (t){
                                    return t.toString().localeNum();
                                  },
                                  onChanged: (val){
                                    selectedMin = val;
                                    ctr.update();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  );
                }
            ),
          ),
        ),
      ),
    );
  }
}
