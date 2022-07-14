import 'package:flutter/material.dart';

import 'package:iris_tools/models/dataModels/colorTheme.dart';

import '/abstracts/stateBase.dart';
import '/managers/settingsManager.dart';
import '/system/extensions.dart';
import '/tools/app/appSizes.dart';
import '/tools/app/appThemes.dart';
import '/tools/centers/broadcastCenter.dart';

class ThemeScreen extends StatefulWidget {
  static const screenName = 'ThemeScreen';

  ThemeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ThemeScreenState();
  }
}
///========================================================================================================
class ThemeScreenState extends StateBase<ThemeScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    rotateToPortrait();

    return getScaffold(this);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
///========================================================================================================
Widget getScaffold(ThemeScreenState state) {

  return WillPopScope(
    onWillPop: () => state.onWillBack(state),
    child: Scaffold(
      key: state.scaffoldKey,
      appBar: getAppbar(state),
      body: getBody(state),
    ),
  );
}
///========================================================================================================
getAppbar(ThemeScreenState state) {
  return AppBar(
    title: Text(state.context.tC('theme')!),
  );
}
///========================================================================================================
getBody(ThemeScreenState state) {

  EdgeInsets itemPad = const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0);
  Map<String, ColorTheme> themes = AppThemes.themeList;

  return SizedBox(
    width: AppSizes.getScreenWidth(state.context),
    height: AppSizes.getScreenHeight(state.context),

    child: Directionality(
      textDirection: TextDirection.ltr,
      child: ListView.separated(
        itemCount: themes.length,
        itemBuilder: (BuildContext context, int index){
          MapEntry<String, ColorTheme> kv = themes.entries.elementAt(index);
          String name = (kv.key == AppThemes.defaultTheme.themeName)? '${kv.key} (Default)': kv.key ;

          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: (){
                if(AppThemes.currentTheme.themeName != kv.key){
                  AppThemes.applyTheme(kv.value);
                  state.update();
                  BroadcastCenter.reBuildMaterial();
                  SettingsManager.saveSettings(context: state.context);
                  state.updateParent();
                }
                else {
                  AppThemes.applyTheme(AppThemes.defaultTheme);
                  state.update();
                  BroadcastCenter.reBuildMaterial();
                  SettingsManager.saveSettings(context: state.context);
                  state.updateParent();
                }
              },
            child: Padding(
              padding: itemPad,
              child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: kv.value.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6,),
                        Text(name)
                      ],
                    ),
                    Switch(
                      value: AppThemes.currentTheme.themeName == kv.key,
                      onChanged: (s){
                        if(s){
                          AppThemes.applyTheme(kv.value);
                          state.update();
                          BroadcastCenter.reBuildMaterial();
                          SettingsManager.saveSettings(context: state.context);
                          state.updateParent();
                        }
                      },
                    ),
                  ],
                ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index){
          return const Divider();
        },
      ),
    ),
  );
}
///========================================================================================================
