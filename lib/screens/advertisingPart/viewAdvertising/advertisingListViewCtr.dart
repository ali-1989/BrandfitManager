import 'package:flutter/material.dart';

import 'package:iris_pic_editor/pic_editor.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/helpers/pathHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/features/overlayDialog.dart';

import '/abstracts/viewController.dart';
import '/models/dataModels/advertisingModel.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/screens/advertisingPart/advertisingScreen.dart';
import '/screens/advertisingPart/viewAdvertising/advertisingListView.dart';
import '/system/enums.dart';
import '/system/keys.dart';
import '/system/requester.dart';
import '/system/session.dart';
import '/tools/app/appManager.dart';
import '/tools/app/appNavigator.dart';
import '/tools/centers/dialogCenter.dart';
import '/tools/centers/directoriesCenter.dart';
import '/tools/centers/httpCenter.dart';
import '/tools/centers/sheetCenter.dart';
import '/tools/centers/snackCenter.dart';

class AdvertisingListViewCtr implements ViewController {
  late AdvertisingListViewState state;
  late Requester commonRequester;
  UserModel? userAdmin;
  late AdvertisingScreenState parentState;
  late AdvertisingModel model;
  Map<String, String> typeMap = {};


  @override
  void onInitState<E extends State>(E state){
    this.state = state as AdvertisingListViewState;

    commonRequester = Requester();
    commonRequester.requestPath = RequestPath.GetData;

    parentState = state.widget.parentState;
    model = state.widget.model;
    userAdmin = Session.getLastLoginUser();
    typeMap = state.tAsStringMap('addAdvertisingPage', 'types')!;

    parentState.controller.listChildren.add(state);
  }

  @override
  void onBuild(){
  }

  @override
  void onDispose(){
    parentState.controller.listChildren.remove(state);

    HttpCenter.cancelAndClose(commonRequester.httpRequester);
  }
  ///========================================================================================================
  void uploadLink(String link) {
    if(link.isEmpty){
      SheetCenter.showSheetOk(state.context, state.tC('pleaseFillOptions')!);
      return;
    }

    final js = <String, dynamic>{};
    js[Keys.request] = 'ChangeAdvertisingLink';
    js[Keys.userId] = userAdmin!.userId;
    js['link'] = link;
    js['advertising_id'] = model.id;

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
      }
      else {
        await SheetCenter.showSheet$ServerNotRespondProperly(state.context);
      }
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      return false;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      model.clickLink = link;

