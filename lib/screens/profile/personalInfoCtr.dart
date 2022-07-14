

import 'package:flutter/material.dart';

import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/features/overlayDialog.dart';
import 'package:iris_tools/widgets/text/autoDirection.dart';

import '/abstracts/viewController.dart';
import '/models/dataModels/usersModels/fitnessDataModel.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/screens/profile/personalInfoScreen.dart';
import '/system/keys.dart';
import '/system/requester.dart';
import '/system/session.dart';
import '/tools/app/appNavigator.dart';
import '/tools/app/appThemes.dart';
import '/tools/centers/httpCenter.dart';
import '/tools/centers/sheetCenter.dart';
import '/views/loadingScreen.dart';

class PersonalInfoCtr implements ViewController {
  late PersonalInfoScreenState state;
  late Requester commonRequester;
  late UserModel user;
  String countryName = '';


  @override
  void onInitState<E extends State>(E state){
    this.state = state as PersonalInfoScreenState;

    commonRequester = Requester();

    user = Session.getLastLoginUser()!;
    countryName = user.countryName;

    Session.addLogoffListener(onLogout);
  }

  @override
  void onBuild(){
  }

  @override
  void onDispose(){
    Session.removeLogoffListener(onLogout);
    HttpCenter.cancelAndClose(commonRequester.httpRequester);
  }

  void onLogout(user){
    Session.removeLogoffListener(onLogout);
    HttpCenter.cancelAndClose(commonRequester.httpRequester);
    AppNavigator.popRoutesUntilRoot(state.context);
  }
  ///========================================================================================================
  void tryAgain(State state){
    if(state is PersonalInfoScreenState) {
    }
  }

  void showEditNameScreen(String screenName){
    final nameCtr = TextEditingController();
    final familyCtr = TextEditingController();
    nameCtr.text = user.name?? '';
    familyCtr.text = user.family?? '';

    final Widget screen = Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 22),
        child: Column(
          children: [
            AutoDirection(
                builder: (context, dCtr) {
                  return TextFormField(
                    textDirection: dCtr.getTextDirection(nameCtr.text),
                    controller: nameCtr,
                    //validator: (_) => validation(state, userNameCtl),
                    textInputAction: TextInputAction.next,
                    style: AppThemes.baseTextStyle(),
                    onTap: () {
                      dCtr.manageSelection(nameCtr);
                    },
                    onChanged: (t){
                      dCtr.onChangeText(t);
                    },
                    decoration: InputDecoration(
                      hintText: '${state.t('name')}',
                      border: InputBorder.none,
                    ),
                  );
                }
            ),

            AutoDirection(
                builder: (context, dCtr) {
                  return TextFormField(
                    textDirection: dCtr.getTextDirection(nameCtr.text),
                    controller: familyCtr,
                    //validator: (_) => validation(state, userNameCtl),
                    textInputAction: TextInputAction.done,
                    style: AppThemes.baseTextStyle(),
                    onTap: () {
                      dCtr.manageSelection(familyCtr);
                    },
                    onChanged: (t){
                      dCtr.onChangeText(t);
                    },
                    decoration: InputDecoration(
                      hintText: '${state.t('family')}',
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
                child: Text('${state.tC('apply')}'),
              ),
            )
          ],
        ),
      ),
    );

    final view = OverlayScreenView(
      content: SizedBox.expand(
        child: screen,
      ),
      routingName: screenName,
      backgroundColor: AppThemes.currentTheme.backgroundColor,
    );

