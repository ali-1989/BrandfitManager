import '/constants.dart';
import '/managers/settingsManager.dart';
import '/tools/centers/dbCenter.dart';

class VersionManager {
  VersionManager._();

  static Future<void> onFirstInstall() async {
    SettingsManager.settingsModel.appVersion = Constants.appVersionCode;

    await DbCenter.firstDatabasePrepare();
    SettingsManager.saveSettings();
  }

  static Future<void> onUpdateInstall() async {
    SettingsManager.settingsModel.appVersion = Constants.appVersionCode;
    // ignore: unawaited_futures
    SettingsManager.saveSettings();
  }
}