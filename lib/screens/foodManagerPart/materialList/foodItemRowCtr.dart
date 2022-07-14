import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/focusHelper.dart';

import '/abstracts/viewController.dart';
import '/models/dataModels/foodModels/materialModel.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/screens/commons/inputFieldScreen.dart';
import '/screens/foodManagerPart/editMaterial/editPropertiesScreen.dart';
import '/screens/foodManagerPart/editMaterial/editSameWordsScreen.dart';
import '/screens/foodManagerPart/materialList/foodItemRow.dart';
import '/system/httpCodes.dart';
import '/system/icons.dart';
import '/system/keys.dart';
import '/system/requester.dart';
import '/tools/app/appNavigator.dart';
import '/tools/centers/dialogCenter.dart';
import '/tools/centers/httpCenter.dart';
import '/tools/centers/sheetCenter.dart';
import '/tools/centers/snackCenter.dart';

class FoodItemRowCtr implements ViewController {
  late FoodItemRowState state;
  Requester? updateTitleRequester;
  Requester? deleteMaterialRequester;
  Requester? changeShowStateRequester;
  late UserModel userAdmin;
  late MaterialModel materialModel;


  @override
  void onInitState<E extends State>(E state){
    this.state = state as FoodItemRowState;

    state.widget.parentState.controller.rowViewList.add(state);
    materialModel = state.widget.foodModel;
    userAdmin = state.widget.parentState.controller.user!;

    updateTitleRequester = Requester();
    updateTitleRequester?.requestPath = RequestPath.SetData;

    changeShowStateRequester = Requester();
    changeShowStateRequester?.requestPath = RequestPath.SetData;

    deleteMaterialRequester = Requester();
    deleteMaterialRequester?.requestPath = RequestPath.SetData;
  }

  @override
  void onBuild(){
  }

  @override
  void onDispose(){
    HttpCenter.cancelAndClose(updateTitleRequester?.httpRequester);
    HttpCenter.cancelAndClose(deleteMaterialRequester?.httpRequester);
    HttpCenter.cancelAndClose(changeShowStateRequester?.httpRequester);
    state.widget.parentState.controller.rowViewList.remove(state);
  }
  ///========================================================================================================
  void showEditMenu(){
    /*SheetCenter.showModalSheet(state.context,
      content,
      routeName: 'EditMenu',
      backgroundColor: AppThemes.currentTheme.backgroundColor,
      isDismissible: true,
    );*/

    var wList = <Map>[];
    wList.add({'title': '${state.t('edit', key2: 'title')}',
      'icon': IconList.pencil,
      'fn': (){showEditTitleScreen();}});

    wList.add({'title': '${state.tInMap('foodProgramScreen','editSameWords')}',
      'icon': IconList.pencil,
      'fn': (){showEditSameWords();}});

    wList.add({'title': '${state.tInMap('foodProgramScreen','editProperties')}',
      'icon': IconList.pencil,
      'fn': (){showEditProps();}});

    wList.add({'title': '${materialModel.canShow? state.t('temporaryStorage'): state.t('show')}',
      'icon': IconList.flag,
      'fn': (){changeShowState();}});

    wList.add({'title': '${state.t('delete')}',
      'icon': IconList.delete,
      'fn': (){
        yesFn(){
          AppNavigator.pop(state.context);
          deleteFood();
        }

        DialogCenter().showYesNoDialog(state.context,
            yesFn: yesFn,
            desc: state.t('wantToDeleteThisItem'));
      }
    });


    Widget genView(elm){
     return ListTile(
       title: Text(elm['title']),
       leading: Icon(elm['icon']),
       onTap: (){
         SheetCenter.closeSheetByName(state.context, 'EditMenu');
         elm['fn']?.call();
       },
     );
    }

    SheetCenter.showSheetMenu(state.context,
        wList.map(genView).toList(),
        'EditMenu');
  }

  void showEditTitleScreen(){
    TextEditingController nameCtr = TextEditingController();
    nameCtr.text = materialModel.matchTitle?? materialModel.orgTitle;

    var content = InputFieldScreen(
      buttonClick: uploadTitle,
      editingController: nameCtr,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      hint: state.t('title'),
      buttonText: state.tC('apply'),
      title: state.tC('title'),
    );

    AppNavigator.pushNextPage(
        state.context, content, name: InputFieldScreen.screenName).then((value) {
      if(value != null){
        state.update();
        SnackCenter.showSnack$successOperation(state.context);
      }
    });
  }

  void showEditSameWords(){
    var content = EditSameWordsScreen(materialModel);

    AppNavigator.pushNextPage(
        state.context, content, name: EditSameWordsScreen.screenName).then((value) {
      if(value != null){
        state.update();
        SnackCenter.showSnack$successOperation(state.context);
      }
    });
  }

  void showEditProps(){
    var content = EditPropertiesScreen(materialModel);

    AppNavigator.pushNextPage(
        state.context,
        content,
        name: EditPropertiesScreen.screenName
    )
        .then((value) {
          if(value != null){
            state.update();
            SnackCenter.showSnack$successOperation(state.context);
          }
        });
  }

