import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/localeHelper.dart';
import 'package:iris_tools/modules/stateManagers/selfRefresh.dart';

import '/abstracts/stateBase.dart';
import '/models/dataModels/usersModels/appUserModel.dart';
import '/system/keys.dart';
import '/system/requester.dart';
import '/system/session.dart';
import '/tools/app/appNavigator.dart';
import '/tools/app/appThemes.dart';
import '/tools/centers/sheetCenter.dart';
import '/tools/centers/snackCenter.dart';

class EditUserNameScreen extends StatefulWidget {
  static const screenName = 'EditUserNameScreen';
  final AppUserModel pupilModel;

  const EditUserNameScreen({
    Key? key,
    required this.pupilModel,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => EditUserNameScreenState();
}
///==============================================================================================
class EditUserNameScreenState extends StateBase<EditUserNameScreen> {
  final usernameCtr = TextEditingController();
  late Requester commonRequester;
  late AppUserModel pupilModel;


  @override
  void initState() {
    super.initState();

    commonRequester = Requester();

    pupilModel = widget.pupilModel;
    usernameCtr.text = pupilModel.userName!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 42),
        child: Column(
          children: [
            SelfRefresh(
                builder: (BuildContext context, UpdateController ctr) {
                  return TextFormField(
                    textDirection: ctr.getOrDefault('direction', LocaleHelper.autoDirection(usernameCtr.text)),
                    controller: usernameCtr,
                    textInputAction: TextInputAction.next,
                    style: AppThemes.baseTextStyle(),
                    onTap: () {
                      FocusHelper.fullSelect(usernameCtr);
                    },
                    onChanged: (t){
                      ctr.set('direction', LocaleHelper.autoDirection(t));
                      ctr.update();
                    },
                    onFieldSubmitted: (_) {
                      /*no need focusNode.nextFocus();*/
                    },
                    decoration: InputDecoration(
                      hintText: '${t('name')}',
                      border: InputBorder.none,
                    ),
                  );
                }
            ),

            const SizedBox(height: 40,),
            Center(
              child: ElevatedButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 50)),
                ),
                onPressed: (){
                  uploadUserName(usernameCtr.text);
                },
                child: Text('${tC('apply')}'),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameCtr.dispose();
    
    super.dispose();
  }

  void uploadUserName(String username) {
    if(username.isEmpty){
      SheetCenter.showSheetNotice(context, tC('selectOneUsername')!);
      return;
    }

    Map<String, dynamic> js = {};
    js[Keys.request] = Keys.adminCommand;
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.subRequest] = 'UpdateProfileUserName';
    js[Keys.forUserId] = pupilModel.userId;
    js[Keys.userName] = username;

    commonRequester.requestPath = RequestPath.SetData;
    commonRequester.bodyJson = js;

    commonRequester.httpRequestEvents.onAnyState = (req) async {
      await hideLoading();
    };

    commonRequester.httpRequestEvents.onNetworkError = (req) async {
      SnackCenter.showSnack$errorCommunicatingServer(context);
    };

    commonRequester.httpRequestEvents.onResponseError = (req, isOk) async {
      if(isOk) {
        SnackCenter.showSnack$errorInServerSide(context);
      } else {
        SnackCenter.showSnack$errorCommunicatingServer(context);
      }
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      return false;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      pupilModel.userName = username;
      AppNavigator.pop(context);
    };

    showLoading();
    commonRequester.request(context);
  }
}