      AppNavigator.pop(state.context);
      //state.update();
    };

    state.showLoading();
    commonRequester.request(state.context);
  }

  void editImage(String imgPath){
    final editOptions = EditOptions.byPath(imgPath);
    editOptions.cropBoxInitSize = const Size(200, 170);

    void onOk(EditOptions op) async {
      final pat = DirectoriesCenter.getSavePathByPath(SavePathType.ADVERTISING, imgPath)!;

      FileHelper.createNewFileSync(pat);
      FileHelper.writeBytesSync(pat, editOptions.imageBytes!);

      uploadPhoto(pat);
    }

    editOptions.callOnResult = onOk;
    final ov = OverlayScreenView(content: PicEditor(editOptions), backgroundColor: Colors.black);
    OverlayDialog().show(state.context, ov);
  }

  void uploadTitle(String title) {
    if(title.isEmpty){
      SheetCenter.showSheetNotice(state.context, state.tC('pleaseFillOptions')!);
      return;
    }

    final js = <String, dynamic>{};
    js[Keys.request] = 'ChangeAdvertisingTitle';
    js[Keys.userId] = userAdmin!.userId;
    js[Keys.title] = title;
    js['advertising_id'] = model.id;

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
      }
      else {
        await SheetCenter.showSheet$ServerNotRespondProperly(state.context);
      }
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      return false;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      model.title = title;

      AppNavigator.pop(state.context);
      //state.update();
    };

    state.showLoading();
    commonRequester.request(state.context);
  }

  void uploadTag(String tag) {
    if(tag.isEmpty){
      SheetCenter.showSheetNotice(state.context, state.tC('pleaseFillOptions')!);
      return;
    }

    final js = <String, dynamic>{};
    js[Keys.request] = 'ChangeAdvertisingTag';
    js[Keys.userId] = userAdmin!.userId;
    js['tag'] = tag;
    js['advertising_id'] = model.id;

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
      }
      else {
        await SheetCenter.showSheet$ServerNotRespondProperly(state.context);
      }
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      return false;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      model.tag = tag;

      AppNavigator.pop(state.context);
      //state.update();
    };

    state.showLoading();
    commonRequester.request(state.context);
  }

  void changeShowState(){
    final js = <String, dynamic>{};
    js[Keys.request] = 'ChangeAdvertisingShowState';
    js[Keys.userId] = userAdmin!.userId;
    js[Keys.state] = !model.canShow;
    js['advertising_id'] = model.id;

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
      }
      else {
        await SheetCenter.showSheet$ServerNotRespondProperly(state.context);
      }
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      return false;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      model.canShow = !model.canShow;

      //AppNavigator.pop(state.context);
      state.update();
    };

    state.showLoading();
    commonRequester.request(state.context);
  }

  void deleteAdvertising(){
    final desc = state.tC('wantToDeleteThisItem')!;

    void yesFn(){
      Future((){
        requestDeleteAdv();
      });
    }

    DialogCenter().showYesNoDialog(state.context, desc: desc, yesFn: yesFn,);
  }

  void requestDeleteAdv() {
    final js = <String, dynamic>{};
    js[Keys.request] = 'DeleteAdvertising';
    js[Keys.userId] = userAdmin!.userId;
    js['advertising_id'] = model.id;

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
      }
      else {
        await SheetCenter.showSheet$ServerNotRespondProperly(state.context);
      }
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      return false;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      parentState.controller.advertisingList.remove(model);

      parentState.update();
      //state.update();
    };

    state.showLoading();
    commonRequester.request(state.context);
  }

  void uploadOrder(int order) {
    final js = <String, dynamic>{};
    js[Keys.request] = 'ChangeAdvertisingOrder';
    js[Keys.userId] = userAdmin!.userId;
    js['order_num'] = order;
    js['advertising_id'] = model.id;

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
      }
      else {
        await SheetCenter.showSheet$ServerNotRespondProperly(state.context);
      }
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      return false;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      model.orderNum = order;

      AppNavigator.pop(state.context);
      state.update();
    };

    state.showLoading();
    commonRequester.request(state.context);
  }

  void uploadType(String type) {
    if(type.isEmpty){
      SheetCenter.showSheetNotice(state.context, state.tC('pleaseFillOptions')!);
      return;
    }

    final js = <String, dynamic>{};
    js[Keys.request] = 'ChangeAdvertisingType';
    js[Keys.userId] = userAdmin!.userId;
    js[Keys.type] = type;
    js['advertising_id'] = model.id;

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
      }
      else {
        await SheetCenter.showSheet$ServerNotRespondProperly(state.context);
      }
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      return false;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      model.type = type;

      AppNavigator.pop(state.context);
      //state.update();
    };

    state.showLoading();
    commonRequester.request(state.context);
  }

  void uploadDate(DateTime? date, String section) {
    final js = <String, dynamic>{};
    //js[Keys.request] = Keys.adminCommand;
    js[Keys.request] = 'ChangeAdvertisingDate';
    //js[Keys.requesterId] = userAdmin.userId;
    //js[Keys.subRequest] = 'UpdateProfileNameFamily';
    js[Keys.userId] = userAdmin!.userId;
    js[Keys.section] = section;
    js[Keys.date] = date == null? null : DateHelper.localToUtcTs(date);
    js['advertising_id'] = model.id;

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
      }
      else {
        await SheetCenter.showSheet$ServerNotRespondProperly(state.context);
      }
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      return false;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      if(section == 'start_date') {
        model.startShowDate = date;
      }
      else {
        model.finishShowDate = date;
      }

      state.update();
    };

    state.showLoading();
    commonRequester.request(state.context);
  }

  void uploadPhoto(String filePath) {
    final partName = 'AdvertisingPhoto';
    final fileName = PathHelper.getFileName(filePath);

    final js = <String, dynamic>{};
    js[Keys.request] = 'ChangeAdvertisingPhoto';
    js[Keys.requesterId] = userAdmin!.userId;
    js['advertising_id'] = model.id;
    js[Keys.partName] = partName;
    js[Keys.fileName] = fileName;

    AppManager.addAppInfo(js);
    commonRequester.requestPath = RequestPath.SetData;
    commonRequester.httpItem.addBodyField(Keys.jsonHttpPart, JsonHelper.mapToJson(js));
    commonRequester.httpItem.addBodyFile(partName, fileName, FileHelper.getFile(filePath));

    commonRequester.httpRequestEvents.onAnyState = (req) async {
      await state.hideLoading();
    };

    commonRequester.httpRequestEvents.onNetworkError = (req) async {
      SnackCenter.showSnack$errorCommunicatingServer(state.context);
    };

    commonRequester.httpRequestEvents.onResponseError = (req, isOk) async {
      if(isOk) {
        SnackCenter.showSnack$errorInServerSide(state.context);
      }
      else {
        await SheetCenter.showSheet$ServerNotRespondProperly(state.context);
      }
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      return false;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      model.imagePath = filePath;
      model.advFile = FileHelper.getFile(filePath);
      model.imageUri = js[Keys.fileUri];

      //AppNavigator.pop(state.context);
      state.update();
    };

    state.showLoading();
    commonRequester.request(state.context);
  }
}
