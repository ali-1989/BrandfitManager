import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/databaseHelper.dart';
import 'package:iris_tools/api/logger/reporter.dart';
import 'package:iris_tools/api/manageCallAction.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';
import 'package:iris_tools/net/trustSsl.dart';
import 'package:workmanager/workmanager.dart';

import '/constants.dart';
import '/managers/settingsManager.dart';
import '/managers/versionManager.dart';
import '/screens/routeScreen.dart';
import '/system/cronTask.dart';
import '/system/initialize.dart';
import '/system/keys.dart';
import '/system/session.dart';
import '/tools/app/appManager.dart';
import '/tools/app/appSizes.dart';
import '/tools/app/appThemes.dart';
import '/tools/centers/broadcastCenter.dart';
import '/tools/centers/dbCenter.dart';
import '/tools/centers/directoriesCenter.dart';
import '/tools/centers/localeCenter.dart';
import '/tools/centers/routeCenter.dart';
import '/views/toastView.dart';

bool _isInit = false;
bool _loadSettings = false;

///===== call on any hot restart ================================================================
void main() async {

  Future<void> flutterBindingInitialize() async {
    AppManager.widgetsBinding = WidgetsFlutterBinding?.ensureInitialized();
    SchedulerBinding.instance.ensureVisualUpdate();
    SchedulerBinding.instance.window.scheduleFrame();
  }

  if(kIsWeb){
    flutterBindingInitialize();
  }
  else {
    Timer(const Duration(milliseconds: 100), flutterBindingInitialize);
  }

  // runZoned(), LocalizedApp()
  // o.fixPortraitModeOnly(runApp, getApp());
  runApp(const MyApp());
}
///===== call on any hot reload ================================================================
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RouteCenter.materialContext = context;
    init();

    /// - ReBuild First Widgets tree, not call on Navigator pages
    return StreamBuilder<bool>(
        initialData: false,
        stream: BroadcastCenter.materialUpdaterStream.stream,
        builder: (context, snapshot) {

          if (!_loadSettings) {
            return Center(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                  ),
                )
            );
          }
          else {
            if (kIsWeb) {
              return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 400,
                      minHeight: 400,
                      maxWidth: 700,
                      maxHeight: double.infinity,
                    ),
                    child: getMaterialApp()
                  )
              );
          }
          else {
            return getMaterialApp();
          }
        }
    });
  }

  void init() async {
    if(_isInit){
      return;
    }

    _isInit = true;

    await Initial.waitForImportant();
    await prepareReporter();
    await prepareDatabase();

    AppSizes.initial();
    AppThemes.initial();
    _loadSettings = SettingsManager.loadSettings();

    if (_loadSettings) {
      await checkNewVersion();
      await Session.fetchLoginUsers();
      TrustSsl.acceptBadCertificate();

      Workmanager().initialize(
        callbackWorkManager,
        isInDebugMode: false,
      );

      BroadcastCenter.reBuildMaterialBySetTheme();
    }
  }

  // MaterialApp/ CupertinoApp/ WidgetsApp
  Widget getMaterialApp() {
    final material = MaterialApp(
      key: BroadcastCenter.materialAppKey,
      debugShowCheckedModeBanner: false,
      navigatorObservers: [ClearFocusOnPush()],
      //scrollBehavior: MyCustomScrollBehavior(),
      //onGenerateTitle: (ctx) => ,
      title: Constants.appTitle,
      theme: AppThemes.themeData, //or: ThemeData.light(),
      //darkTheme: ThemeData.dark(),
      themeMode: AppThemes.currentThemeMode,
      scaffoldMessengerKey: BroadcastCenter.rootScaffoldMessengerKey,
      navigatorKey: BroadcastCenter.rootNavigatorStateKey,
      localizationsDelegates: LocaleCenter.getLocaleDelegates(),
      supportedLocales: LocaleCenter.getAssetSupportedLocales(),
      locale: SettingsManager.settingsModel.appLocale,
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        return SettingsManager.settingsModel.appLocale;

        /*if(deviceLocale != null) {
        for (var locale in supportedLocales) {
          if (locale.languageCode == deviceLocale.languageCode && locale.countryCode == deviceLocale.countryCode) {
            return deviceLocale;
          }
        }
      }

      return supportedLocales.first;*/
      },
      home: RouteScreen(),
      builder: (context, home) {
        RouteCenter.materialContext = context;
        Initial.oncePreparing(context);
        final mediaQueryData = MediaQuery.of(context);

        return MediaQuery(
          data: mediaQueryData.copyWith(textScaleFactor: 1.0),

          /// detect orientation change and rotate screen
          child: OrientationBuilder(
              builder: (context, orientation) {
                //LocaleCenter.detectLocaleDirection(Localizations.localeOf(context));
                LocaleCenter.detectLocaleDirection(SettingsManager.settingsModel.appLocale);
                testCodes(context);

                return home!;
              }),
        );
      },
    );

    return Material(
      child: Directionality(
        textDirection: AppThemes.textDirection,
        child: Stack(
          fit: StackFit.expand,
          children: [
            material,

            // StateXController.globalUpdate(Keys.toast, stateData: 'toast');
            StateX(
                id: Keys.toast,
                builder: (ctx, ctr, data){
                  if(data != null) {
                    final c = RewindCall(Keys.toast, const Duration(milliseconds: 4000));
                    c.fireBy(fn: (){
                      StateXController.globalUpdate(Keys.toast, stateData: null);
                    });

                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: ToastView(
                        Text(
                          '$data',
                          style: const TextStyle(color: Colors.white),
                        ),
                        key: ValueKey(Generator.hashMd5(data)),
                      ),
                    );
                  }

                  return const SizedBox();
                }
            ),
          ],
        ),
      ),
    );
  }
  ///==================================================================================================
  Future<void> checkNewVersion() async {
    final oldVersion = SettingsManager.settingsModel.appVersion;

    if (oldVersion == null) {
      VersionManager.onFirstInstall();
    }
    else if (oldVersion < Constants.appVersionCode) {
      VersionManager.onUpdateInstall();
    }
  }

  Future<bool> prepareReporter() async {
    AppManager.reporter = Reporter(DirectoriesCenter.getAppFolderInExternalStorage(), 'report');

    return true;
  }

  Future<DatabaseHelper> prepareDatabase() async {
    DbCenter.db = DatabaseHelper();
    DbCenter.db.setDatabasePath(await DirectoriesCenter.getDatabasesDir());
    DbCenter.db.setDebug(false);

    await DbCenter.db.openTable(DbCenter.tbKv);
    await DbCenter.db.openTable(DbCenter.tbLanguages);
    await DbCenter.db.openTable(DbCenter.tbUserModel);
    await DbCenter.db.openTable(DbCenter.tbUserAdvanced);
    //await DbCenter.db.openTable(DbCenter.tbNotifiers);
    await DbCenter.db.openTable(DbCenter.tbCourseRequest);
    await DbCenter.db.openTable(DbCenter.tbAdvertising);
    await DbCenter.db.openTable(DbCenter.tbMediaMessage);
    await DbCenter.db.openTable(DbCenter.tbMediaMessageDraft);
    await DbCenter.db.openTable(DbCenter.tbTickets);
    await DbCenter.db.openTable(DbCenter.tbTicketsDraft);
    await DbCenter.db.openTable(DbCenter.tbTicketMessage);
    await DbCenter.db.openTable(DbCenter.tbTicketMessageDraft);
    await DbCenter.db.openTable(DbCenter.tbChats);
    //await DbCenter.db.openTable(DbCenter.tbChatDraft);
    await DbCenter.db.openTable(DbCenter.tbChatMessage);
    await DbCenter.db.openTable(DbCenter.tbChatMessageDraft);
    await DbCenter.db.openTable(DbCenter.tbMaterials);
    //await DbCenter.db.openTable(DbCenter.tbPrograms);
    await DbCenter.db.openTable(DbCenter.tbCaloriesCounter);
    

    return DbCenter.db;
  }

  Future<void> testCodes(BuildContext context) async { //deep:56
    //await DbCenter.db.clearTable(DbCenter.tbKv);
  }
}
///==================================================================================================
class ClearFocusOnPush extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    final focus = FocusManager.instance.primaryFocus;
    focus?.unfocus();
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}