    OverlayDialog().show(state.context, view).then((value){
      state.stateController.updateMain();
    });
  }

  void uploadName(String name, String family) {
    if(name.isEmpty){
      SheetCenter.showSheetNotice(state.context, state.tC('enterYourName')!);
      return;
    }

    if(family.isEmpty){
      SheetCenter.showSheetNotice(state.context, state.tC('enterFamily')!);
      return;
    }

    final js = <String, dynamic>{};
    js[Keys.request] = 'UpdateProfileNameFamily';
    js[Keys.forUserId] = user.userId;
    js[Keys.name] = name;
    js[Keys.family] = family;

    commonRequester.bodyJson = js;
    commonRequester.requestPath = RequestPath.SetData;

    commonRequester.httpRequestEvents.onAnyState = (req) async {
      state.hideLoading();
    };

    commonRequester.httpRequestEvents.onFailState = (req) async {
      SheetCenter.showSheet$ServerNotRespondProperly(state.context);
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      return true;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      user.name = name;
      user.family = family;

      await Session.sinkUserInfo(user).then((value) async{
        await LoadingScreen.hideLoading(state.context);
        AppNavigator.pop(state.context);
      });

      state.stateController.updateMain();
    };

    state.showLoading(canBack: false);
    commonRequester.request(state.context);
  }

  void uploadGender(int sex) {
    final js = <String, dynamic>{};
    js[Keys.request] = 'UpdateProfileSex';
    js[Keys.forUserId] = user.userId;
    js[Keys.sex] = sex;

    commonRequester.bodyJson = js;
    commonRequester.requestPath = RequestPath.SetData;

    commonRequester.httpRequestEvents.onAnyState = (req) async {
      state.hideLoading();
    };

    commonRequester.httpRequestEvents.onFailState = (req) async {
      SheetCenter.showSheet$ServerNotRespondProperly(state.context);
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      return true;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      user.sex = sex;

      await Session.sinkUserInfo(user).then((value) async{
        await LoadingScreen.hideLoading(state.context);
        AppNavigator.pop(state.context);
      });

      state.stateController.updateMain();
    };

    state.showLoading(canBack: false);
    commonRequester.request(state.context);
  }

  void uploadBirthDate(DateTime ageTs) {
    final js = <String, dynamic>{};
    js[Keys.request] = 'UpdateProfileBirthDate';
    js[Keys.forUserId] = user.userId;
    js[Keys.birthdate] = DateHelper.dateOnlyToStamp(ageTs);

    commonRequester.bodyJson = js;
    commonRequester.requestPath = RequestPath.SetData;

    commonRequester.httpRequestEvents.onAnyState = (req) async {
      state.hideLoading();
    };

    commonRequester.httpRequestEvents.onFailState = (req) async {
      SheetCenter.showSheet$ServerNotRespondProperly(state.context);
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      return true;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      user.birthDate = ageTs;

      await Session.sinkUserInfo(user).then((value) async{
        await LoadingScreen.hideLoading(state.context);
        AppNavigator.pop(state.context);
      });

      state.stateController.updateMain();
    };

    state.showLoading(canBack: false);
    commonRequester.request(state.context);
  }

  void uploadHeight(double height) {
    final js = <String, dynamic>{};
    js[Keys.request] = 'UpdateFitnessStatus';
    js[Keys.userId] = user.userId;
    js['node_name'] = 'height_node';
    js[Keys.value] = height;

    commonRequester.bodyJson = js;
    commonRequester.requestPath = RequestPath.SetData;

    commonRequester.httpRequestEvents.onAnyState = (req) async {
      state.hideLoading();
    };

    commonRequester.httpRequestEvents.onFailState = (req) async {
      SheetCenter.showSheet$ServerNotRespondProperly(state.context);
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      return true;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      final fitnessJs = js['fitness_status_js'];

      if(fitnessJs != null){
        user.fitnessDataModel.matchBy(FitnessDataModel.fromMap(fitnessJs));
      }

      await Session.sinkUserInfo(user).then((value) async{
        await LoadingScreen.hideLoading(state.context);
        AppNavigator.pop(state.context);
      });

      state.stateController.updateMain();
    };

    state.showLoading(canBack: false);
    commonRequester.request(state.context);
  }

  void uploadWeight(double weight) {
    final js = <String, dynamic>{};
    js[Keys.request] = 'UpdateFitnessStatus';
    js[Keys.userId] = user.userId;
    js['node_name'] = 'weight_node';
    js[Keys.value] = weight;

    commonRequester.bodyJson = js;
    commonRequester.requestPath = RequestPath.SetData;

    commonRequester.httpRequestEvents.onAnyState = (req) async {
      state.hideLoading();
    };

    commonRequester.httpRequestEvents.onFailState = (req) async {
      SheetCenter.showSheet$ServerNotRespondProperly(state.context);
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      return true;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      final fitnessJs = js['fitness_status_js'];

      if(fitnessJs != null){
        user.fitnessDataModel.matchBy(FitnessDataModel.fromMap(fitnessJs));
      }

      await Session.sinkUserInfo(user).then((value) async{
        await LoadingScreen.hideLoading(state.context);
        AppNavigator.pop(state.context);
      });

      state.stateController.updateMain();
    };

    state.showLoading(canBack: false);
    commonRequester.request(state.context);
  }

  void uploadCountryIso(String countryCode, String countryIso, String countryName) {
    final js = <String, dynamic>{};
    js[Keys.request] = 'UpdateUserCountryIso';
    js[Keys.userId] = user.userId;
    js[Keys.countryIso] = countryIso;
    js[Keys.phoneCode] = countryCode;

    commonRequester.bodyJson = js;
    commonRequester.requestPath = RequestPath.SetData;

    commonRequester.httpRequestEvents.onAnyState = (req) async {
      state.hideLoading();
    };

    commonRequester.httpRequestEvents.onFailState = (req) async {
      SheetCenter.showSheet$ServerNotRespondProperly(state.context);
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      return true;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      user.countryModel.countryIso = countryIso;
      user.countryModel.countryPhoneCode = countryCode;
      user.countryModel.countryName = countryName;
      countryName = countryName;

      await Session.sinkUserInfo(user).then((value) async{
        await LoadingScreen.hideLoading(state.context);
      });

      state.stateController.updateMain();
    };

    state.showLoading(canBack: false);
    commonRequester.request(state.context);
  }
}
