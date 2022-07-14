import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '/abstracts/viewController.dart';
import '/models/dataModels/courseModels/courseModel.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/screens/courseManagementPart/fullInfoPart/courseFullInfoScreen.dart';
import '/screens/courseManagementPart/withoutSet/managementWithoutSetScreen.dart';
import '/system/keys.dart';
import '/system/requester.dart';
import '/tools/app/appNavigator.dart';
import '/tools/centers/httpCenter.dart';
import '/tools/centers/infoDisplayCenter.dart';
import '/tools/centers/snackCenter.dart';

class ItemListViewCtr implements ViewController {
  late ItemListViewState state;
  Requester? commonRequester;
  late CourseModel model;
  late UserModel userAdmin;


  @override
  void onInitState<E extends State>(E state){
    this.state = state as ItemListViewState;

    commonRequester = Requester();
    commonRequester?.requestPath = RequestPath.GetData;

    state.widget.stateList.add(state);
    model = state.widget.model;
    userAdmin = state.widget.user;
  }

  @override
  void onBuild(){
  }

  @override
  void onDispose(){
    state.widget.stateList.remove(state);
    HttpCenter.cancelAndClose(commonRequester?.httpRequester);
  }
  ///========================================================================================================
  void gotoFullInfo(){
    AppNavigator.pushNextPage(
        state.context,
        CourseFullInfoScreen(courseModel: model,),
        name: CourseFullInfoScreen.screenName);
  }

  void showInfo(){
    InfoDisplayCenter.showMiniInfo(state.context,
        Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            textDirection: TextDirection.ltr,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('id: ${model.id}'),
              Text('user: ${model.creatorUserName}'),
              Text('userId: ${model.creatorUserId}'),
              Text('date: ${model.creationDate}'),
              Text('price: ${model.price}'),
              Row(
                children: [
                  Text('currency: ${model.currencyModel.currencyName}'),
                  Text(', ${model.currencyModel.currencyCode}'),
                  Text(', ${model.currencyModel.countryIso}'),
                ],
              ),
            ],
          ),
        ),
        center: true
    );
  }

  void blockUnblock() {
    Map<String, dynamic> js = {};
    js[Keys.request] = Keys.adminCommand;
    js[Keys.requesterId] = userAdmin.userId;
    js[Keys.subRequest] = 'ChangeCourseBlockState';
    js['course_id'] = model.id;
    js[Keys.state] = !model.isBlock;

    commonRequester?.requestPath = RequestPath.SetData;
    commonRequester?.bodyJson = js;

    commonRequester?.httpRequestEvents.onAnyState = (req) async {
      await state.hideLoading();
    };

    commonRequester?.httpRequestEvents.onNetworkError = (req) async {
      SnackCenter.showSnack$errorCommunicatingServer(state.context);
    };

    commonRequester?.httpRequestEvents.onResponseError = (req, isOk) async {
      if(isOk) {
        SnackCenter.showSnack$errorInServerSide(state.context);
      } else {
        SnackCenter.showSnack$errorCommunicatingServer(state.context);
      }
    };

    commonRequester?.httpRequestEvents.onResultError = (req, data) async {
      return false;
    };

    commonRequester?.httpRequestEvents.onResultOk = (req, data) async {
      model.isBlock = !model.isBlock;

      state.update();
    };

    state.showLoading();
    commonRequester?.request(state.context);
  }

  void downloadImage(){
    /*if(model.imageUri == null){
      if(model.imageUri != null){

        if(model.imagePath == null) {
          model.imagePath =
              PublicAccess.getSavePath(model.imageUri, SavePathType.COURSE_PHOTO);
        }

        PermissionTools.requestStoragePermission().then((permission){
          if (permission != PermissionStatus.granted){
            return;
          }

          var f = FileHelper.getFile(model.imagePath!);

          f.exists().then((exist){
            if(exist){
              model.imagePath = f.path;
              //update();
            }
            else {
              var item = DownloadUpload.downloadManager
                  .createDownloadItem(model.imageUri!, model.imagePath!);
              item.category = DownloadCategory.USER_PROFILE.toString();
              item.subCategory = model.id.toString();
              item.attach = model;

              DownloadUpload.downloadManager.enqueue(item);
            }
          });
        });
      }
    }*/
  }
}
