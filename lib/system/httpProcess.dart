import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';

import '/system/extensions.dart';
import '/system/httpCodes.dart';
import '/system/keys.dart';
import '/system/session.dart';
import '/tools/centers/dialogCenter.dart';
import '/tools/centers/routeCenter.dart';
import '/tools/centers/sheetCenter.dart';
import '/tools/centers/snackCenter.dart';
import '/tools/userLoginTools.dart';

class HttpProcess {
  HttpProcess._();

  static bool processCommonRequestError(BuildContext context, Map json) {
    final int causeCode = json[Keys.causeCode] ?? 0;
    final String cause = json[Keys.cause] ?? Keys.error;

    return processCommonRequestErrors(context, causeCode, cause, json);
  }

  static bool processCommonRequestErrors(BuildContext context, int causeCode, String? cause, Map json){
    if(causeCode == HttpCodes.error_requestKeyNotFound){
      SnackCenter.showFlashBarError(context, "'request' key not exist");
      return true;
    }
    else if(causeCode == HttpCodes.error_tokenNotCorrect){
      SnackCenter.showFlashBarError(context, context.tInMap('httpCodes', 'tokenIsIncorrect')!);
      return true;
    }
    else if(causeCode == HttpCodes.error_databaseError){
      SnackCenter.showFlashBarError(context, context.tInMap('httpCodes', 'databaseError')!);
      return true;
    }
    else if(causeCode == HttpCodes.error_userIsBlocked){
      SnackCenter.showFlashBarInfo(context, context.tInMap('httpCodes', 'accountIsBlock')!);
      return true;
    }
    else if(causeCode == HttpCodes.error_userNotFound){
      SnackCenter.showFlashBarInfo(context, context.tInMap('httpCodes', 'userNameOrPasswordIncorrect')!);
      return true;
    }
    else if(causeCode == HttpCodes.error_userNamePassIncorrect){
      SnackCenter.showFlashBarInfo(context, context.tInMap('httpCodes', 'userNameOrPasswordIncorrect')!);
      return true;
    }
    else if(causeCode == HttpCodes.error_isNotJson){
      SnackCenter.showFlashBarError(context,  'request data not a json');
      return true;
    }
    else if(causeCode == HttpCodes.error_parametersNotCorrect){
      SnackCenter.showFlashBarError(context, context.tInMap('httpCodes', 'errorOccurredInSubmittedParameters')!);
      return true;
    }
    else if(causeCode == HttpCodes.error_notUpload){
      SnackCenter.showFlashBarError(context, context.tInMap('httpCodes', 'errorUploadingData')!);
      return true;
    }
    else if(causeCode == HttpCodes.error_internalError){
      SnackCenter.showFlashBarError(context, context.tInMap('httpCodes', 'errorInServerSide')!);
      return true;
    }
    else if(causeCode == HttpCodes.error_dataNotExist){
      SnackCenter.showFlashBarInfo(context, context.tInMap('httpCodes', 'dataNotFound')!);
      return true;
    }
    else if(causeCode == HttpCodes.error_canNotAccess){
      SheetCenter.showSheet$YouDoNotHaveAccess(context);
      return true;
    }
    else if(causeCode == HttpCodes.error_operationCannotBePerformed){
      SheetCenter.showSheet$OperationCannotBePerformed(context);
      return true;
    }
    else if(causeCode == HttpCodes.error_requestNotDefined){
      SnackCenter.showFlashBarInfo(context, context.tInMap('httpCodes', 'thisRequestNotDefined')!);
      return true;
    }
    else if(causeCode == HttpCodes.error_userMessage){
      SnackCenter.showFlashBarAction(context, cause!, TextButton(
          onPressed: (){SheetCenter.closeSheet(context);}, child: Text('${context.tC('ok')}')
      ), autoDismiss: false,);
      return true;
    }

    return false;
  }

  static bool onResponse(Response response){
    final statusCode = response.statusCode?? 0;

    if(statusCode == 200){
      final isString = response.data is String;
      final json = isString? JsonHelper.jsonToMap(response.data): null;

      if(json != null){
          final causeCode = json[Keys.causeCode]?? 0;

          if(causeCode == HttpCodes.error_tokenNotCorrect){
            UserLoginTools.forceLogoff(Session.getLastLoginUser()?.userId?? 0);

            DialogCenter.instance.showInfoDialog(
                RouteCenter.getFirstContext(),
                null,
                RouteCenter.getFirstContext().t('yourTokenExp')!
            );
          }
      }
    }

    return true;
  }
}
