import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/tools.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';

import '/abstracts/viewController.dart';
import '/models/dataModels/foodModels/materialFundamentalModel.dart';
import '/models/dataModels/foodModels/materialMeasureModel.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/models/holderModels/fundamentalHolder.dart';
import '/screens/commons/topInputFieldScreen.dart';
import '/screens/foodManagerPart/addMaterial/AddMaterialScreen.dart';
import '/system/extensions.dart';
import '/system/httpCodes.dart';
import '/system/keys.dart';
import '/system/requester.dart';
import '/system/session.dart';
import '/tools/app/appNavigator.dart';
import '/tools/centers/httpCenter.dart';
import '/tools/centers/sheetCenter.dart';

class AddMaterialScreenCtr implements ViewController {
  late AddFoodMaterialScreenState state;
  UserModel? user;
  late Requester commonRequester;
  List<FundamentalHolder> selectedFundamentals = [];
  List<String> alternatives = [];
  Map<String, bool> typeSelected = {};
  final allFundamentals = <String, String>{};
  final titleEditCtr = TextEditingController();
  final measureCtr = TextEditingController();
  bool canShowFlag = true;
  bool inCheckTitle = true;
  int sumCaloriesState = 0;
  late MaterialMeasureModel measureModel;

  AddMaterialScreenCtr();

  @override
  void onInitState<E extends State>(E state){
    this.state = state as AddFoodMaterialScreenState;

    Session.addLogoffListener(onLogout);
    typeSelected.addAll({'matter': true, 'complement': false, 'herbal_tea': false});

    commonRequester = Requester();
    measureModel = MaterialMeasureModel();
    measureModel.unit = MeasureUnits.gram.name;
    measureModel.unitValue = '100';

    measureCtr.text = measureModel.unitValue;

    final map = state.tAsMap('materialFundamentals')!.map((key, value) {
      return MapEntry<String, String>(key, value);
    });

    allFundamentals.addAll(map);

    prepareMainFundamental();
  }

  @override
  void onBuild(){
    user = Session.getLastLoginUser();
  }

  @override
  void onDispose(){
    HttpCenter.cancelAndClose(commonRequester.httpRequester);
    Session.removeLogoffListener(onLogout);
  }

  void onLogout(user){
    HttpCenter.cancelAndClose(commonRequester.httpRequester);
    AppNavigator.popRoutesUntilRoot(state.context);
  }
  ///========================================================================================================
  void tryAgain(State state){
    if(state is AddFoodMaterialScreenState) {
      state.stateController.mainState = StateXController.state$loading;
      state.stateController.updateMain();

      requestAddMaterial();
    }
  }

  void prepareMainFundamental(){
    selectedFundamentals.removeWhere((element) => element.isMain);

    for(final base in Keys.mainMaterialFundamentals){
      final mfm = MaterialFundamentalModel();
      mfm.key = base;

      final holder = FundamentalHolder.by(mfm, true);

      selectedFundamentals.add(holder);
    }
  }

  void checkSumCalories(){
    var cal = '';
    var pro = '';
    var car = '';
    var fat = '';

    sumCaloriesState = 0;

    for(final holder in selectedFundamentals){
      if(!holder.isMain){
        continue;
      }

      if(holder.fundamental.key == 'calories'){
        cal = holder.editingController.text.trim();
      }
      else if(holder.fundamental.key == 'protein'){
        pro = holder.editingController.text.trim();
      }
      else if(holder.fundamental.key == 'carbohydrate'){
        car = holder.editingController.text.trim();
      }
      else if(holder.fundamental.key == 'fat'){
        fat = holder.editingController.text.trim();
      }
    }

    if(cal.isEmpty || pro.isEmpty || car.isEmpty || fat.isEmpty){
      state.stateController.setOverlay(state.getTopOverlay);
      return;
    }

    double calories = double.tryParse(cal)?? 0;
    double protein = double.tryParse(pro)?? 0;
    double carbohydrate = double.tryParse(car)?? 0;
    double fatInt = double.tryParse(fat)?? 0;

    double res = (protein*4) + (carbohydrate*4) + (fatInt*9);
    double dif = (calories - res).abs();

    if(dif > 10){
      sumCaloriesState = 2;
    }
    else if(dif > 1){
      sumCaloriesState = 1;
    }

    state.stateController.setOverlay(state.getTopOverlay);
  }

