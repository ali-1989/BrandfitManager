import 'package:flutter/widgets.dart';

import 'package:iris_tools/api/helpers/jsonHelper.dart';

import '/system/httpProcess.dart';
import '/system/keys.dart';
import '/tools/app/appManager.dart';
import '/tools/centers/httpCenter.dart';
import '/tools/centers/sheetCenter.dart';

///=============================================================================================
enum MethodType {
  Post,
  Get,
  Put
}

enum RequestPath {
  GetData,
  SetData,
  Others
}
///=============================================================================================
class Requester {
  Map<String, dynamic>? _bodyJs;
  MethodType methodType = MethodType.Post;
  RequestPath _requestPath = RequestPath.Others;
  late HttpRequester _httpRequester;
  late HttpRequestEvents httpRequestEvents;
  late HttpItem _http;

  Requester(){
    _prepareHttp();
    httpRequestEvents = HttpRequestEvents();
    _httpRequester = HttpRequester();
  }

  HttpItem get httpItem => _http;

  HttpRequester? get httpRequester => _httpRequester;

  Map<String, dynamic>? get bodyJson => _bodyJs;

  set requestPath(RequestPath requestPath) {
    _requestPath = requestPath;
  }

  set bodyJson(Map<String, dynamic>? js) {
    _bodyJs = js;

    if(js != null) {
      AppManager.addAppInfo(_bodyJs!);
    }
  }

  void _prepareHttp(){
    _http = HttpItem();
    _http.setResponseIsPlain();
  }

  void request([BuildContext? context]){
    _http.method = methodType == MethodType.Get? 'GET': 'POST';

    if(_requestPath != RequestPath.Others) {
      _http.pathSection = _requestPath == RequestPath.GetData ? '/get-data' : '/set-data';
    }

    if(_bodyJs != null) {
      _http.body = JsonHelper.mapToJson(_bodyJs!);
    }

    HttpCenter.cancelAndClose(_httpRequester);

    _httpRequester = HttpCenter.send(_http);

    var f = _httpRequester.responseFuture.catchError((e){
      if (_httpRequester.isDioCancelError){
        return _httpRequester.emptyError;
      }

      httpRequestEvents.onAnyState?.call(_httpRequester);
      httpRequestEvents.onFailState?.call(_httpRequester);
      httpRequestEvents.onNetworkError?.call(_httpRequester);
    });

    f = f.then((val) async {
      await httpRequestEvents.onAnyState?.call(_httpRequester);

      if(!_httpRequester.isOk){
        await httpRequestEvents.onFailState?.call(_httpRequester);
        await httpRequestEvents.onResponseError?.call(_httpRequester, false);
        return;
      }

      final Map? js = _httpRequester.getBodyAsJson();

      if (js == null) {
        await httpRequestEvents.onFailState?.call(_httpRequester);
        await httpRequestEvents.onResponseError?.call(_httpRequester, true);
        return;
      }

      if(httpRequestEvents.manageResponse != null){
        await httpRequestEvents.manageResponse?.call(_httpRequester, js);
        return;
      }

      final result = js[Keys.result]?? Keys.error;

      if(result == Keys.ok) {
        await httpRequestEvents.onResultOk?.call(_httpRequester, js);
      }
      else {
        await httpRequestEvents.onFailState?.call(_httpRequester);
        final managedByUser = await httpRequestEvents.onResultError?.call(_httpRequester, js)?? false;

        if(context != null) {
          if (!managedByUser && !HttpProcess.processCommonRequestError(context, js)) {
            await SheetCenter.showSheet$ServerNotRespondProperly(context);
          }
        }
      }
    });
  }
}
///================================================================================================
class HttpRequestEvents {
  Future Function(HttpRequester)? onNetworkError;
  Future Function(HttpRequester, bool)? onResponseError;
  Future Function(HttpRequester)? onAnyState;
  Future Function(HttpRequester)? onFailState;
  Future Function(HttpRequester, Map)? manageResponse;
  Future Function(HttpRequester, Map)? onResultOk;
  Future<bool> Function(HttpRequester, Map)? onResultError;
  //final cause = data[Keys.cause];
  //final causeCode = data[Keys.causeCode];
}
