import 'package:iris_db/iris_db.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/net/netManager.dart';

import '/managers/settingsManager.dart';
import '/system/keys.dart';
import '/tools/app/appManager.dart';
import '/tools/centers/dbCenter.dart';
import '/tools/centers/httpCenter.dart';
import '/tools/centers/localeCenter.dart';

class LanguageTools {
  LanguageTools._();

  static String getLanguageLocaleName() {
    final lanCode = SettingsManager.settingsModel.appLocale.languageCode;
    final Map<String, Map> languages = LocaleCenter.getAssetSupportedLanguages();

    for(var L in languages.entries){
      if(L.key == lanCode){
        return L.value['locale_name'];
      }
    }

    return 'English!';
  }

  static Future prepareRequestAppLanguages() async {
    final listener = NetListener('updateLanguages');

    listener.onConnected = (bool isWifi){
      requestUpdateAppLanguages().then((value){
        listener.purge();
      });
    };

    listener.listenIfNot();
  }

  static Future<bool> requestUpdateAppLanguages() async{
    if(!(await NetManager.isConnected())){
      return false;
    }

    final js = <String, dynamic>{};
    js[Keys.request] = 'GetLanguages';
    AppManager.addAppInfo(js);

    final request = HttpItem();
    request.pathSection = '/get-data';
    request.method = 'POST';
    request.body = JsonHelper.mapToJson(js);

    final f = Future<bool>((){
      final response = HttpCenter.send(request);

      /*response.future.catchError((err){
				return err;
			}); uncomment , take error */

      return response.responseFuture.then((value) async{
        if (!response.isOk) {
          return false;
        }

        final json = response.getBodyAsJson();

        if (json == null) {
          return false;
        }

        final String result = json[Keys.request] ?? Keys.error;

        if (result == Keys.ok) {
          final List<dynamic> array = json['Array'];

          for(Map<String, dynamic> jsItem in array){
            final newMap = jsItem.map((key, value) {
              /*if(key == 'Key') old: convert bit to num
                value = TextHelper.removeUntil('$value', "0", "1");*/

              //if(key == 'IsUsable') used for sqlLite
              //value = BoolHelper.isTrue(value)? 1: 0;
              return MapEntry(key, value);
            });

            await DbCenter.db.insertOrUpdate(DbCenter.tbLanguages, newMap,
                Conditions().add(Condition()..key = 'iso'..value = newMap['iso'])
                    .add(Condition()..key = 'iso_and_country'..value = newMap['iso_and_country']));
          }

          return true;
        }
        else if (result == Keys.error) {
          return false;
        }

        return false;
      });
    });

    return f;
  }
}
