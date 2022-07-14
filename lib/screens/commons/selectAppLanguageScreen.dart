import 'package:flutter/material.dart';

import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/api/managers/orientationManager.dart';

import '/managers/fontManager.dart';
import '/managers/settingsManager.dart';
import '/tools/app/appSizes.dart';
import '/tools/app/appThemes.dart';
import '/tools/centers/broadcastCenter.dart';
import '/tools/centers/localeCenter.dart';
import '/tools/centers/routeCenter.dart';

class SelectAppLanguageScreen extends StatefulWidget{
  static const screenName = '/select_language_page';

  SelectAppLanguageScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SelectAppLanguageScreenState();
  }
}
///===============================================================================================
class SelectAppLanguageScreenState extends State<SelectAppLanguageScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(!OrientationManager.isPortrait(context)) {
      OrientationManager.fixPortraitModeOnly();
    }

    return getScaffold();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget getScaffold(){
    final languageSecOffset = LocaleCenter.getAssetSupportedLanguages().length < 7?
    MathHelper.percent(AppSizes.getScreenHeight(context), 60)
        : MathHelper.percent(AppSizes.getScreenHeight(context), 32);

    //System.changeStatusBarNavBarColor(Colors.red);

    /// wrap by SafeArea for remove fullScreen
    return Scaffold(
      //extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[

          /// background
          Positioned.fill(
              child: Image.asset('assets/images/selectLanguage.jpg',
                //color: AppThemes.currentTheme.primaryColor,
                //colorBlendMode: BlendMode.color,
                fit: BoxFit.fill,
              )
          ),


          /// title
          Positioned(
            top: 50, left: 20, right: 20,
            child: Center(
                child: Card(color: AppThemes.currentTheme.primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 8, 12.0, 8),
                    child: AutoSizeText(LocaleCenter.appLocalize.translate('selectYourLanguage')!,
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                      maxLines: 1,
                    ),
                  ),
                )
            ),
          ),

          /// language list
          Positioned(
            top: languageSecOffset, left: 20, right: 20, bottom: 40,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: FadeInUp(
                from: languageSecOffset+300,
                child: GridView.count(
                  scrollDirection: Axis.vertical,
                  crossAxisCount: AppSizes.getScreenWidth(context) > 450? 5: 3,
                  reverse: false,
                  shrinkWrap: true,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  childAspectRatio: 3/2,
                  children: getLanguageList(),
                ),
              ),
            ),
          ),


          /// next Button
          Positioned(
            left: 20, right: 20, bottom: 12,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 60, vertical: 14)),
                ),
                onPressed: (){
                  RouteCenter.navigateRouteScreen(RoutesName.homePage);
                  //AppNavigator.pushNextPage(context, RootScreen(), name: RootScreen.screenName);
                },
                //shape: StadiumBorder(),
                child: Text(LocaleCenter.appLocalize.translate('next')!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> getLanguageList() {
    final res = <Widget>[];
    final languages = LocaleCenter.getAssetSupportedLanguages();

    for (var item in languages.entries) {
      final Widget w = GestureDetector(
        onTap: () async {
          final c = LocaleCenter.getAssetSupportedLocales()
              .firstWhere((loc) => loc.languageCode == item.key, orElse: () => const Locale('en', 'US'));
          SettingsManager.settingsModel.appLocale = c;
          await LocaleCenter.localeDelegate().load(c);
          await FontManager.fetchFontThemeData(c.languageCode);

          BroadcastCenter.reBuildMaterialBySetTheme();
          SettingsManager.saveSettings$Delay();
        },
        child: Card(
          color: (SettingsManager.settingsModel.appLocale.languageCode == item.key) ?
          AppThemes.themeData.colorScheme.secondary:
          Colors.white ,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  textDirection: TextDirection.ltr,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    /* Chip(
                          label: Text(item.value['name']!, style: AppThemes.currentTheme.baseTextStyle,),
                          avatar: CircleAvatar(child: Icon(Icons.translate),
                            backgroundColor: AppThemes.currentTheme.textColor,),
                        ),*/
                    //Icon(Icons.translate),
                    //SizedBox(width: 3,),
                    Text(item.value['name']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),),
                  ],
                ),
                const SizedBox(height: 6,),
                Text("(${item.value['locale_name']})"),
              ],
            ),
          ),
        ),
      );

      res.add(w);
    }

    return res;
  }
  ///=============================================================================================
}
