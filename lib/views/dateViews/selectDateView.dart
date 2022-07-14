import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/dateSection/ADateStructure.dart';
import 'package:iris_tools/modules/stateManagers/selfRefresh.dart';
import 'package:numberpicker/numberpicker.dart';

import '/system/extensions.dart';
import '/tools/app/appNavigator.dart';
import '/tools/app/appSizes.dart';
import '/tools/app/appThemes.dart';
import '/tools/centers/snackCenter.dart';
import '/tools/dateTools.dart';

class SelectDateView extends StatelessWidget {
  final String? title;
  final Color? iconColor;
  final TextStyle? textStyle;
  final DateTime? currentDate;
  final int? maxYear;
  final int? minYear;
  final bool lockYear;
  final bool lockMonth;
  final bool lockDay;

  SelectDateView({
    this.title,
    this.currentDate,
    this.maxYear,
    this.minYear,
    this.lockYear = false,
    this.lockMonth = false,
    this.lockDay = false,
    this.iconColor,
    this.textStyle,
    Key? key,
    }): super(key: key);

  @override
  Widget build(BuildContext context) {
    var selectedYear = 2000;
    var selectedMonth = 1;
    var selectedDay = 1;
    var maxDayOfMonth = 29;
    var minOfYear = 0;
    var maxOfYear = 0;
    DateTime curDate;
    ADateStructure curDateRelative;

    curDate = currentDate?? DateTime.now();
    curDateRelative = DateTools.convertToADateByCalendar(curDate)!;
    final toDay = DateTools.convertToADateByCalendar(DateTime.now())!;

    if(maxYear != null){
      final d = DateTime(maxYear!, 1, 1);
      maxOfYear = DateTools.convertToADateByCalendar(d)!.getYear();
    }
    else {
      maxOfYear = toDay.getYear() +1;
    }

    if(minYear != null){
      final d = DateTime(minYear!, 1, 1);
      minOfYear = DateTools.convertToADateByCalendar(d)!.getYear();
    }
    else {
      final cDate = DateTools.convertToADateByCalendar(curDate)!;
      minOfYear = MathHelper.minInt(toDay.getYear(), cDate.getYear());
    }

    selectedYear = curDateRelative.getYear();
    selectedMonth = curDateRelative.getMonth();
    selectedDay = curDateRelative.getDay();
    maxDayOfMonth = curDateRelative.getLastDayOfMonthFor(selectedYear, selectedMonth);
    //Color itemColor = iconColor?? AppThemes.currentTheme.textColor;

    void calcDate(){
      maxDayOfMonth = DateTools.calMaxMonthDay(selectedYear, selectedMonth);

      if(selectedDay > maxDayOfMonth){
        selectedDay = maxDayOfMonth;
      }

      curDate = DateTools.getDateByCalendar(selectedYear, selectedMonth, selectedDay)!;
    }

    return ColoredBox(
      color: AppThemes.currentTheme.backgroundColor,
      child: SelfRefresh(
        builder: (context, ctr) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      child: Text('${context.t('apply')}'),
                      onPressed: (){
                        ADateStructure date = DateTools.getADateByCalendar(selectedYear, selectedMonth, selectedDay)!;

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

              Scrollbar(
                thumbVisibility: true,
                child: ListView(
                  shrinkWrap: true,
                  children: [
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
                              ignoring: lockYear,
                              child: NumberPicker(
                                minValue: minOfYear,
                                maxValue: maxOfYear,
                                value: selectedYear,
                                axis: Axis.vertical,
                                haptics: true,
                                zeroPad: true,
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
                                  selectedYear = val;
                                  final max = DateTools.calMaxMonthDay(selectedYear, selectedMonth);

                                  if((maxDayOfMonth - max).abs() > 1){
                                    selectedDay = MathHelper.backwardStepInRing(selectedDay, 1, max, true);
                                  }

                                  calcDate();
                                  ctr.update();
                                },
                              ),
                            ),

                            ///--- month
                            IgnorePointer(
                              ignoring: lockMonth,
                              child: NumberPicker(
                                minValue: 1,
                                maxValue: 12,
                                value: selectedMonth,
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
                                  color: AppThemes.currentTheme.activeItemColor,//AppThemes.checkPrimaryByWB(AppThemes.currentTheme.primaryColor, AppThemes.currentTheme.differentColor),
                                ),
                                textMapper: (t){
                                  return t.toString().localeNum();
                                },
                                onChanged: (val){
                                  selectedMonth = val;
                                  final max = DateTools.calMaxMonthDay(selectedYear, selectedMonth);

                                  if((maxDayOfMonth - max).abs() > 1){
                                    selectedDay = MathHelper.backwardStepInRing(selectedDay, 1, max, true);
                                  }
                                  calcDate();

                                  ctr.update();
                                },
                              ),
                            ),

                            ///--- day
                            IgnorePointer(
                              ignoring: lockDay,
                              child: NumberPicker(
                                minValue: 1,
                                maxValue: maxDayOfMonth,
                                value: selectedDay,
                                axis: Axis.vertical,
                                haptics: true,
                                zeroPad: true,
                                infiniteLoop: true,
                                itemWidth: 50,
                                itemHeight: 40,textStyle: AppThemes.baseTextStyle().copyWith(
                                fontSize: AppSizes.fwFontSize(15),
                                fontWeight: FontWeight.bold,
                              ),
                                selectedTextStyle: TextStyle(
                                  fontSize: AppSizes.fwFontSize(16),
                                  fontWeight: FontWeight.bold,
                                  color: AppThemes.currentTheme.activeItemColor,//AppThemes.checkPrimaryByWB(AppThemes.currentTheme.primaryColor, AppThemes.currentTheme.differentColor),
                                ),
                                textMapper: (t){
                                  return t.toString().localeNum();
                                },
                                onChanged: (val){
                                  selectedDay = val;
                                  calcDate();

                                  ctr.update();
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              )
            ],
          );
        }
      ),
    );
  }
}
