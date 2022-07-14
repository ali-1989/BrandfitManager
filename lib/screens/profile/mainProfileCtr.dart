import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:iris_pic_editor/picEditor/models/edit_options.dart';
import 'package:iris_pic_editor/picEditor/picEditor.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/helpers/pathHelper.dart';
import 'package:iris_tools/features/overlayDialog.dart';
import 'package:iris_tools/widgets/attribute.dart';
import 'package:permission_handler/permission_handler.dart';

import '/abstracts/viewController.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/screens/commons/imageFullScreen.dart';
import '/screens/drawerMenu.dart';
import '/screens/profile/mainProfileScreen.dart';
import '/system/enums.dart';
import '/system/extensions.dart';
import '/system/keys.dart';
import '/system/requester.dart';
import '/system/session.dart';
import '/tools/app/appManager.dart';
import '/tools/app/appNavigator.dart';
import '/tools/app/appThemes.dart';
import '/tools/centers/directoriesCenter.dart';
import '/tools/centers/httpCenter.dart';
import '/tools/centers/sheetCenter.dart';
import '/tools/centers/snackCenter.dart';
import '/tools/permissionTools.dart';
import '/views/loadingScreen.dart';

class MainProfileCtr implements ViewController {
  late UserProfileScreenState state;
  late Requester commonRequester;
  late UserModel user;
  AttributeController popMenuAtt = AttributeController();
  double maxWidth = 0;
  bool isLoadingShow = false;


  @override
  void onInitState<E extends State>(E state){
    this.state = state as UserProfileScreenState;

    commonRequester = Requester();

    user = Session.getLastLoginUser()!;
    DrawerMenuTool.prepareAvatar(user);

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
    if(state is UserProfileScreenState) {
    }
  }

