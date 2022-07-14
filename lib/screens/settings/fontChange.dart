import 'package:flutter/material.dart';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/widgets/maxWidth.dart';
import 'package:iris_tools/widgets/slider/buSlider.dart';
import 'package:iris_tools/modules/stateManagers/refresh.dart';

import '/abstracts/stateBase.dart';
import '/managers/fontManager.dart';
import '/managers/settingsManager.dart';
import '/screens/settings/settingsScreen.dart';
import '/system/extensions.dart';
import '/tools/app/appNavigator.dart';
import '/tools/app/appSizes.dart';
import '/tools/app/appThemes.dart';
import '/tools/centers/broadcastCenter.dart';
import '/tools/centers/localeCenter.dart';
import '/tools/centers/snackCenter.dart';

class FontScreen extends StatefulWidget {
  static const screenName = 'FontScreen';

  FontScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FontScreenState();
  }
}
///========================================================================================================
class FontScreenState extends StateBase<FontScreen> {
  RefreshController fontSizeRefresher = RefreshController();
  RefreshController fontFamilyRefresher = RefreshController();
  late SettingsScreenState parentState;
  double baseFontSize = AppThemes.currentTheme.baseTextStyle.fontSize!;
  //double subFontSize = AppThemes.currentTheme.subTextStyle.fontSize!;
  //double boldFontSize = AppThemes.currentTheme.boldTextStyle.fontSize!;
  double chatFontSize = AppThemes.chatTextStyle().fontSize!;
  String baseFontFamily = AppThemes.currentTheme.baseTextStyle.fontFamily!;
  String subFontFamily = AppThemes.currentTheme.subTextStyle.fontFamily!;
  String boldFontFamily = AppThemes.currentTheme.boldTextStyle.fontFamily!;
  String chatFontFamily = AppThemes.chatTextStyle().fontFamily!;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    rotateToPortrait();

