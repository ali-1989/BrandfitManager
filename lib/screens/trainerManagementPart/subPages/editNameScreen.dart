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

class EditNameScreen extends StatefulWidget {
  static const screenName = 'EditNameScreen';
  final AppUserModel pupilModel;

  const EditNameScreen({
    Key? key,
    required this.pupilModel,
  }) : super(key: key);

  @override
  State<EditNameScreen> createState() => _EditNameScreenState();
}
///==============================================================================================
class _EditNameScreenState extends StateBase<EditNameScreen> {
  final nameCtr = TextEditingController();
  final familyCtr = TextEditingController();
  late Requester commonRequester;
  late AppUserModel pupilModel;


  @override
  void initState() {
    super.initState();

    commonRequester = Requester();

    pupilModel = widget.pupilModel;
    nameCtr.text = pupilModel.name!;
    familyCtr.text = pupilModel.family!;
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
                    textDirection: ctr.getOrDefault('direction', LocaleHelper.autoDirection(nameCtr.text)),
                    controller: nameCtr,
                    //validator: (_) => validation(state, userNameCtl),
                    textInputAction: TextInputAction.next,
                    style: AppThemes.baseTextStyle(),
                    onTap: () {
                      FocusHelper.fullSelect(nameCtr);
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

            SelfRefresh(
                builder: (BuildContext context, UpdateController ctr) {
                  return TextFormField(
                    textDirection: ctr.getOrDefault('direction', LocaleHelper.autoDirection(familyCtr.text)),
                    controller: familyCtr,
                    //validator: (_) => validation(state, userNameCtl),
                    textInputAction: TextInputAction.done,
                    style: AppThemes.baseTextStyle(),
                    onTap: () {
                      FocusHelper.fullSelect(familyCtr);
                    },
                    onChanged: (t){
                      ctr.set('direction', LocaleHelper.autoDirection(t));
                      ctr.update();
                    },
                    onFieldSubmitted: (_) {
                      /*no need focusNode.nextFocus();*/
                    },
                    decoration: InputDecoration(
                      hintText: '${t('family')}',
                      border: InputBorder.none,
                      //hintStyle: TextStyle(color: Colors.white),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppThemes.currentTheme.textColor)),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppThemes.currentTheme.textColor)),
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
                  uploadName(nameCtr.text, familyCtr.text);
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
    nameCtr.dispose();
    familyCtr.dispose();
    
    super.dispose();
  }

  void uploadName(String name, String family) {
    if(name.isEmpty){
      SheetCenter.showSheetNotice(context, tC('enterYourName')!);
      return;
    }

    if(family.isEmpty){
      SheetCenter.showSheetNotice(context, tC('enterFamily')!);
      return;
    }

    Map<String, dynamic> js = {};
    js[Keys.request] = Keys.adminCommand;
    js[Keys.requesterId] = Session.getLastLoginUser()?.userId;
    js[Keys.subRequest] = 'UpdateProfileNameFamily';
    js[Keys.forUserId] = pupilModel.userId;
    js[Keys.name] = name;
    js['family'] = family;

    commonRequester.requestPath = RequestPath.SetData;
    commonRequester.bodyJson = js;

    commonRequester.httpRequestEvents.onAnyState = (req) async {
      await hideLoading();
    };

    commonRequester.httpRequestEvents.onNetworkError = (req) async {
      SnackCenter.showSnack$errorCommunicatingServer(context);
    };

    commonRequester.httpRequestEvents.onResponseError = (req, isOk) async {
      SnackCenter.showSnack$errorInServerSide(context);
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      return false;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      pupilModel.name = name;
      pupilModel.family = family;

      AppNavigator.pop(context);
    };

    showLoading();
    commonRequester.request(context);
  }
}