  void onAddOtherFundamentalClick(){
    FocusHelper.hideKeyboardByUnFocusRoot();

    final mfm = MaterialFundamentalModel();
    final holder = FundamentalHolder.by(mfm, false);

    pickFreeFundamental(holder);

    selectedFundamentals.add(holder);
    state.stateController.updateMain();
  }

  void pickFreeFundamental(FundamentalHolder holder){
    holder.fundamental.key = '';

    for(final fun in allFundamentals.entries){
      var exist = false;

      for(final iHolder in selectedFundamentals){
        if(iHolder.fundamental.key == fun.key){
          exist = true;
          break;
        }
      }

      if(exist){
        continue;
      }

      holder.fundamental.key = fun.key;
      break;
    }
  }

  List<DropdownMenuItem<String>> getDropdownMeasureItems(){
    final res = <DropdownMenuItem<String>>[];

    for(final m in MeasureUnits.values){
      final d = DropdownMenuItem<String>(
        value: m.name,
        child: Text('${state.tInMap('materialUnits', m.name)}')
            .color(state.itemColor).bold(),
      );

      res.add(d);
    }

    return res;
  }

  List<DropdownMenuItem<String>> getDropdownItems(String myKey){
    final res = <DropdownMenuItem<String>>[];

    for(final fun in allFundamentals.entries){
      var exist = false;

      for(final iHolder in selectedFundamentals){
        if(myKey != fun.key && iHolder.fundamental.key == fun.key){
          exist = true;
          break;
        }
      }

      if(exist){
        continue;
      }

      final d = DropdownMenuItem<String>(
        value: fun.key,
        child: Text(fun.value.localeNum())
            .color(state.itemColor).bold(),
      );

      res.add(d);
    }

    return res;
  }

  String? findUnSelected(List<String> selectedList){
    for(final tr in allFundamentals.entries){
      if(!selectedList.contains(tr.key)){
        selectedList.add(tr.key);

        return tr.key;
      }
    }

    return null;
  }

  void checkRepeatSelected(){
    final tempList = <String>[];

    for(final obj in selectedFundamentals) {
      tempList.add(obj.fundamental.key);
    }

    for(var p in selectedFundamentals.reversed) {
      for(final p2 in selectedFundamentals) {
        if(!identical(p, p2) && p.fundamental.key == p2.fundamental.key){
          p.fundamental.key = findUnSelected(tempList)?? '';
          break;
        }
      }
    }
  }

  void onAddSameWordClick(){
    AppNavigator.pushNextTransparentPage(
        state.context,
        TopInputFieldScreen(),
        name: TopInputFieldScreen.screenName
    ).then((value) {
      if(value != null){
        alternatives.add(value);
        state.stateController.updateSubMain();
      }
    });
  }

  void onSaveClick3() {
    checkSumCalories();
  }

  void onSaveClick(){
    checkSumCalories();

    if(sumCaloriesState == 2){
      AnimationController? ctr = state.stateController.object('errorOverlayAnim');
      ctr?.forward();
      ctr?.addStatusListener((status) {
        if(status == AnimationStatus.completed){
          ctr.reset();
        }
      });

      return;
    }

    final type = Tools.getToggleSelectedName(typeSelected, defValue: 'matter');

    if(canShowFlag && type == 'matter'){
      for(final holder in selectedFundamentals){
        if(!holder.isMain){
            continue;
          }

        final val = holder.editingController.text.trim();

        if(val.isEmpty){
          var msg = 'enterCaloriesValue';

          if(holder.fundamental.key == 'protein'){
            msg = 'enterProteinValue';
          }
          else if(holder.fundamental.key == 'carbohydrate'){
            msg = 'enterCarbohydrateValue';
          }
          else if(holder.fundamental.key == 'fat'){
            msg = 'enterFatValue';
          }

          SheetCenter.showSheetOk(state.context, '${state.tInMap('foodProgramScreen', msg)}');
          return;
        }
      }
    }

    requestAddMaterial();
  }

