import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import '/system/keys.dart';
import '/tools/app/appManager.dart';
import '/tools/centers/cacheCenter.dart';
import '/tools/centers/httpCenter.dart';

class ServerTimeTools {
  ServerTimeTools._();

  static Duration? _serverUtcDif;

  static Future<bool> requestUtcTimeOfServer(){
    if(!CacheCenter.timeoutCache.addTimeout('getUtcTimeOfServer', Duration(seconds: 5))){
      return Future.value(false);
    }

    final js = <String, dynamic>{};
    js[Keys.request] = 'GetUtcTimeStamp';

    AppManager.addAppInfo(js);

    final item = HttpItem();
    item.method = 'POST';
    item.pathSection = '/get-data';
    item.body = JsonHelper.mapToJson(js);

    final res = HttpCenter.send(item);

    return res.responseFuture.then((value) {
      if(value == null || value is Exception || !res.isOk){
        return false;
      }

      final js = res.getBodyAsJson()!;
      final serverUtc = DateHelper.tsToSystemDate(js[Keys.value]);

      if(serverUtc != null) {
        _serverUtcDif = serverUtc.difference(DateHelper.localToUtc(DateTime.now()));
      }

      return _serverUtcDif != null;
    });
  }

  static Duration? get serverUtcDiff => _serverUtcDif;

  static DateTime get localTimeMatchServer {
    var now = DateTime.now();

    if(_serverUtcDif != null){
      now = now.add(_serverUtcDif!);
    }

    return now;
  }

  static DateTime get utcTimeMatchServer {
    return DateHelper.localToUtc(localTimeMatchServer);
  }
}
