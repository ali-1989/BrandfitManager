import 'package:flutter/material.dart';

import '/abstracts/viewController.dart';
import '/models/dataModels/courseModels/courseModel.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/screens/commons/imageFullScreen.dart';
import '/screens/courseManagementPart/fullInfoPart/courseFullInfoScreen.dart';
import '/system/enums.dart';
import '/system/requester.dart';
import '/system/session.dart';
import '/tools/app/appNavigator.dart';
import '/tools/centers/httpCenter.dart';

class CourseFullInfoCtr implements ViewController {
  late CourseFullInfoScreenState state;
  late UserModel user;
  late CourseModel courseModel;
  late Requester commonRequester;

  @override
  void onInitState<E extends State>(E state){
    this.state = state as CourseFullInfoScreenState;

    commonRequester = Requester();
    commonRequester.requestPath = RequestPath.GetData;

    courseModel = state.widget.courseModel;

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

  void showFullScreenImage(){
    if(courseModel.imageUri == null){
      return;
    }

    final view = ImageFullScreen(
      imageType: ImageType.File,
      heroTag: 'h${courseModel.id}',
      imageObj: courseModel.imagePath,
    );

    AppNavigator.pushNextPageExtra(state.context, view, name: ImageFullScreen.screenName);
  }
}
