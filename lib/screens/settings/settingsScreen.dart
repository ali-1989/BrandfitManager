import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/selfRefresh.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';

import '/abstracts/stateBase.dart';
import '/managers/settingsManager.dart';
import '/screens/example.dart';
import '/screens/settings/settingsScreenCtr.dart';
import '/system/extensions.dart';
import '/tools/app/appSizes.dart';
import '/tools/app/appThemes.dart';
import '/tools/languageTools.dart';

class SettingsScreen extends StatefulWidget {
  static const screenName = 'SettingsScreen';

  SettingsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SettingsScreenState();
  }
}
///========================================================================================================
class SettingsScreenState extends StateBase<SettingsScreen> {
  StateXController stateController = StateXController();
  SettingsScreenCtr controller = SettingsScreenCtr();
  
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
      child: SizedBox(
        width: AppSizes.getScreenWidth(context),
        height: AppSizes.getScreenHeight(context),
        child: Scaffold(
          key: scaffoldKey,
          appBar: getAppbar(),
          body: SafeArea(
            child: getBody(),
          )
        ),
      ),
    );
  }

  PreferredSizeWidget getAppbar() {
    return AppBar(
      title: GestureDetector(
        onLongPress: (){
          Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx){return ExampleScreen();})
          );
        },
          child: Text('${tC('settings')}')
      ),
      /*actions: <Widget>[
        (ModalRoute.of(context)?.canPop ?? false)?
    IconButton(
      onPressed: () => onBackButton(state),
      icon: (System.isAndroid()) ?
      Icon(Icons.arrow_back, textDirection: AppThemes.getOppositeDirection(),) :
      Icon(Icons.arrow_back_ios, textDirection: AppThemes.getOppositeDirection(),),
    )
        : SizedBox(),
      ],*/
    );
  }

  Widget getBody() {
    return StateX(
      isMain: true,
      builder: (context, ctr, data) {
        return ListView(
          children: [
            ...commonSection(),
            ...colorFontSection(),
            ...notificationSection(),
            ...mediaSection(),
            ...dateSection(),
          ],
        );
      }
    );
  }
  ///========================================================================================================
  List<Widget> commonSection(){
    return [
      genHeader(tInMap('settingsScreen', 'commonSettings')!),
      GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          controller.gotoSelectLanguagePage();
        },
        child: Padding(
          padding: itemPadding(),
          child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tC('language')!).infoColor(),

                Row(
                  children: [
                    Text(LanguageTools.getLanguageLocaleName()),
                    const SizedBox(width: 5,),
                    getArrow(),
                  ],
                ),
              ]
          ),
        ),
      ),

      itemDivider(),

      SelfRefresh(
          builder: (ctx, ctr) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                SettingsManager.settingsModel.confirmOnExit = !SettingsManager.settingsModel.confirmOnExit;
                SettingsManager.saveSettings();
                ctr.update();
                SettingsManager.notify(context: ctx);
              },
              child: Padding(
                padding: checkPadding(),
                child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.exit_to_app, size: 18,),
                          const SizedBox(width: 5,),
                          Text(tInMap('settingsScreen', 'descriptionConfirmOnExit')!),
                        ],
                      ),
                      Switch(
                        value: SettingsManager.settingsModel.confirmOnExit,
                        onChanged: (v) {
                          SettingsManager.settingsModel.confirmOnExit = !SettingsManager.settingsModel.confirmOnExit;
                          SettingsManager.saveSettings();
                          ctr.update();
                          SettingsManager.notify(context: ctx);
                        },
                      ),
                    ]
                ),
              ),
            );
          }
      ),
    ];
  }

  List<Widget> colorFontSection(){
    return [
      genHeader(tInMap('settingsScreen', 'fontSettings')!),
      /*GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          controller.gotoThemePage();
        },
        child: Padding(
          padding: itemPadding(),
          child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tInMap('settingsScreen', 'theme')!).infoColor(),

                Row(
                  children: [
                    Text(AppThemes.currentTheme.themeName),
                    SizedBox(width: 5,),
                    getArrow(),
                  ],
                ),
              ]
          ),
        ),
      ),*/

      //itemDivider(),

      GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          controller.gotoFontPage();
        },
        child: Padding(
          padding: itemPadding(),
          child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tInMap('settingsScreen', 'font')!).infoColor(),

                Row(
                  children: [
                    Text(AppThemes.currentTheme.baseTextStyle.fontFamily!),
                    const SizedBox(width: 5,),
                    getArrow(),
                  ],
                ),
              ]
          ),
        ),
      ),
    ];
  }

  List<Widget> notificationSection(){
    return [
      genHeader(tInMap('settingsScreen', 'notifications')!),
      SelfRefresh(
          builder: (ctx, ctr) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                SettingsManager.settingsModel.chatNotification = !SettingsManager.settingsModel.chatNotification;
                SettingsManager.saveSettings();
                ctr.update();
                SettingsManager.notify(context: ctx);
              },
              child: Padding(
                padding: checkPadding(),
                child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.message, size: 18,),
                          const SizedBox(width: 5,),
                          Text(tInMap('settingsScreen', 'chats')!),
                        ],
                      ),
                      Switch(
                        value: SettingsManager.settingsModel.chatNotification,
                        onChanged: (v) {
                          SettingsManager.settingsModel.chatNotification = !SettingsManager.settingsModel.chatNotification;

                          SettingsManager.saveSettings();
                          ctr.update();
                          SettingsManager.notify(context: ctx);
                        },
                      ),
                    ]
                ),
              ),
            );
          }
      ),
    ];
  }

  List<Widget> mediaSection(){
    return [
      genHeader(tInMap('settingsScreen', 'media')!),
      SelfRefresh(
          builder: (ctx, ctr) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                SettingsManager.settingsModel.autoDownloadImages = !SettingsManager.settingsModel.autoDownloadImages;
                SettingsManager.saveSettings();
                ctr.update();
                SettingsManager.notify(context: ctx);
              },
              child: Padding(
                padding: checkPadding(),
                child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.image, size: 18,),
                          const SizedBox(width: 5,),
                          Text(tInMap('settingsScreen', 'descriptionAutoDownloadImage')!),
                        ],
                      ),
                      Switch(
                        value: SettingsManager.settingsModel.autoDownloadImages,
                        onChanged: (v) {
                          SettingsManager.settingsModel.autoDownloadImages = !SettingsManager.settingsModel.autoDownloadImages;
                          SettingsManager.saveSettings();
                          ctr.update();
                          SettingsManager.notify(context: ctx);
                        },
                      ),
                    ]
                ),
              ),
            );
          }
      ),

      SelfRefresh(
          builder: (ctx, ctr) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                SettingsManager.settingsModel.autoDownloadVideos = !SettingsManager.settingsModel.autoDownloadVideos;
                SettingsManager.saveSettings();
                ctr.update();
                SettingsManager.notify(context: ctx);
              },
              child: Padding(
                padding: checkPadding(),
                child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.video_library, size: 18,),
                          const SizedBox(width: 5,),
                          Text(tInMap('settingsScreen', 'descriptionAutoDownloadVideo')!),
                        ],
                      ),
                      Switch(
                        value: SettingsManager.settingsModel.autoDownloadVideos,
                        onChanged: (v) {
                          SettingsManager.settingsModel.autoDownloadVideos = !SettingsManager.settingsModel.autoDownloadVideos;
                          SettingsManager.saveSettings();
                          ctr.update();
                          SettingsManager.notify(context: ctx);
                        },
                      ),
                    ]
                ),
              ),
            );
          }
      ),
    ];
  }

  List<Widget> dateSection(){
    return [
      genHeader(tInMap('settingsScreen', 'date&calendarSettings')!),
      GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          controller.gotoDateCalendarPage();
        },
        child: Padding(
          padding: itemPadding(),
          child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tInMap('settingsScreen', 'calendar')!).infoColor(),

                Row(
                  children: [
                    Text(tInMap('calendarOptions', SettingsManager.settingsModel.calendarType.name)!),
                    const SizedBox(width: 5,),
                    getArrow(),
                  ],
                ),
              ]
          ),
        ),
      ),
    ];
  }

  Widget getArrow() {
    return RotatedBox(
      quarterTurns: AppThemes.isRtlDirection() ? 0 : 2,
      child: const Icon(Icons.arrow_back_ios_outlined, size: 10, textDirection: TextDirection.ltr,),
    );
  }

  Widget itemDivider() {
    return const Divider(height: 1.0,);
  }

  EdgeInsets itemPadding() {
    return const EdgeInsets.symmetric(horizontal: 26.0, vertical: 16.0);
  }

  EdgeInsets checkPadding() {
    return const EdgeInsets.symmetric(horizontal: 26.0, vertical: 2.0);
  }

  Widget genHeader(String text){
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppThemes.currentTheme.headerBackColor,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Text(text,
            textScaleFactor: 1.1,
            style: TextStyle(
                color: AppThemes.currentTheme.headerTextColor,
                fontWeight: FontWeight.w400)
        ),
      ),
    );
  }
}