    parentState = AppNavigator.getArgumentsOf(context) as SettingsScreenState;
    return getScaffold();
  }

  @override
  void dispose() {
    fontSizeRefresher.dispose();
    fontFamilyRefresher.dispose();

    super.dispose();
  }

  Widget getScaffold() {
    return WillPopScope(
      onWillPop: () => onWillBack(this),
      child: Scaffold(
        key: scaffoldKey,
        appBar: getAppbar(),
        body: getBody(),
      ),
    );
  }

  PreferredSizeWidget getAppbar() {
    return AppBar(
      title: Text(context.tC('font')!),
    );
  }

  Widget getBody() {
    return SizedBox(
      width: AppSizes.getScreenWidth(context),
      height: AppSizes.getScreenHeight(context),

      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Column(
              children: [
                Text(context.tC('descriptionPressApply')!, textScaleFactor: 1.2,).bold(),
                const SizedBox(height: 18,),
                MaxWidth(
                  maxWidth: 350,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 22, vertical: 14))
                          ),
                          child: Text(LocaleCenter.appLocalize.translate('apply')!),
                          onPressed: (){
                            applyFont();
                          },
                        ),

                        const SizedBox(height: 10,),

                        ElevatedButton(
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 22, vertical: 14))
                          ),
                          child: Text(LocaleCenter.appLocalize.translate('defaultSettings')!),
                          onPressed: (){
                            setDefault();
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 5,),
              ],
            ),
          ),

          Expanded(
            child: ListView(
                children: [
                  /// --------------------------------------------- TextSize
                  parentState.genHeader(tInMap('settingsScreen', 'fontSize')!),

                  Refresh(
                    controller: fontSizeRefresher,
                    builder: (BuildContext context, RefreshController controller) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// ------------------- baseTextSize
                          ConstrainedBox(
                            constraints: BoxConstraints.loose(const Size(800, double.infinity)),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                              child:Card(
                                color: AppThemes.currentTheme.accentColor,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                                      child: Row(
                                          children: <Widget>[
                                            const Icon(CommunityMaterialIcons.gamepad, size: 18,).whiteOrAppBarItemOnPrimary(),
                                            const SizedBox(width: 5,),
                                            Text(tInMap('settingsScreen', 'baseFont')!, textScaleFactor: 1.2 ,).whiteOrAppBarItemOnPrimary(),]
                                      ),
                                    ),

                                    const SizedBox(height: 5,),

                                    Card(
                                        color: ColorHelper.changeHue(AppThemes.currentTheme.accentColor),
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          child: Text(tInMap('settingsScreen', 'sampleText_fontSize')!,
                                            style: TextStyle(fontSize: baseFontSize),),
                                        )
                                    ),

                                    const SizedBox(height: 5,),

                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      child: Directionality(
                                        textDirection: TextDirection.ltr,
                                        child: BuSlider(
                                          min: 10.0,
                                          max: 18.0,
                                          fullWidth: true,
                                          value: baseFontSize,
                                          //activeColor: AppThemes.themeData.sliderTheme.activeTrackColor,
                                          //inactiveColor: AppThemes.themeData.sliderTheme.inactiveTrackColor,
                                          onChanged: (dynamic val){
                                            baseFontSize = val;
                                            fontSizeRefresher.update();
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          /// ------------------- chatFontSize
                          ConstrainedBox(
                            constraints: BoxConstraints.loose(const Size(800, double.infinity)),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                              child:Card(
                                color: AppThemes.currentTheme.accentColor,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                                      child: Row(
                                          children: <Widget>[
                                            const Icon(CommunityMaterialIcons.gamepad, size: 18,).whiteOrAppBarItemOnPrimary(),
                                            const SizedBox(width: 5,),
                                            Text(tInMap('settingsScreen', 'chatFont')!, textScaleFactor: 1.2 ,).whiteOrAppBarItemOnPrimary(),]
                                      ),
                                    ),

                                    const SizedBox(height: 5,),

                                    Card(
                                        color: ColorHelper.changeHue(AppThemes.currentTheme.accentColor),
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          child: Text(tInMap('settingsScreen', 'sampleText_fontSize')!,
                                            style: TextStyle(fontSize: chatFontSize),),
                                        )
                                    ),

                                    const SizedBox(height: 5,),

                                    Container(
                                        padding: const EdgeInsets.all(5),
                                        child: Directionality(
                                          textDirection: TextDirection.ltr,
                                          child: BuSlider(
                                              min: 10,
                                              max: 18,
                                              value: chatFontSize,
                                              fullWidth : true,
                                              //divisions: 18,
                                              //activeColor: AppThemes.themeData.sliderTheme.activeTrackColor,
                                              //inactiveColor: AppThemes.themeData.sliderTheme.inactiveTrackColor,
                                              onChanged: (dynamic val){
                                                chatFontSize = val;
                                                fontSizeRefresher.update();
                                              }
                                          ),
                                        )
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  /// --------------------------------------------- FontFamily
                  parentState.genHeader(tC('font')!),

                  Refresh(
                      controller: fontFamilyRefresher,
                      builder: (BuildContext context, RefreshController controller) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// ------------------------------ baseFont
                            ConstrainedBox(
                              constraints: BoxConstraints.loose(const Size(800, double.infinity)),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                                child:Card(
                                  color: AppThemes.currentTheme.accentColor,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,

                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                                        child: Row(
                                            children: <Widget>[
                                              const Icon(CommunityMaterialIcons.gamepad, size: 18,).whiteOrAppBarItemOnPrimary(),
                                              const SizedBox(width: 5,),
                                              Text(tInMap('settingsScreen', 'baseFont')!, textScaleFactor: 1.2 ,).whiteOrAppBarItemOnPrimary(),
                                            ]
                                        ),
                                      ),

                                      const SizedBox(height: 5,),

                                      Card(
                                          color: ColorHelper.changeHue(AppThemes.currentTheme.accentColor),
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            child: Text(tInMap('settingsScreen', 'sampleText_fontFamily')!,
                                              style: TextStyle(fontFamily: baseFontFamily),),
                                          )
                                      ),

                                      const SizedBox(height: 5,),

                                      Column(
                                        children: getBaseFontItems(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            /// ------------------------------ chatFont
                            ConstrainedBox(
                              constraints: BoxConstraints.loose(const Size(800, double.infinity)),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                child:Card(
                                  color: AppThemes.currentTheme.accentColor,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,

                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                                        child: Row(
                                            children: <Widget>[
                                              const Icon(CommunityMaterialIcons.gamepad, size: 18,).whiteOrAppBarItemOnPrimary(),
                                              const SizedBox(width: 5,),
                                              Text(tInMap('settingsScreen', 'chatFont')!, textScaleFactor: 1.2 ,).whiteOrAppBarItemOnPrimary(),
                                            ]
                                        ),
                                      ),

                                      const SizedBox(height: 5,),

                                      Card(
                                          color: ColorHelper.changeHue(AppThemes.currentTheme.accentColor),
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            child: Text(tInMap('settingsScreen', 'sampleText_fontFamily')!,
                                              style: TextStyle(fontFamily: chatFontFamily, fontSize: chatFontSize),),
                                          )
                                      ),

                                      const SizedBox(height: 5,),

                                      Column(
                                        children: getChatFontItems(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                  ),
                ]
            ),
          ),
        ],
      ),
    );
  }
  ///========================================================================================================
  List<Widget> getBaseFontItems(){
    final res = <Widget>[];
    final fonts = FontManager.instance.fontListFor(SettingsManager.settingsModel.appLocale.languageCode, 'base', false);

    for(var i in fonts){
      final r = Row(
        children: [
          Radio(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            groupValue: baseFontFamily,
            value: i.family!,
            onChanged: (val) {
              baseFontFamily = val! as String;
              fontFamilyRefresher.update();
            },
          ).intelliWhite(),

          Text(i.family!).whiteOrAppBarItemOnPrimary(),
        ],
      );

      res.add(r);
    }

    return res;
  }

  List<Widget> getSubFontItems(){
    final res = <Widget>[];
    final fonts = FontManager.instance.fontListFor(SettingsManager.settingsModel.appLocale.languageCode, 'sub', true);

    for(var i in fonts){
      final r = Row(
        children: [
          Radio(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            groupValue: baseFontFamily,
            value: i.family!,
            onChanged: (val) {
              baseFontFamily = val! as String;
              fontFamilyRefresher.update();
            },
          ).intelliWhite(),

          Text(i.family!).whiteOrAppBarItemOnPrimary(),
        ],
      );

      res.add(r);
    }

    return res;
  }

  List<Widget> getChatFontItems(){
    final res = <Widget>[];
    final fonts = FontManager.instance.fontListFor(SettingsManager.settingsModel.appLocale.languageCode, 'base', false);

    for(var i in fonts){
      final r = Row(
        children: [
          Radio(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            groupValue: chatFontFamily,
            value: i.family!,
            onChanged: (val) {
              chatFontFamily = val! as String;
              fontFamilyRefresher.update();
            },
          ).intelliWhite(),

          Text(i.family!).whiteOrAppBarItemOnPrimary(),
        ],
      );

      res.add(r);
    }

    return res;
  }

  void applyFont(){
    AppThemes.baseFont.size = baseFontSize;
    AppThemes.subFont.size = baseFontSize;
    AppThemes.boldFont.size = baseFontSize;
    AppThemes.chatFont.size = chatFontSize;

    AppThemes.baseFont.family = baseFontFamily;
    AppThemes.subFont.family = subFontFamily;
    AppThemes.boldFont.family = boldFontFamily;
    AppThemes.chatFont.family = chatFontFamily;

    AppThemes.applyTheme(AppThemes.currentTheme);
    FontManager.saveFontThemeData(SettingsManager.settingsModel.appLocale.languageCode);
    update();
    BroadcastCenter.reBuildMaterial();
    SnackCenter.showSnack$successOperation(context);
    updateParent();
  }

  void setDefault(){
    FontManager.setToDefault(SettingsManager.settingsModel.appLocale.languageCode);

    baseFontSize = AppThemes.baseFont.size!;
    chatFontSize = AppThemes.chatFont.size!;

    baseFontFamily = AppThemes.baseFont.family!;
    subFontFamily = AppThemes.subFont.family!;
    boldFontFamily = AppThemes.boldFont.family!;
    chatFontFamily = AppThemes.chatFont.family!;

    AppThemes.applyTheme(AppThemes.currentTheme);
    update();
    BroadcastCenter.reBuildMaterial();
    FontManager.saveFontThemeData(SettingsManager.settingsModel.appLocale.languageCode);
    updateParent();
  }
}
