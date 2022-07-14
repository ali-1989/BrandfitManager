import 'package:flutter/material.dart';

import '/abstracts/stateBase.dart';
import '/managers/fontManager.dart';
import '/managers/settingsManager.dart';
import '/system/extensions.dart';
import '/tools/app/appSizes.dart';
import '/tools/centers/broadcastCenter.dart';
import '/tools/centers/localeCenter.dart';

class SelectLanguageScreen extends StatefulWidget {
  static const screenName = 'SelectLanguageScreen';
  
  SelectLanguageScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SelectLanguageScreenState();
  }
}
///========================================================================================================
class SelectLanguageScreenState extends StateBase<SelectLanguageScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    rotateToPortrait();

    return getScaffold();
  }

  @override
  void dispose() {
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

  getAppbar() {
    return AppBar(
      title: Text(context.tC('language')!),
    );
  }

  getBody() {

    EdgeInsets itemPad = const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0);
    Map<String, Map> languages = LocaleCenter.getAssetSupportedLanguages();

    return SizedBox(
      width: AppSizes.getScreenWidth(context),
      height: AppSizes.getScreenHeight(context),

      child: Directionality(
        textDirection: TextDirection.ltr,
        child: ListView.separated(
          itemCount: languages.length,
          itemBuilder: (BuildContext context, int index){
            MapEntry<String, Map> kv = languages.entries.elementAt(index);

            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async{
                showLoading(startDelay: null);

                if(SettingsManager.settingsModel.appLocale.languageCode != kv.key){
                  beforeChangeLanguage(kv.key);
                  await LocaleCenter.changeApplicationLanguage(kv.key);
                }
                /*else {
                  await AppManager.changeApplicationLanguage('en');
                }*/

                update();
                afterChangeLanguage(kv.key);
              },
              child: Padding(
                padding: itemPad,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(kv.value['name'] + ' (' + kv.value['locale_name'] + ')'),
                    Switch(
                      value: SettingsManager.settingsModel.appLocale.languageCode == kv.key,
                      onChanged: (s) async {

                        showLoading();
                        if(s){
                          beforeChangeLanguage(kv.key);
                          await LocaleCenter.changeApplicationLanguage(kv.key);
                        }
                        /*else {
                          await AppManager.changeApplicationLanguage('en');
                        }*/

                        update();
                        afterChangeLanguage(kv.key);
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
  void beforeChangeLanguage(String lang){
    FontManager.fetchFontThemeData(lang);
  }

  void afterChangeLanguage(String lang){
    BroadcastCenter.reBuildMaterialBySetTheme();
    hideLoading();
    updateParent();
    // dont call: FontManager.saveFontThemeData(lang);
  }
}