  void changeShowState() {
    FocusHelper.hideKeyboardByUnFocus(state.context);

    Map<String, dynamic> js = {};
    js[Keys.request] = Keys.adminCommand;
    js[Keys.requesterId] = userAdmin.userId;
    js[Keys.subRequest] = 'UpdateFoodMaterialShowState';
    js['id'] = materialModel.id;
    js[Keys.state] = !materialModel.canShow;

    changeShowStateRequester?.bodyJson = js;

    changeShowStateRequester?.httpRequestEvents.onNetworkError = (req) async {
      await state.hideLoading();
      SheetCenter.showSheet$ErrorCommunicatingServer(state.context);
    };

    changeShowStateRequester?.httpRequestEvents.onResponseError = (req, isOk) async {
      await state.hideLoading();
      SheetCenter.showSheet$ServerNotRespondProperly(state.context);
    };

    changeShowStateRequester?.httpRequestEvents.onResultError = (req, data) async {
      await state.hideLoading();

      int causeCode = data[Keys.causeCode] ?? 0;

      if(causeCode == HttpCodes.error_operationCannotBePerformed){
        SheetCenter.showSheetOk(state.context, '${state.t('operationCannotBePerformed')}');
      }
      else {
        SheetCenter.showSheet$ServerNotRespondProperly(state.context);
      }

      return true;
    };

    changeShowStateRequester?.httpRequestEvents.onResultOk = (req, data) async {
      await state.hideLoading();

      materialModel.canShow = !materialModel.canShow;
      state.update();
    };

    state.showLoading(canBack: false);
    changeShowStateRequester?.request(state.context);
  }

  void deleteFood() {
    FocusHelper.hideKeyboardByUnFocus(state.context);

    final js = <String, dynamic>{};
    js[Keys.request] = Keys.adminCommand;
    js[Keys.subRequest] = 'DeleteFoodMaterial';
    js[Keys.requesterId] = userAdmin.userId;
    js['id'] = materialModel.id;

    deleteMaterialRequester?.bodyJson = js;

    deleteMaterialRequester?.httpRequestEvents.onAnyState = (req) async {
      await state.hideLoading();
    };

    deleteMaterialRequester?.httpRequestEvents.onResponseError = (req, isOk) async {
      SheetCenter.showSheet$ServerNotRespondProperly(state.context);
    };

    deleteMaterialRequester?.httpRequestEvents.onResultError = (req, data) async {
      final int causeCode = data[Keys.causeCode] ?? 0;
      //final String cause = data[Keys.cause] ?? Keys.error;

      if(causeCode == HttpCodes.error_operationCannotBePerformed){
        SheetCenter.showSheetNotice(state.context, state.tInMap('foodProgramScreen', 'canNotDeleteThisMaterial')!);

        return true;
      }

      return false;
    };

    deleteMaterialRequester?.httpRequestEvents.onResultOk = (req, data) async {
      state.widget.parentState.controller.foodMaterialList.removeWhere((elm) => elm.id == materialModel.id);
      state.widget.parentState.controller.rowViewList.remove(state);

      state.widget.parentState.stateController.updateMain();
    };

    state.showLoading(canBack: false);
    deleteMaterialRequester?.request(state.context);
  }

  void uploadTitle(String title) {
    FocusHelper.hideKeyboardByUnFocus(state.context);

    if(title.isEmpty){
      SheetCenter.showSheetOk(state.context, state.tC('enterTitle')!);
      return;
    }

    Map<String, dynamic> js = {};
    js[Keys.request] = Keys.adminCommand;
    js[Keys.requesterId] = userAdmin.userId;
    js[Keys.forUserId] = userAdmin.userId;
    js[Keys.subRequest] = 'UpdateFoodMaterialTitle';
    js['id'] =  materialModel.id;
    js[Keys.title] = title;

    updateTitleRequester?.bodyJson = js;

    updateTitleRequester?.httpRequestEvents.onNetworkError = (req) async {
      await state.hideLoading();
      SheetCenter.showSheet$ErrorCommunicatingServer(state.context);
    };

    updateTitleRequester?.httpRequestEvents.onResponseError = (req, isOk) async {
      await state.hideLoading();
      SheetCenter.showSheet$ServerNotRespondProperly(state.context);
    };

    updateTitleRequester?.httpRequestEvents.onResultError = (req, data) async {
      await state.hideLoading();

      int causeCode = data[Keys.causeCode] ?? 0;

      if(causeCode == HttpCodes.error_existThis){
        SheetCenter.showSheetOk(state.context, '${state.t('thereIsThisCase')}');
      }
      else {
        SheetCenter.showSheet$ServerNotRespondProperly(state.context);
      }

      return true;
    };

    updateTitleRequester?.httpRequestEvents.onResultOk = (req, data) async {
      await state.hideLoading();

      materialModel.orgTitle = data[Keys.title];
      materialModel.orgLanguage = data['language'];
      materialModel.translateJs = data['translates']?? {};
      materialModel.findMatchTitle();

      AppNavigator.pop(state.context, result: true);
    };

    state.showLoading(canBack: false);
    updateTitleRequester?.request(state.context);
  }
}
