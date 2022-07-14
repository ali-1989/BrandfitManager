import 'dart:async';

import 'package:flutter/material.dart';

import 'package:iris_db/iris_db.dart';
import 'package:iris_tools/dateSection/calendarTools.dart';

import '/managers/fontManager.dart';
import '/models/dataModels/settingsModel.dart';
import '/system/keys.dart';
import '/system/session.dart';
import '/tools/app/appThemes.dart';
import '/tools/centers/dbCenter.dart';
import '/tools/centers/httpCenter.dart';
import '/tools/centers/routeCenter.dart';
import '/tools/centers/wsCenter.dart';
import '/tools/dateTools.dart';

class SettingsManager {
	SettingsManager._();

	static bool serverHackState = false;
	static int homePageIndex = 2;
	static bool calledBootUp = false;
	static int webSocketPeriodicHeart = 3;
	static int drawerMenuTimeMill = 350;
	static Orientation? appRotationState; // null: free
	static final List<void Function()> _settingsChangeListeners = [];
	/// image/video in chat .................................................
	static int maxCoverWidth = 180;
	static int maxCoverHeightL = 120;
	static int maxCoverHeightP = 240;
	static int maxViewWidth = 380;
	static int maxViewHeightL = 200;
	static int maxViewHeightP = 460;
	/// saved settings .................................................
	static late SettingsModel _settingsModel;

	static final String _defaultRouteScreen = RoutesName.homePage;
	static final Locale _defaultAppLocale = const Locale('fa', 'IR');
	static final CalendarType _defaultCalendarType = CalendarType.byType(TypeOfCalendar.solarHijri);
	static final String _defaultDateFormat = DateTools.dateFormats.first;
	static final String _defaultHttpAddress = 'http://31.216.62.79:6060';
	static final String _defaultWsAddress = 'ws://31.216.62.79:6065/ws';
	static final String _defaultProxyAddress = '95.174.67.50:18080';
	//static final String _defaultHttpAddress = 'http://192.168.1.103:6060';
	//static final String _defaultWsAddress = 'ws://192.168.1.103:6065/ws';

	static SettingsModel get settingsModel => _settingsModel;

  static void addListeners(void Function() fn) {
		if(!_settingsChangeListeners.contains(fn)) {
		  _settingsChangeListeners.add(fn);
		}
  }

	static void removeListeners(Function fn){
		_settingsChangeListeners.remove(fn);
	}
	///=== save & fetch settings =======================================================================
	static Future<bool> saveSettings({BuildContext? context}) async {
		final con = Conditions();
		con.add(Condition()..key = Keys.name..value = Keys.appSettings);

		final newSettings = <String, dynamic>{};
		newSettings[Keys.name] = Keys.appSettings;
		newSettings[Keys.value] = settingsModel.toMap();

		final res = await DbCenter.db.insertOrReplace(DbCenter.tbKv, newSettings, con);

		context ??= RouteCenter.getContext();
		notify(context: context);

		return res > 0;
	}

	static void saveSettings$Delay({BuildContext? context}) {
		Timer(const Duration(seconds: 1), () {
			saveSettings(context: context);
		});
	}

	static bool loadSettings() {
		final con = Conditions();
		con.add(Condition()..key = Keys.name..value = Keys.appSettings);

		final res = DbCenter.db.query(DbCenter.tbKv, con);

		if(res.isEmpty) {
			_settingsModel = SettingsModel();
			prepareSettings();
		}
		else {
			final Map m = res.first;
			_settingsModel = SettingsModel.fromMap(m[Keys.value] ?? {});
			prepareSettings();
		}

		return true;
	}

	static Future<bool> prepareSettings({BuildContext? context}) {
		context ??= RouteCenter.getContext();
		//final locale = System.getCurrentLocalizationsLocale(context);

		settingsModel.lastUserId ??= Session.getLastLoginUser()?.userId;
		settingsModel.colorTheme ??= AppThemes.currentTheme.themeName;
		settingsModel.dateFormat ??= _defaultDateFormat;
		//settingsModel.languageIso ??= locale?.languageCode?? _defaultAppLocale.languageCode;
		settingsModel.languageIso ??= _defaultAppLocale.languageCode;
		settingsModel.countryIso ??= _defaultAppLocale.countryCode;
		settingsModel.currentRouteScreen ??= RouteCenter.fetchRouteScreenName()?? _defaultRouteScreen;
		settingsModel.httpAddress ??= _defaultHttpAddress; // remove ?? for set local
		settingsModel.wsAddress ??= _defaultWsAddress;
		settingsModel.proxyAddress ??= _defaultProxyAddress;

		settingsModel.appLocale = Locale(settingsModel.languageIso!, settingsModel.countryIso);

		if(settingsModel.calendarType.type == TypeOfCalendar.unKnow) {
			settingsModel.calendarType = _defaultCalendarType;
		}

		FontManager.fetchFontThemeData(settingsModel.appLocale.languageCode);

		if(AppThemes.currentTheme.themeName != settingsModel.colorTheme) {
			for (var t in AppThemes.themeList.entries) {
				if (t.key == settingsModel.colorTheme) {
					AppThemes.applyTheme(t.value);
					break;
				}
			}
		}

		return saveSettings(context: context);
  }

	static void notify({BuildContext? context}){
		Future((){
			for(Function f in _settingsChangeListeners){
				try{
					f();
				}
				catch(e){}
			}
		});
	}

	///--------------------------------------------------------------------------------------------------
	static Future<bool> changeHttpAddress(String address) async {
		settingsModel.httpAddress = address;
		HttpCenter.baseUri = address;

		return saveSettings();
	}

	static Future<bool> changeWebSocketAddress(String address) async {
		settingsModel.wsAddress = address;
		// ignore: unawaited_futures
		WsCenter.prepareWebSocket(address);

		return saveSettings();
	}

	static Future<bool> changeProxyAddress(String address) async {
		settingsModel.proxyAddress = address;

		return saveSettings();
	}
}

