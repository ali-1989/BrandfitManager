import 'package:brandfit_manager/tools/app/appNotification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:iris_download_manager/downloadManager/downloadManager.dart';
import 'package:iris_download_manager/uploadManager/uploadManager.dart';
import 'package:iris_tools/api/helpers/storageHelper.dart';
import 'package:iris_tools/api/logger/logger.dart';

import '/constants.dart';
import '/managers/settingsManager.dart';
import '/system/downloadUpload.dart';
import '/tools/app/appManager.dart';
import '/tools/centers/cacheCenter.dart';
import '/tools/centers/directoriesCenter.dart';
import '/tools/centers/httpCenter.dart';
import '/tools/centers/localeCenter.dart';
import '/tools/centers/wsCenter.dart';
import '/tools/countryTools.dart';
import '/tools/deviceInfoTools.dart';
import '/tools/playerTools.dart';

class Initial {
	Initial._();

	static bool isFired = false;
	static bool isInitial = false;

	static Future<bool> waitForImportant() async {
		await DirectoriesCenter.prepareStoragePaths(Constants.appName);
		await DeviceInfoTools.prepareDeviceInfo();
		await DeviceInfoTools.prepareDeviceId();

		return true;
	}

	static Future<bool> oncePreparing(BuildContext context) async {
		if(isFired) {
			return true;
		}

		isFired = true;
		if(kIsWeb) {
		  AppManager.logger = Logger(StorageHelper.getMemoryFileSystem().path.current + '/events.txt');
		} else {
		  AppManager.logger = Logger(DirectoriesCenter.getTempDir$ex() + '/events.txt');
		}

		// ignore: unawaited_futures
		LocaleCenter.localeDelegate().getLocalization().setFallbackByLocale(const Locale('en', 'US'));
		HttpCenter.baseUri = SettingsManager.settingsModel.httpAddress!;
		await WsCenter.prepareWebSocket(SettingsManager.settingsModel.wsAddress!);
		PlayerTools.init();
		DownloadUpload.downloadManager = DownloadManager('${Constants.appName}DownloadManager');
		DownloadUpload.uploadManager = UploadManager('${Constants.appName}UploadManager');
		CacheCenter.screenBack = AssetImage('assets/images/selectLanguage.jpg');
		await precacheImage(CacheCenter.screenBack!, context);
		// ignore: unawaited_futures
		CountryTools.fetchCountries();


		if(!kIsWeb) {
			await AppNotification.initial();
		}

		isInitial = true;
		return true;
	}
}
