import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:iris_db/iris_db.dart';

import '/system/keys.dart';
import '/tools/app/appThemes.dart';
import '/tools/centers/dbCenter.dart';

class FontManager {
  FontManager._();

  static final List<Font> _list = [];
  static const _fontThemeDataKey = 'FontThemeData';
  static late Font _platformDefaultFont;
  static late final FontManager _instance;
  static late final TextTheme _rawTextTheme;
  static late final ThemeData _rawThemeData;
  static bool _calledInit = false;

  static _init(){
    if(!_calledInit){
      _createThemes();
      _prepareFontList();
      
      _calledInit = true;
      _instance = FontManager._();
    }
  }

  static FontManager get instance {
    _init();

    return _instance;
  }

  ThemeData get rawThemeData => _rawThemeData;
  TextTheme get rawTextTheme => _rawTextTheme;

  String getPlatformFontFamily(){
    BuildContext? context = WidgetsBinding.instance.focusManager.primaryFocus?.context;
    context ??= WidgetsBinding.instance.focusManager.rootScope.focusedChild?.context;
    context ??= WidgetsBinding.instance.focusManager.rootScope.context;

    String? def = getPlatformFontFamilyOf(context!);

    return def?? (kIsWeb? 'Segoe UI' : 'Roboto'); // monospace
  }

  String? getPlatformFontFamilyOf(BuildContext context){
    return getDefaultTextStyleOf(context).style.fontFamily;
  }

  DefaultTextStyle getDefaultTextStyleOf(BuildContext context){
    return DefaultTextStyle.of(context);
  }

  List<Font> fontListFor(String language, String usage, bool onlyDefault) {
    final result = <Font>[];
    
    for(var fon in _list){
      var hasLanguage = fon.defaultLanguage == language;
      var hasUsage = fon.defaultUsage == usage;

      if(!hasLanguage && fon.defaultLanguage == null) {
        hasLanguage = fon.languages.isEmpty || fon.languages.contains(language);
      }

      if(!hasUsage && !onlyDefault) { // && fon.defaultUsage == null
        hasUsage = fon.usages.isEmpty || fon.usages.contains(usage);
      }

      if(hasLanguage && hasUsage){
        result.add(Font.fromMap(fon.toMap()));
      }
    }

    return result;
  }

  // defaultFontFor(Settings.appLocale.languageCode, 'sub');
  Font defaultFontFor(String language, String usage) {
    for(var fon in _list){
      final hasLanguage = fon.defaultLanguage == language;
      final hasUsage = fon.defaultUsage == usage;

      if(hasLanguage && hasUsage) {
        return Font.fromMap(fon.toMap());
      }
    }

    return Font.fromMap(_platformDefaultFont.toMap());
  }

  Font getPlatformFont(){
    return Font.fromMap(_platformDefaultFont.toMap());
  }

  Font? getEnglishFont(){
    return defaultFontFor('en', 'base');
  }

  static Future<bool> saveFontThemeData(String lang) async {
    final con =  Conditions();
    con.add(Condition()..key = Keys.name..value = _fontThemeDataKey);

    var dbData = DbCenter.db.queryFirst(DbCenter.tbKv, con);

    dbData ??= {};

    final valueMap = dbData[Keys.value]?? {};
    final Map<String, dynamic> dataJs = valueMap[lang]?? {};
    valueMap[lang] = dataJs;

    dataJs['UserBaseFont'] = AppThemes.baseFont.toMap();
    dataJs['UserSubFont'] = AppThemes.subFont.toMap();
    dataJs['UserBoldFont'] = AppThemes.boldFont.toMap();
    dataJs['UserChatFont'] = AppThemes.chatFont.toMap();

    final val = <String, dynamic>{};
    val[Keys.name] = _fontThemeDataKey;
    val[Keys.value] = valueMap;

    final dynamic res = await DbCenter.db.insertOrReplace(DbCenter.tbKv, val, con);

    return res > 0;
  }

