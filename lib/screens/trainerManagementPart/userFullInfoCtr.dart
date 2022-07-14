import 'package:flutter/material.dart';

import 'package:animate_do/animate_do.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/widgets/optionsRow/checkRow.dart';
import 'package:iris_tools/modules/stateManagers/selfRefresh.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '/abstracts/viewController.dart';
import '/models/dataModels/usersModels/appUserModel.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/screens/commons/imageFullScreen.dart';
import '/screens/trainerManagementPart/bioPart/bioScreen.dart';
import '/screens/trainerManagementPart/subPages/editNameScreen.dart';
import '/screens/trainerManagementPart/subPages/editUserNameScreen.dart';
import '/screens/trainerManagementPart/userFullInfoScreen.dart';
import '/system/enums.dart';
import '/system/extensions.dart';
import '/system/keys.dart';
import '/system/multiViewDialog.dart';
import '/system/requester.dart';
import '/system/session.dart';
import '/tools/app/appNavigator.dart';
import '/tools/app/appSizes.dart';
import '/tools/app/appThemes.dart';
import '/tools/centers/httpCenter.dart';
import '/tools/centers/sheetCenter.dart';
import '/tools/centers/snackCenter.dart';
import '/views/dateViews/selectDateCalendarView.dart';

class UserFullInfoCtr implements ViewController {
  late UserFullInfoScreenState state;
  late UserModel user;
  late AppUserModel pupilModel;
  late Requester commonRequester;

  @override
  void onInitState<E extends State>(E state){
    this.state = state as UserFullInfoScreenState;

    commonRequester = Requester();
    commonRequester.requestPath = RequestPath.GetData;

    pupilModel = state.widget.userModel;

    Session.addLogoffListener(onLogout);
  }

  @override
  void onBuild(){
    user = Session.getLastLoginUser()!;
  }

  @override
  void onDispose(){
    Session.removeLogoffListener(onLogout);
    HttpCenter.cancelAndClose(commonRequester.httpRequester);
  }

  void onLogout(user){
    HttpCenter.cancelAndClose(commonRequester.httpRequester);
    state.stateController.updateMain();
  }
  ///========================================================================================================
  void tryAgain(State state){
  }

  void tryLogin(State state){
  }

  void gotoBioScreen(){
    AppNavigator.pushNextPage(state.context, BioScreen(trainerModel: pupilModel,), name: BioScreen.screenName);
  }
  void showFullScreenImage(){
    if(pupilModel.profileFile == null){
      return;
    }

    final view = ImageFullScreen(
      imageType: ImageType.File,
      heroTag: 'h${pupilModel.userId}',
      imageObj: pupilModel.profileFile!,
    );

    AppNavigator.pushNextPageExtra(state.context, view, name: ImageFullScreen.screenName);
  }

  void showEditSheet(){
    final v = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 33),
      child: Table(
        defaultColumnWidth: const FractionColumnWidth(0.5),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        textDirection: TextDirection.ltr,
        children: [
          TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: ElevatedButton(
                    child: Text('${state.tC('edit', key2: 'name')}'),
                    onPressed: (){
                      SheetCenter.closeSheetByName(state.context, 'EditUser');
                      showEditNameScreen('EditNameScreen');
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: ElevatedButton(
                    child: Text('${state.tC('edit', key2: 'userName')}'),
                    onPressed: (){
                      SheetCenter.closeSheetByName(state.context, 'EditUser');
                      showEditUserNameScreen('EditUserNameScreen');
                    },
                  ),
                )
              ]
          ),

          TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: ElevatedButton(
                    child: Text('${state.tC('edit', key2: 'birthDate')}'),
                    onPressed: (){
                      SheetCenter.closeSheetByName(state.context, 'EditUser');
                      showEditBirthdateScreen('EditBirthdateScreen');
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: ElevatedButton(
                    child: Text('${state.tC('edit', key2: 'gender')}'),
                    onPressed: (){
                      SheetCenter.closeSheetByName(state.context, 'EditUser');
                      showEditGenderScreen('EditGenderScreen');
                    },
                  ),
                )
              ]
          ),

          TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: ElevatedButton(
                    child: Text('${state.tInMap('trainerManagementPage', 'broadcastCourseState')}'),
                    onPressed: (){
                      SheetCenter.closeSheetByName(state.context, 'EditUser');
                      showEditCourseStatePrompt('EditCourseStatePrompt');
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: ElevatedButton(
                    child: Text('${state.tInMap('trainerManagementPage', 'trainerScopeState')}'),
                    onPressed: (){
                      SheetCenter.closeSheetByName(state.context, 'EditUser');
                      showEditTrainerStatePrompt('EditTrainerStatePrompt');
                    },
                  ),
                )
              ]
          ),

          TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: ElevatedButton(
                    child: pupilModel.isBlocked?
                    Text('${state.tC('unblocking', key2: 'user')}')
                        : Text('${state.tC('block', key2: 'user')}'),
                    onPressed: (){
                      SheetCenter.closeSheetByName(state.context, 'EditUser');
                      blockUser();
                    },
                  ),
                ),

                const SizedBox(height: 10,),
              ]
          ),
        ],
      ),
    );

    final sheet = SheetCenter.generateCloseSheet(state.context, v, 'EditUser', backColor: Colors.white);
    SheetCenter.showModalSheet(state.context, (_)=> sheet, routeName: 'EditUser');
  }

  void showEditNameScreen(String screenName){
    AppNavigator.pushNextPage(
        state.context,
        EditNameScreen(pupilModel: pupilModel,),
        name: EditNameScreen.screenName
    ).then((value){
      state.stateController.updateMain();
    });
  }

  void showEditUserNameScreen(String screenName){
    AppNavigator.pushNextPage(
        state.context,
        EditUserNameScreen(pupilModel: pupilModel,),
        name: EditUserNameScreen.screenName
    ).then((value){
      state.stateController.updateMain();
    });
  }

  void showEditGenderScreen(String screenName){
    var selectedGender = pupilModel.sexInt!-1; //1 man, 2 woman

    if(selectedGender < 0){
      selectedGender = 0;
    }

    final view = MultiViewDialog.addCloseBtn(
      state.context,
      SizedBox(
        width: AppSizes.getScreenWidth(state.context),
        child: ColoredBox(
          color: AppThemes.currentTheme.backgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
            child: FlipInX(
              delay: const Duration(milliseconds: 300),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('${state.tC('gender')}:').bold().fs(16),
                  SizedBox(height: AppSizes.fwSize(16),),
                  ToggleSwitch(
                    initialLabelIndex: selectedGender,
                    cornerRadius: 12.0,
                    //minWidth: 100,
                    activeBgColor: [AppThemes.currentTheme.activeItemColor],
                    inactiveBgColor: Colors.grey[400],
                    activeFgColor: Colors.white,
                    inactiveFgColor: AppThemes.currentTheme.inactiveTextColor,
                    totalSwitches: 2,
                    textDirectionRTL: true,
                    labels: [state.tC('male')!, state.tC('female')!],
                    onToggle: (index) {
                      selectedGender = index!;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      withExpanded: false,
      navName: screenName,
    );

    SheetCenter.showSheetCustom(
      state.context,
      view,
      positiveButton: ElevatedButton(
        child: Text('${state.tC('apply')}'),
        onPressed: (){
          uploadGender(selectedGender+1);
        },
      ),
      routeName: screenName,
      backgroundColor: Colors.transparent,
      contentColor: Colors.transparent,
      buttonBarColor: AppThemes.currentTheme.backgroundColor,
    );
  }

  void showEditBirthdateScreen(String screenName){
    var birthDate = pupilModel.birthDate?? DateTime(DateTime.now().year-10);

    final view = MultiViewDialog.addCloseBtn(
      state.context,
      SelectDateCalendarView(
        currentDate: birthDate,
        minYear: 1920,
        onSelect: (d){
          uploadBirthDate(d);
        },
      ),
      navName: screenName,
    );

    SheetCenter.showSheetCustom(
      state.context,
      view,
      routeName: screenName,
      backgroundColor: Colors.transparent,
      contentColor: Colors.transparent,
      buttonBarColor: AppThemes.currentTheme.backgroundColor,
    );
  }

  void showEditTrainerStatePrompt(String screenName){
    var isExercise = pupilModel.isExerciseTrainer;
    var isFood = pupilModel.isFoodTrainer;

    final view = MultiViewDialog.addCloseBtn(
      state.context,
      SelfRefresh(
        builder: (context, ctr) {
          return SizedBox(
            width: AppSizes.getScreenWidth(state.context),
            child: ColoredBox(
              color: AppThemes.currentTheme.backgroundColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
                child: FlipInX(
                  delay: const Duration(milliseconds: 300),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${state.tInMap('trainerManagementPage', 'trainerScopeState')}:').bold().fs(16),
                      SizedBox(height: AppSizes.fwSize(16),),
                      CheckBoxRow(
                          value: isExercise,
                          description: Text('${state.tInMap('trainerManagementPage', 'isExerciseTrainer')}')
                              .color(Colors.black),
                          onChanged: (v){
                            isExercise = !isExercise;
                            ctr.update();
                          }
                      ),

                      CheckBoxRow(
                          value: isFood,
                          description: Text('${state.tInMap('trainerManagementPage', 'isFoodTrainer')}')
                              .color(Colors.black),
                          onChanged: (v){
                            isFood = !isFood;
                            ctr.update();
                          }
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      ),
      withExpanded: false,
      navName: screenName,
    );

    SheetCenter.showSheetCustom(
      state.context,
      view,
      positiveButton: ElevatedButton(
        child: Text('${state.tC('apply')}'),
        onPressed: (){
          uploadTrainerState(isExercise, isFood);
        },
      ),
      routeName: screenName,
      backgroundColor: Colors.transparent,
      contentColor: Colors.transparent,
      buttonBarColor: AppThemes.currentTheme.backgroundColor,
    );
  }

  void showEditCourseStatePrompt(String screenName){
    var isBroadcastCourse = pupilModel.broadcastCourse;

    final view = MultiViewDialog.addCloseBtn(
      state.context,
        SelfRefresh(
            builder: (context, ctr) {
              return SizedBox(
                width: AppSizes.getScreenWidth(state.context),
                child: ColoredBox(
                  color: AppThemes.currentTheme.backgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
                    child: FlipInX(
                      delay: const Duration(milliseconds: 300),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('${state.tInMap('trainerManagementPage', 'broadcastCourseState')}:').bold().fs(16),
                          SizedBox(height: AppSizes.fwSize(16),),
                          CheckBoxRow(
                              value: isBroadcastCourse,
                              description: Text('${state.tInMap('trainerManagementPage', 'isBroadcastCourse')}')
                                  .color(Colors.black),
                              onChanged: (v){
                                isBroadcastCourse = !isBroadcastCourse;
                                ctr.update();
                              }
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
        ),
      withExpanded: false,
      navName: screenName,
    );

    SheetCenter.showSheetCustom(
      state.context,
      view,
      positiveButton: ElevatedButton(
        child: Text('${state.tC('apply')}'),
        onPressed: (){
          uploadBroadcastCourseState(isBroadcastCourse);
        },
      ),
      routeName: screenName,
      backgroundColor: Colors.transparent,
      contentColor: Colors.transparent,
      buttonBarColor: AppThemes.currentTheme.backgroundColor,
    );
  }

  void uploadGender(int sex) {
    final js = <String, dynamic>{};
    js[Keys.request] = Keys.adminCommand;
    js[Keys.requesterId] = user.userId;
    js[Keys.subRequest] = 'UpdateProfileSex';
    js[Keys.forUserId] = pupilModel.userId;
    js[Keys.sex] = sex;

    commonRequester.requestPath = RequestPath.SetData;
    commonRequester.bodyJson = js;

    commonRequester.httpRequestEvents.onAnyState = (req) async {
      await state.hideLoading();
    };

    commonRequester.httpRequestEvents.onNetworkError = (req) async {
      SnackCenter.showSnack$errorCommunicatingServer(state.context);
    };

    commonRequester.httpRequestEvents.onResponseError = (req, isOk) async {
      if(isOk) {
        SnackCenter.showSnack$errorInServerSide(state.context);
      } else {
        SnackCenter.showSnack$errorCommunicatingServer(state.context);
      }
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      return false;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      pupilModel.sexInt = sex;
      AppNavigator.pop(state.context);

      state.stateController.updateMain();
    };

    state.showLoading();
    commonRequester.request(state.context);
  }

  void uploadBirthDate(DateTime ageTs) {
    final js = <String, dynamic>{};
    js[Keys.request] = Keys.adminCommand;
    js[Keys.requesterId] = user.userId;
    js[Keys.subRequest] = 'UpdateProfileBirthDate';
    js[Keys.forUserId] = pupilModel.userId;
    js['birthdate'] = DateHelper.dateOnlyToStamp(ageTs);

    commonRequester.requestPath = RequestPath.SetData;
    commonRequester.bodyJson = js;

    commonRequester.httpRequestEvents.onAnyState = (req) async {
      await state.hideLoading();
    };

    commonRequester.httpRequestEvents.onNetworkError = (req) async {
      SnackCenter.showSnack$errorCommunicatingServer(state.context);
    };

    commonRequester.httpRequestEvents.onResponseError = (req, isOk) async {
      if(isOk) {
        SnackCenter.showSnack$errorInServerSide(state.context);
      } else {
        SnackCenter.showSnack$errorCommunicatingServer(state.context);
      }
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      return false;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      pupilModel.birthDateStr = DateHelper.dateOnlyToStamp(ageTs);
      pupilModel.birthDate = ageTs;

      AppNavigator.pop(state.context);

      state.stateController.updateMain();
    };

    state.showLoading();
    commonRequester.request(state.context);
  }

  void blockUser(){
    final js = <String, dynamic>{};
    js[Keys.request] = Keys.adminCommand;
    js[Keys.requesterId] = user.userId;
    js[Keys.subRequest] = 'SetUserBlockingState';
    js[Keys.forUserId] = pupilModel.userId;
    js[Keys.state] = !pupilModel.isBlocked;

    commonRequester.requestPath = RequestPath.SetData;
    commonRequester.bodyJson = js;

    commonRequester.httpRequestEvents.onAnyState = (req) async {
      await state.hideLoading();
    };

    commonRequester.httpRequestEvents.onNetworkError = (req) async {
      SnackCenter.showSnack$errorCommunicatingServer(state.context);
    };

    commonRequester.httpRequestEvents.onResponseError = (req, isOk) async {
      if(isOk) {
        SnackCenter.showSnack$errorInServerSide(state.context);
      } else {
        SnackCenter.showSnack$errorCommunicatingServer(state.context);
      }
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      return false;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      pupilModel.isBlocked = !pupilModel.isBlocked;

      state.stateController.updateMain();
    };

    state.showLoading();
    commonRequester.request(state.context);
  }

  void uploadTrainerState(bool isExercise, bool isFood){
    final js = <String, dynamic>{};
    js[Keys.request] = Keys.adminCommand;
    js[Keys.requesterId] = user.userId;
    js[Keys.subRequest] = 'SetTrainerState';
    js[Keys.forUserId] = pupilModel.userId;
    js['is_exercise'] = isExercise;
    js['is_food'] = isFood;

    commonRequester.requestPath = RequestPath.SetData;
    commonRequester.bodyJson = js;

    commonRequester.httpRequestEvents.onAnyState = (req) async {
      await state.hideLoading();
    };

    commonRequester.httpRequestEvents.onNetworkError = (req) async {
      SnackCenter.showSnack$errorCommunicatingServer(state.context);
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      return true;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      pupilModel.isExerciseTrainer = isExercise;
      pupilModel.isFoodTrainer = isFood;

      AppNavigator.pop(state.context);
      state.stateController.updateMain();
    };

    state.showLoading();
    commonRequester.request(state.context);
  }

  void uploadBroadcastCourseState(bool isBroadcastCourse){
    final js = <String, dynamic>{};
    js[Keys.request] = Keys.adminCommand;
    js[Keys.requesterId] = user.userId;
    js[Keys.subRequest] = 'SetTrainerBroadcastCourseState';
    js[Keys.forUserId] = pupilModel.userId;
    js['is_broadcast_course'] = isBroadcastCourse;

    commonRequester.requestPath = RequestPath.SetData;
    commonRequester.bodyJson = js;

    commonRequester.httpRequestEvents.onAnyState = (req) async {
      await state.hideLoading();
    };

    commonRequester.httpRequestEvents.onNetworkError = (req) async {
      SnackCenter.showSnack$errorCommunicatingServer(state.context);
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      return true;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      pupilModel.broadcastCourse = isBroadcastCourse;

      AppNavigator.pop(state.context);
      state.stateController.updateMain();
    };

    state.showLoading();
    commonRequester.request(state.context);
  }
}
