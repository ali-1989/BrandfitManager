// ignore_for_file: unawaited_futures

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:iris_pic_editor/pic_editor.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/features/overlayDialog.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';
import 'package:permission_handler/permission_handler.dart';

import '/abstracts/viewController.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/screens/advertisingPart/addAdvertising/addNewAdvertising.dart';
import '/system/enums.dart';
import '/system/keys.dart';
import '/system/requester.dart';
import '/system/session.dart';
import '/tools/app/appManager.dart';
import '/tools/app/appNavigator.dart';
import '/tools/app/appThemes.dart';
import '/tools/centers/dialogCenter.dart';
import '/tools/centers/directoriesCenter.dart';
import '/tools/centers/httpCenter.dart';
import '/tools/centers/sheetCenter.dart';
import '/tools/permissionTools.dart';
import '/tools/widgetTools.dart';

class AddNewAdvertisingScreenCtr implements ViewController {
  late AddNewAdvertisingScreenState state;
  Requester? addNewRequester;
  late UserModel? userAdmin;
  late TextEditingController searchEditController;
  String? photoPath;
  bool showToUser$op = true;
  DateTime? startShow$op;
  String startShowText = '';
  DateTime? finishShow$op;
  String finishShowText = '';
  Map<String, String> typeMap = {};
  List<String> typeTranslates = [];
  int selectedType = 0;
  TextEditingController titleCtr = TextEditingController();
  TextEditingController tagCtr = TextEditingController();
  TextEditingController orderCtr = TextEditingController();
  TextEditingController linkCtr = TextEditingController();


  @override
  void onInitState<E extends State>(E state){
    this.state = state as AddNewAdvertisingScreenState;

    userAdmin = Session.getLastLoginUser();
    addNewRequester = Requester();
    addNewRequester!.requestPath = RequestPath.SetData;

    typeMap = state.tAsStringMap('addAdvertisingPage', 'types')!;
    typeTranslates.addAll(typeMap.values);
  }

  @override
  void onBuild(){
  }

  @override
  void onDispose(){
    HttpCenter.cancelAndClose(addNewRequester?.httpRequester);
  }
  ///========================================================================================================
  void tryAgain(State state){
    if(state is AddNewAdvertisingScreenState) {
      state.stateController.mainStateAndUpdate(StateXController.state$loading);

      requestAddAdvertising();
    }
  }

  void deleteDialog(){
    final desc = state.tC('wantToDeleteThisItem')!;

    void yesFn(){
      photoPath = null;
      state.stateController.updateMain();
    }

    DialogCenter().showYesNoDialog(state.context, desc: desc, yesFn: yesFn,);
  }

  void addPhoto(){
    final Widget view = SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          const SizedBox(height: 10,),

          ElevatedButton(
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(const Size(200, 50)),
                shape: MaterialStateProperty.all(ShapeList.stadiumBorder$Outlined),
                foregroundColor: MaterialStateProperty.all(AppThemes.currentTheme.buttonTextColorOnPrimary),
                backgroundColor: MaterialStateProperty.all(AppThemes.currentTheme.buttonBackColorOnPrimary),
              ),
              onPressed: (){
                SheetCenter.closeSheetByName(state.context, 'ChoosePhotoSource');

                PermissionTools.requestCameraStoragePermissions().then((value) {
                  if(value == PermissionStatus.granted){
                    ImagePicker().pickImage(source: ImageSource.camera).then((value) {
                      if(value == null) {
                        return;
                      }

                      editImage(value.path);
                    });
                  }
                });
              },
              child: Text('${state.tC('camera')}')
          ),

