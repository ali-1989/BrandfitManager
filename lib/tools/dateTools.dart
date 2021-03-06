import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/localeHelper.dart';
import 'package:iris_tools/dateSection/ADateStructure.dart';
import 'package:iris_tools/dateSection/calendarTools.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import '/managers/settingsManager.dart';
import '/system/extensions.dart';

class DateTools {
  DateTools._();

  static List<String> dateFormats = [
    'YYYY/MM/DD', 'YY/MM/DD', 'YYYY/NN /DD',
    'YY/NN /DD', 'MM/DD/YYYY', 'NN /DD/YYYY',
    'MM/DD/YY', 'NN /DD/YY'];

  static List<CalendarType> calendarList = [
    CalendarType.gregorian(),
    CalendarType.byType(TypeOfCalendar.solarHijri)
  ];

  static String dateRelativeByAppFormat(DateTime? date, {bool isUtc = true, String? format}){
    if(date == null) {
      return '';
    }

    format ??= SettingsManager.settingsModel.dateFormat!;
    ADateStructure mDate;

    if(SettingsManager.settingsModel.calendarType.type == TypeOfCalendar.solarHijri){
      mDate = SolarHijriDate.from(date);
    }
    else {
      mDate = GregorianDate.from(date);
    }

    if(isUtc) {
      mDate.attachTimeZone('utc');
      mDate.moveUtcToLocal();
    }

    return LocaleHelper.overrideLtr(mDate.format(format, 'en').localeNum());
  }

  static String dateOnlyRelative$String(String date, {bool isUtc = true}){
    return dateRelativeByAppFormat(DateHelper.tsToSystemDate(date)!, isUtc: isUtc);
  }

  static String dateOnlyRelative(DateTime? date, {bool isUtc = true}){
    return dateRelativeByAppFormat(date, isUtc: isUtc);
  }

  static String dateAndHmRelative(DateTime? date, {bool isUtc = true}){
    if(date == null) {
      return '';
    }

    ADateStructure mDate;

    if(SettingsManager.settingsModel.calendarType.type == TypeOfCalendar.solarHijri){
      mDate = SolarHijriDate.from(date);
    }
    else {
      mDate = GregorianDate.from(date);
    }

    if(isUtc) {
      mDate.attachTimeZone('UTC');
      mDate.moveUtcToLocal();
    }

    return LocaleHelper.overrideLtr(mDate.format('${SettingsManager.settingsModel.dateFormat} HH:mm', 'en')
        .localeNum());
  }

  static String dateAndHmRelative$String(String date, {bool isUtc = true}){
    return dateAndHmRelative(DateHelper.tsToSystemDate(date), isUtc: isUtc);
  }

  static String dateYmOnlyRelative(DateTime? date, {bool isUtc = true}){
    if(date == null) {
      return '';
    }

    ADateStructure mDate;

    if(SettingsManager.settingsModel.calendarType.type == TypeOfCalendar.solarHijri){
      mDate = SolarHijriDate.from(date);
    }
    else {
      mDate = GregorianDate.from(date);
    }

    if(isUtc) {
      mDate.attachTimeZone('UTC');
      mDate.moveUtcToLocal();
    }

    return LocaleHelper.overrideLtr(mDate.format('YYYY/MM', 'en').localeNum());
  }

  static String dateHmOnlyRelative(DateTime? date, {bool isUtc = true}){
    if(date == null) {
      return '';
    }

    ADateStructure mDate;

    if(SettingsManager.settingsModel.calendarType.type == TypeOfCalendar.solarHijri){
      mDate = SolarHijriDate.from(date);
    }
    else {
      mDate = GregorianDate.from(date);
    }

    if(isUtc) {
      mDate.attachTimeZone('UTC');
      mDate.moveUtcToLocal();
    }

    return LocaleHelper.overrideLtr(mDate.format('HH:mm', 'en').localeNum());
  }

  static String dateHmOnlyRelative$String(String? date, {bool isUtc = true}){
    return dateHmOnlyRelative(DateHelper.tsToSystemDate(date), isUtc: isUtc);
  }
  ///---------------------------------------------------------------------------------------
  static Future saveAppCalendar(CalendarType calendarType, {BuildContext? context}) {
    SettingsManager.settingsModel.calendarType = calendarType;
    return SettingsManager.saveSettings(context: context);
  }

  static Future saveAppCalendarByName(String calName, {BuildContext? context}) {
    final cal = CalendarType.byName(calName);
    return saveAppCalendar(cal, context: context);
  }

  static DateTime? getDateByCalendar(int year, int month, int day, {int hour = 0, int minutes = 0, CalendarType? calendarType}){
    return getADateByCalendar(year, month, day, hour: hour, minutes: minutes, calendarType: calendarType)?.convertToSystemDate();
  }

  static ADateStructure? getADateByCalendar(int year, int month, int day, {int hour = 0, int minutes = 0, CalendarType? calendarType}){
    switch(calendarType?? SettingsManager.settingsModel.calendarType.type){
      case TypeOfCalendar.gregorian:
        return GregorianDate.hm(year, month, day, hour, minutes);
      case TypeOfCalendar.solarHijri:
        return SolarHijriDate.hm(year, month, day, hour, minutes);
    }

    return null;
  }

  static int calMaxMonthDay(int year, int month, {CalendarType? calendarType}){
    ADateStructure? ad;

    switch(calendarType?? SettingsManager.settingsModel.calendarType.type){
      case TypeOfCalendar.gregorian:
        ad = GregorianDate();
        break;
      case TypeOfCalendar.solarHijri:
        ad = SolarHijriDate();
        break;
    }

    return ad!.getLastDayOfMonthFor(year, month);
  }

  static ADateStructure? convertToADateByCalendar(DateTime date, {CalendarType? calendarType}){
    switch(calendarType?? SettingsManager.settingsModel.calendarType.type){
      case TypeOfCalendar.gregorian:
        return GregorianDate.from(date);
      case TypeOfCalendar.solarHijri:
        return SolarHijriDate.from(date);
    }

    return null;
  }

  static List<int> splitDateByCalendar(DateTime date, {CalendarType? calendarType}){
    final res = <int>[0,0,0];

    if((calendarType?? SettingsManager.settingsModel.calendarType.type) == TypeOfCalendar.gregorian) {
      res[0] = date.year;
      res[1] = date.month;
      res[2] = date.day;
    }

    final c = convertToADateByCalendar(date, calendarType: calendarType)!;
    res[0] = c.getYear();
    res[1] = c.getMonth();
    res[2] = c.getDay();

    return res;
  }
  ///---------------------------------------------------------------------------------------
  static int calMinBirthdateYear({CalendarType? calendarType}){
    switch(calendarType?? SettingsManager.settingsModel.calendarType.type){
      case TypeOfCalendar.gregorian:
        return DateTime.now().year-90;
      case TypeOfCalendar.solarHijri:
        return SolarHijriDate().getYear()-90;
      default:
        return DateTime.now().year-100;
    }
  }

  static int calMaxBirthdateYear({CalendarType? calendarType}){
    switch(calendarType?? SettingsManager.settingsModel.calendarType.type){
      case TypeOfCalendar.gregorian:
        return DateTime.now().year-7;
      case TypeOfCalendar.solarHijri:
        return SolarHijriDate().getYear()-7;
      default:
        return DateTime.now().year;
    }
  }
  ///---------------------------------------------------------------------------------------

}