  static Future fetchFontThemeData(String lang) async {
    final con =  Conditions();
    con.add(Condition()..key = Keys.name..value = _fontThemeDataKey);

    var res = DbCenter.db.queryFirst(DbCenter.tbKv, con);

    if(res == null) {
      /// can set app default font
      //AppThemes.baseFont.size = 14;
      //AppThemes.baseFont.family = 'Nazanin';
    }

    res ??= {};
    final valueMap = res[Keys.value]?? {};
    final Map<String, dynamic> data = valueMap[lang]?? {};

    AppThemes.baseFont = Font.fromMap(data['UserBaseFont']);
    if(AppThemes.baseFont.family == null) {
      AppThemes.baseFont = FontManager.instance.defaultFontFor(lang, 'base');
    }

    AppThemes.subFont = Font.fromMap(data['UserSubFont']);
    if(AppThemes.subFont.family == null) {
      AppThemes.subFont = FontManager.instance.defaultFontFor(lang, 'sub');
    }

    AppThemes.boldFont = Font.fromMap(data['UserBoldFont']);
    if(AppThemes.boldFont.family == null) {
      AppThemes.boldFont = FontManager.instance.defaultFontFor(lang, 'bold');
    }

    AppThemes.chatFont = Font.fromMap(data['UserChatFont']);
    if(AppThemes.chatFont.family == null) {
      AppThemes.chatFont = FontManager.instance.defaultFontFor(lang, 'base');
      AppThemes.chatFont.size = Font.getRelativeFontSize() + 2;
    }

    return;
  }

  static void setToDefault(String lang){
    AppThemes.baseFont = FontManager.instance.defaultFontFor(lang, 'base');
    AppThemes.subFont = FontManager.instance.defaultFontFor(lang, 'sub');
    AppThemes.boldFont = FontManager.instance.defaultFontFor(lang, 'bold');
    AppThemes.chatFont = FontManager.instance.defaultFontFor(lang, 'base');

    AppThemes.chatFont.size = Font.getRelativeFontSize() + 2;

    //AppThemes.applyTheme(AppThemes.currentTheme);
  }

  static void _prepareFontList() {
    // key: show name   value: font name in [pubspec.yaml]

    if(_list.isEmpty) {
      final atlanta = Font.bySize()
        ..family = 'Atlanta'
        ..fileName = 'Atlanta'
        ..defaultLanguage = 'en'
        ..defaultUsage = 'base'
        ..usages = ['sub'];

      final simpleLife = Font.bySize()
        ..family = 'Simple Life'
        ..fileName = 'SimpleLife'
        ..defaultLanguage = 'en'
        ..defaultUsage = 'sub';

      final openSans = Font.bySize()
        ..family = 'OpenSans'
        ..fileName = 'OpenSans'
        ..defaultLanguage = 'en'
        ..usages = ['bold', 'base'];
      //------------- fa -------------------------------------------------
      final faSahel = Font.bySize()
        ..family = 'Sahel'
        ..fileName = 'Sahel'
        ..defaultLanguage = 'fa'
        ..defaultUsage = 'base'
        ..usages = ['sub']
        ..height = 1.4;

      final faEstedad = Font.bySize()
        ..family = 'Estedad'
        ..fileName = 'Estedad'
        ..defaultLanguage = 'fa'
        ..defaultUsage = 'bold'
        ..usages = ['base'];

      final faDiplomat = Font.bySize()
        ..family = 'Diplomat'
        ..fileName = 'Diplomat'
        ..defaultLanguage = 'fa'
        ..defaultUsage = 'sub';

      final faNazanin = Font.bySize()
        ..family = 'Nazanin'
        ..fileName = 'Nazanin'
        ..defaultLanguage = 'fa'
        ..usages = ['sub', 'base'];

      final faSans = Font.bySize()
        ..family = 'Sans'
        ..fileName = 'Sans'
        ..defaultLanguage = 'fa'
        ..usages = ['sub', 'base'];

      final faSahelBold = Font.bySize()
        ..family = 'SahelBold'
        ..fileName = 'SahelBold'
        ..defaultLanguage = 'fa'
        ..defaultUsage = 'bold'
        ..usages = ['base'];


      _list.add(atlanta);
      _list.add(simpleLife);
      _list.add(openSans);
      _list.add(faSahel);
      _list.add(faEstedad);
      _list.add(faDiplomat);
      _list.add(faSahelBold);
      _list.add(faNazanin);
      _list.add(faSans);

      //can monospace,Roboto

      var rawDef = _getDefaultFontFamily();

      try {
        final findIdx = _list.indexWhere((font) => font.family == rawDef);

        if (findIdx < 0) { // && rawDef != def
          _platformDefaultFont = Font.bySize()
            ..family = rawDef
            ..fileName = rawDef;

          _list.add(_platformDefaultFont);
        }
        else {
          _platformDefaultFont = _list[findIdx];
        }
      }
      catch (e){}
    }
  }