          const SizedBox(height: 16,),
          ElevatedButton(
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(const Size(200, 50)),
                shape: MaterialStateProperty.all(ShapeList.stadiumBorder$Outlined),
                foregroundColor: MaterialStateProperty.all(AppThemes.currentTheme.buttonTextColorOnPrimary),
                backgroundColor: MaterialStateProperty.all(AppThemes.currentTheme.buttonBackColorOnPrimary),
              ),
              onPressed: (){
                SheetCenter.closeSheetByName(state.context, 'ChoosePhotoSource');

                PermissionTools.requestStoragePermission().then((value) {
                  if(value == PermissionStatus.granted){
                    ImagePicker().pickImage(source: ImageSource.gallery).then((value) {
                      if(value == null) {
                        return;
                      }

                      editImage(value.path);
                    });
                  }
                });
              },
              child: Text('${state.tC('gallery')}')
          ),

          const SizedBox(height: 10,),
        ],
      ),
    );

    SheetCenter.showSheetCustom(state.context, view, routeName: 'ChoosePhotoSource');
  }

  void afterEdit(String filePath){
    photoPath = filePath;
    state.stateController.updateMain();
    //SheetCenter.showSnack$successOperation(state.context);
  }

  void editImage(String imgPath){
    final editOptions = EditOptions.byPath(imgPath);
    editOptions.cropBoxInitSize = const Size(200, 170);

    void onOk(EditOptions op) async {
      final pat = DirectoriesCenter.getSavePathByPath(SavePathType.ADVERTISING, imgPath)!;

      FileHelper.createNewFileSync(pat);
      FileHelper.writeBytesSync(pat, editOptions.imageBytes!);

      afterEdit(pat);
    }

    editOptions.callOnResult = onOk;
    final ov = OverlayScreenView(content: PicEditor(editOptions), backgroundColor: Colors.black);
    OverlayDialog().show(state.context, ov);
  }

  void tickBtn() {
    if(photoPath == null){
      SheetCenter.showSheetOk(state.context, state.t('mustSelectImageFirst')!);
      return;
    }

    if(startShow$op != null && finishShow$op != null){
      if(startShow$op!.isAfter(finishShow$op!)) {
        SheetCenter.showSheetOk(state.context, state.t('orderOfDatesIsIncorrect')!);
        return;
      }
    }

    requestAddAdvertising();
  }

  void requestAddAdvertising() {
    FocusHelper.hideKeyboardByUnFocus(state.context);

    final partName = 'AdvertisingImage';
    final fileName = FileHelper.getFileName(photoPath!);

    final title = titleCtr.text.trim();
    final tag = tagCtr.text.trim();
    final orderNum = orderCtr.text.trim();
    final link = linkCtr.text.trim();

    final js = <String, dynamic>{};
    js[Keys.request] = 'AddAdvertising';
    js[Keys.requesterId] = userAdmin!.userId;
    js[Keys.title] = title.isEmpty? null: title;
    js[Keys.type] = typeMap.entries.firstWhere((element) => element.value == typeTranslates[selectedType]).key;
    js['tag'] = tag.isEmpty? null: tag;
    js['start_date'] = startShow$op == null? null: DateHelper.localToUtcTs(startShow$op!);
    js['finish_date'] =  finishShow$op == null? null: DateHelper.localToUtcTs(finishShow$op!);
    js['can_show'] = showToUser$op;
    js['order_num'] = orderNum.isEmpty? null: orderNum;
    js['link'] = link.isEmpty? null: link;
    js[Keys.partName] = partName;
    js[Keys.fileName] = fileName;

    AppManager.addAppInfo(js);

    addNewRequester?.httpItem.addBodyField(Keys.jsonHttpPart, JsonHelper.mapToJson(js));
    addNewRequester?.httpItem.addBodyFile(partName, fileName, FileHelper.getFile(photoPath!));


    addNewRequester?.httpRequestEvents.onAnyState = (req) async {
      await state.hideLoading();
    };

    addNewRequester?.httpRequestEvents.onNetworkError = (req) async {
      SheetCenter.showSheet$ErrorCommunicatingServer(state.context);
    };

    addNewRequester?.httpRequestEvents.onResponseError = (req, isOk) async {
      if(isOk){
        SheetCenter.showSheet$ErrorInServerSide(state.context);
      }
      else {
        SheetCenter.showSheet$ErrorCommunicatingServer(state.context);
      }
    };

    addNewRequester?.httpRequestEvents.onResultError = (req, data) async {
      return false;
    };

    addNewRequester?.httpRequestEvents.onResultOk = (req, data) async {
      SheetCenter.showSheet$SuccessOperation(state.context).then((value) {
        Future.delayed(const Duration(milliseconds: 500), (){
          AppNavigator.pop(state.context, result: Keys.ok);
        });
      });
    };

    state.showLoading();
    addNewRequester!.request(state.context);
  }
}
