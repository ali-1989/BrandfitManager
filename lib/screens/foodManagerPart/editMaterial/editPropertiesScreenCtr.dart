import 'package:brandfit_manager/models/dataModels/foodModels/materialMeasureModel.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/focusHelper.dart';

import '/abstracts/viewController.dart';
import '/models/dataModels/foodModels/materialFundamentalModel.dart';
import '/models/dataModels/foodModels/materialModel.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/models/holderModels/fundamentalHolder.dart';
import '/screens/foodManagerPart/editMaterial/editPropertiesScreen.dart';
import '/system/extensions.dart';
import '/system/keys.dart';
import '/system/requester.dart';
import '/system/session.dart';
import '/tools/app/appNavigator.dart';
import '/tools/centers/httpCenter.dart';
import '/tools/centers/sheetCenter.dart';

class EditPropertiesScreenCtr implements ViewController {
  late EditPropertiesScreenState state;
  late Requester commonRequester;
  late UserModel user;
  late MaterialModel materialModel;
  List<FundamentalHolder> selectedFundamentals = [];
  var sumCaloriesState = 0;
  final allFundamentals = <String, String>{};
  final measureCtr = TextEditingController();
  late MaterialMeasureModel measureModel;

  @override
  void onInitState<E extends State>(E state){
    this.state = state as EditPropertiesScreenState;

    materialModel = state.widget.materialModel;
    user = Session.getLastLoginUser()!;

    commonRequester = Requester();
    commonRequester.requestPath = RequestPath.SetData;

    final map = state.tAsMap('materialFundamentals')!.map((key, value) {
      return MapEntry<String, String>(key, value);
    });

    allFundamentals.addAll(map);

    measureModel = materialModel.measure;
    measureCtr.text = measureModel.unitValue;

    prepareSelectedList();

    Future.delayed(const Duration(seconds: 2), (){
      checkSumCalories();
    });
  }

  @override
  void onBuild(){
  }

  @override
  void onDispose(){
    HttpCenter.cancelAndClose(commonRequester.httpRequester);
  }
  ///========================================================================================================
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

  void prepareSelectedList(){
    for(final x in materialModel.mainFundamentals){
      final mfm = MaterialFundamentalModel();
      mfm.key = x.key;
      mfm.value = x.value;

      final holder = FundamentalHolder.by(mfm, true);

      selectedFundamentals.add(holder);
    }

    for(var x in materialModel.otherFundamentals){
      final mfm = MaterialFundamentalModel();
      mfm.key = x.key;
      mfm.value = x.value;

      final holder = FundamentalHolder.by(mfm, false);

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
    final mfm = MaterialFundamentalModel();
    final holder = FundamentalHolder.by(mfm, false);

    pickFreeFundamental(holder);

    if(materialModel.isMatter() && Keys.mainMaterialFundamentals.contains(mfm.key)){
      holder.isMain = true;
    }

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

    if(materialModel.canShow && materialModel.type == 'matter'){
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

    uploadFundamental();
  }

  void uploadFundamental() {
    FocusHelper.hideKeyboardByUnFocus(state.context);

    final fundamentals = <MaterialFundamentalModel>[];

    for(final p in selectedFundamentals){
      final v = p.editingController.text.trim();

      if(v.isNotEmpty) {
        final f = MaterialFundamentalModel();
        f.key = p.fundamental.key;
        f.value = v;

        fundamentals.add(f);
      }
    }

    final js = <String, dynamic>{};
    js[Keys.request] = Keys.adminCommand;
    js[Keys.requesterId] = user.userId;
    js[Keys.subRequest] = 'UpdateFoodMaterialFundamentals';
    js['id'] = materialModel.id;
    js['fundamentals_js'] = fundamentals.map((e) => e.toMap()).toList();
    js['measure_js'] = measureModel.toMap();

    commonRequester.bodyJson = js;

    commonRequester.httpRequestEvents.onNetworkError = (req) async {
      await state.hideLoading();
      SheetCenter.showSheet$ErrorCommunicatingServer(state.context);
    };

    commonRequester.httpRequestEvents.onResponseError = (req, isOk) async {
      await state.hideLoading();
      SheetCenter.showSheet$ServerNotRespondProperly(state.context);
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      await state.hideLoading();

      return false;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      await state.hideLoading();

      materialModel.fundamentals = fundamentals;
      materialModel.splitFundamentals();

      AppNavigator.pop(state.context, result: Keys.ok);
    };

    state.showLoading(canBack: false);
    commonRequester.request(state.context);
  }
}