  static void _createThemes(){
    double fs = Font.getRelativeFontSize();
    Color c1 = Colors.teal;
    Color c2 = Colors.blue;
    ThemeData temp = ThemeData();

    _rawTextTheme = TextTheme(
      /// Drawer {textColor}  [emphasizing text]
      bodyText1: temp.textTheme.bodyText1!.copyWith(fontSize: fs, color: c1, decorationColor: c2),
      ///default for Material
      bodyText2: temp.textTheme.bodyText2!.copyWith(fontSize: fs, color: c1, decorationColor: c2),
      overline: temp.textTheme.overline!.copyWith(fontSize: fs, color: c1, decorationColor: c2),
      ///   [Extremely large]
      headline1: temp.textTheme.headline1!.copyWith(fontSize: fs, color: c1, decorationColor: c2),
      ///   [Very, very large]
      headline2: temp.textTheme.headline2!.copyWith(fontSize: fs, color: c1, decorationColor: c2),
      headline3: temp.textTheme.headline3!.copyWith(fontSize: fs, color: c1, decorationColor: c2),
      headline4: temp.textTheme.headline4!.copyWith(fontSize: fs, color: c1, decorationColor: c2),
      /// large text in dialogs (month and year ...)
      headline5: temp.textTheme.headline5!.copyWith(fontSize: fs, color: c1, decorationColor: c2),
      ///{appBar and dialogs} Title   (old = subtitle & subhead)
      headline6: temp.textTheme.headline6!.copyWith(fontSize: fs, color: c1, decorationColor: c2),
      /// textField, list
      subtitle1: temp.textTheme.subtitle1!.copyWith(fontSize: fs, color: c1, decorationColor: c2),
      ///       [medium emphasis]
      subtitle2: temp.textTheme.subtitle2!.copyWith(fontSize: fs, color: c1, decorationColor: c2),
      /// Buttons
      button: temp.textTheme.button!.copyWith(fontSize: fs, color: c1, decorationColor: c2),
      /// images caption
      caption: temp.textTheme.caption!.copyWith(fontSize: fs, color: c1, decorationColor: c2),
    );

    _rawThemeData = ThemeData.from(colorScheme: temp.colorScheme, textTheme: _rawTextTheme);
  }

  static String _getDefaultFontFamily(){
    var ff = _rawTextTheme.bodyText1?.fontFamily;
    return ff?? _rawTextTheme.bodyText2?.fontFamily?? (kIsWeb? 'Segoe UI' : 'Roboto');
  }
}
///=====================================================================================================
class Font {
  String? family;
  String? fileName;
  double height = 1;
  double? size;
  String? defaultUsage;
  String? defaultLanguage;
  List<String> languages = [];
  List<String> usages = [];

  Font();

  Font.bySize(){
    size = getRelativeFontSize();
  }

  Font.fromMap(Map? map){
    if(map == null){
      return;
    }

    family = map['family'];
    fileName = map['file_name'];
    size = map['size']?? 10;
    height = map['height']?? 1;
    defaultUsage = map['default_usage'];
    defaultLanguage = map['default_language'];
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};

    map['family'] = family;
    map['file_name'] = fileName;
    map['size'] = size;
    map['height'] = height;
    map['default_usage'] = defaultUsage;
    map['default_language'] = defaultLanguage;

    return map;
  }

  static double getRelativeFontSize() {
    var realPixelWidth = ui.window.physicalSize.width;
    var realPixelHeight = ui.window.physicalSize.height;
    var pixelRatio = ui.window.devicePixelRatio;
    bool isLandscape = realPixelWidth > realPixelHeight;

    if(kIsWeb) {
      return 12.2;
    }
    else {
      var appHeight = (isLandscape ? realPixelWidth : realPixelHeight) / pixelRatio;
      return (appHeight / 100 /* ~6.3*/) + 6;
    }
  }
}