  void showAvatarPic(){
    final view = OverlayScreenView(
      content: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          //OverlayCenter().hideByName(context, 'ProfileAvatarFullScreen');
        },
        child: SizedBox.expand(
          child: ImageFullScreen(
            heroTag: 'profileHero',
            imageType: ImageType.File,
            imageObj: FileHelper.getFile(user.profilePath!),
          ),
        ),
      ),
      routingName: 'ProfileAvatarFullScreen',
    );

    AppNavigator.pushNextPageExtra(state.context, view, name: 'ProfileAvatarFullScreen');
  }

  void showAvatarMenu(){
    final view = OverlayScreenView(
      content: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          OverlayDialog().hideByName(state.context, 'MenuForProfileAvatar');
        },
        child: SizedBox.expand(
          //child: Center(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.directional(
                textDirection: AppThemes.textDirection,
                top: popMenuAtt.getPositionY(),
                start: popMenuAtt.getPositionX(),
                end: 0,
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  borderOnForeground: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text(state.tC('camera')!),
                        leading: const Icon(Icons.camera_alt),
                        onTap: (){callCamera();},
                      ),

                      ListTile(
                        title: Text(state.tC('gallery')!),
                        leading: const Icon(Icons.image),
                        onTap: (){callGallery();},
                      ),

                      if(user.isSetProfileImage)
                        ListTile(
                          title: Text(state.tC('delete')!),
                          leading: const Icon(Icons.delete_forever),
                          onTap: (){deleteProfile();},
                        ),
                    ],
                  ).wrapListTileTheme(),
                ),
              ),
            ],
          ),
        ),
      ),
      routingName: 'MenuForProfileAvatar',
    );

    OverlayDialog().show(state.context, view).then((value) => null);
  }

  void callCamera(){
    OverlayDialog().hideByName(state.context, 'MenuForProfileAvatar');

    PermissionTools.requestCameraStoragePermissions().then((value) {
      if(value == PermissionStatus.granted) {
        ImagePicker().pickImage(source: ImageSource.camera).then((value) {
          if(value == null) {
            return;
          }

          editImage(value.path);
        });
      }
    });
  }

  void callGallery(){
    OverlayDialog().hideByName(state.context, 'MenuForProfileAvatar');

    PermissionTools.requestStoragePermission().then((value) {
      if(value == PermissionStatus.granted) {
        ImagePicker().pickImage(source: ImageSource.gallery).then((value) {
          if(value == null) {
            return;
          }

          editImage(value.path);
        });
      }
    });
  }

  void afterUpload(String imgPath, Map map){
    final String? uri = map[Keys.fileUri];

    if(uri == null){
      return;
    }

    final newName = PathHelper.getFileName(uri);
    final newFileAddress = PathHelper.getParentDirPath(imgPath) + PathHelper.getSeparator() + newName;

    final f = FileHelper.renameSyncSafe(imgPath, newFileAddress);

    user.profileUri = uri;
    user.profilePath = f.path;

    state.stateController.updateMain();
    Session.sinkUserInfo(user);

    //after load image, auto will call: OverlayCenter().hideLoading(context);
    SnackCenter.showSnack$successOperation(state.context);
  }

  void editImage(String imgPath){
    final editOptions = EditOptions.byPath(imgPath);
    editOptions.cropBoxInitSize = const Size(200, 170);

    void onOk(EditOptions op) async {
      final pat = DirectoriesCenter.getSavePathByPath(SavePathType.USER_PROFILE, imgPath)!;

      FileHelper.createNewFileSync(pat);
      FileHelper.writeBytesSync(pat, editOptions.imageBytes!);

      uploadAvatar(pat, afterUpload);
    }

    editOptions.callOnResult = onOk;
    final ov = OverlayScreenView(content: PicEditor(editOptions), backgroundColor: Colors.black);
    OverlayDialog().show(state.context, ov);
  }

  void uploadAvatar(String filePath, Function onSuccess) {
    final partName = 'ProfileAvatar';
    final fileName = PathHelper.getFileName(filePath);

    final js = <String, dynamic>{};
    js[Keys.request] = 'UpdateProfileAvatar';
    js[Keys.userId] = user.userId;
    js[Keys.fileName] = fileName;
    js[Keys.partName] = partName;
    AppManager.addAppInfo(js);

    commonRequester.requestPath = RequestPath.SetData;
    commonRequester.bodyJson = null;
    commonRequester.httpItem.addBodyField(Keys.jsonHttpPart, JsonHelper.mapToJson(js));
    commonRequester.httpItem.addBodyFile(partName, fileName, File(filePath));

    commonRequester.httpRequestEvents.onNetworkError = (req) async {
      await LoadingScreen.hideLoading(state.context);
      SnackCenter.showSnack$errorCommunicatingServer(state.context);
    };

    commonRequester.httpRequestEvents.onResponseError = (req, isOk) async {
      await LoadingScreen.hideLoading(state.context);

      if(isOk){
        SnackCenter.showSnack$errorInServerSide(state.context);
      }
      else {
        // ignore: unawaited_futures
        SheetCenter.showSheet$ServerNotRespondProperly(state.context);
      }
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      await LoadingScreen.hideLoading(state.context);
      return false;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      isLoadingShow = true;
      onSuccess(filePath, data);
    };

    LoadingScreen.showLoading(state.context, canBack: false);
    commonRequester.request(state.context);
  }

  void deleteProfile(){
    OverlayDialog().hideByName(state.context, 'MenuForProfileAvatar');

    final js = <String, dynamic>{};
    js[Keys.request] = 'DeleteProfileAvatar';
    js[Keys.userId] = user.userId;

    commonRequester.bodyJson = js;
    commonRequester.requestPath = RequestPath.SetData;

    commonRequester.httpRequestEvents.onNetworkError = (req) async {
      await LoadingScreen.hideLoading(state.context);
      SnackCenter.showSnack$errorCommunicatingServer(state.context);
    };

    commonRequester.httpRequestEvents.onAnyState = (req) async {
      await LoadingScreen.hideLoading(state.context);
    };

    commonRequester.httpRequestEvents.onResponseError = (req, isOk) async {
      if(isOk){
        SnackCenter.showSnack$errorInServerSide(state.context);
      }
      else {
        // ignore: unawaited_futures
        SheetCenter.showSheet$ServerNotRespondProperly(state.context);
      }
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      return false;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      user.profilePath = null;
      user.profileUri = null;
      user.profileProvider = null;

      state.stateController.updateMain();
    };

    LoadingScreen.showLoading(state.context, canBack: false);
    commonRequester.request(state.context);
  }
}