  void requestCheckName() async {
    FocusHelper.hideKeyboardByUnFocus(state.context);

    String name = titleEditCtr.text.trim();

    final js = <String, dynamic>{};
    js[Keys.request] = 'CheckNewFoodMaterialName';
    js[Keys.requesterId] = user?.userId;
    js[Keys.name] = name;


    commonRequester.requestPath = RequestPath.GetData;
    commonRequester.bodyJson = js;

    commonRequester.httpRequestEvents.onAnyState = (req) async {
      await state.hideLoading();
    };

    commonRequester.httpRequestEvents.onNetworkError = (req) async {
      SheetCenter.showSheet$ErrorCommunicatingServer(state.context);
    };

    commonRequester.httpRequestEvents.onResponseError = (req, isOk) async {
      SheetCenter.showSheet$ServerNotRespondProperly(state.context);
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      int causeCode = data[Keys.causeCode] ?? 0;

      if(causeCode == HttpCodes.error_existThis){
        SheetCenter.showSheetOk(state.context, '${state.tInMap('foodProgramScreen','thereIsThisCase')}');
        return true;
      }

      return false;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      inCheckTitle = false;
      AnimationController? anim = state.stateController.object('ShowOptionsAnim');
      anim?.forward();
      state.stateController.updateSubMain();
    };

    state.showLoading();
    commonRequester.request(state.context);
  }

  void requestAddMaterial() async {
    FocusHelper.hideKeyboardByUnFocus(state.context);

    final fundamentals = <Map>[];

    for(final p in selectedFundamentals){
      String v = p.editingController.text.trim();

      if(v.isNotEmpty) {
        final f = MaterialFundamentalModel();
        f.key = p.fundamental.key;
        f.value = v;

        fundamentals.add(f.toMap());
      }
    }

    final js = <String, dynamic>{};
    js[Keys.request] = 'AddNewFoodMaterial';
    js[Keys.userId] = user?.userId;
    js[Keys.title] = titleEditCtr.text.trim();
    js['alternatives'] = alternatives;
    js['fundamentals_js'] = fundamentals;
    js['can_show'] = canShowFlag;
    js['measure_js'] = measureModel.toMap();
    js[Keys.type] = Tools.getToggleSelectedName(typeSelected, defValue: 'matter');

    commonRequester.requestPath = RequestPath.SetData;
    commonRequester.bodyJson = js;

    commonRequester.httpRequestEvents.onAnyState = (req) async {
      await state.hideLoading();
    };

    commonRequester.httpRequestEvents.onNetworkError = (req) async {
      SheetCenter.showSheet$ErrorCommunicatingServer(state.context);
      state.stateController.mainStateAndUpdate(StateXController.state$netDisconnect);
    };

    commonRequester.httpRequestEvents.onResponseError = (req, isOk) async {
      SheetCenter.showSheet$ServerNotRespondProperly(state.context);
      state.stateController.mainStateAndUpdate(StateXController.state$serverNotResponse);
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      state.stateController.mainStateAndUpdate(StateXController.state$serverNotResponse);

      return false;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      SheetCenter.showSheetOneAction(state.context, '${state.t('successOperation')}', (){
        AppNavigator.pop(state.context);
      });

      state.stateController.mainStateAndUpdate(StateXController.state$normal);
    };

    state.showLoading();
    commonRequester.request(state.context);
  }
}
