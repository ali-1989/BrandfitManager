import 'package:flutter/material.dart';

import 'package:iris_tools/models/dataModels/colorTheme.dart';

import '/abstracts/stateBase.dart';
import '/models/dataModels/foodModels/materialFundamentalModel.dart';
import '/system/extensions.dart';
import '/tools/app/appThemes.dart';

class FundamentalView extends StatefulWidget {
  final MaterialFundamentalModel fundamentalModel;
  final bool isMain;
  late final FundamentalViewState? state;

  FundamentalView({
    required this.fundamentalModel,
    required this.isMain,
    Key? key,
  }) : super(key: key);


  @override
  State<StatefulWidget> createState(){
    state = FundamentalViewState();
    return state!;
  }
}
///===================================================================================================
class FundamentalViewState extends StateBase<FundamentalView> {
  static final allFundamentals = <String, String>{};

  late TextEditingController editingController;
  late MaterialFundamentalModel fundamental;
  bool isMain = false;
  VoidCallback? onChangeValue;
  late Color itemColor;
  late InputDecoration inputDecoration;


  @override
  void initState() {
    super.initState();

    editingController = TextEditingController();
    fundamental = widget.fundamentalModel;
    isMain = widget.isMain;

    editingController.text = fundamental.value!;

    itemColor = AppThemes.currentTheme.whiteOrBlackOn(AppThemes.currentTheme.primaryWhiteBlackColor);
    inputDecoration = ColorTheme.noneBordersInputDecoration.copyWith(
      hintText: t('value'),
      hintStyle: TextStyle(color: itemColor),
      border: UnderlineInputBorder(borderSide: BorderSide(color: itemColor)),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: itemColor)),
      constraints: BoxConstraints.tightFor(height: 40),
      contentPadding: EdgeInsets.all(0),
    );

    if(allFundamentals.isEmpty){
      final map = tAsMap('materialFundamentals')!.map((key, value) {
        return MapEntry<String, String>(key, value);
      });

      allFundamentals.addAll(map);
    }
  }

  @override
  void didUpdateWidget(FundamentalView oldWidget) {
    super.didUpdateWidget(oldWidget);

    widget.state = oldWidget.state;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
            width: 85,
            child: Text('${allFundamentals[fundamental.key]}:')
                .color(itemColor).bold()
        ),

        SizedBox(width: 16,),
        Padding(
          padding: const EdgeInsets.fromLTRB(0,0,0,5),
          child: SizedBox(
            width: 50,
            child: TextField(
              controller: editingController,
              style: TextStyle(color: itemColor),
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              decoration: inputDecoration,
              onChanged: (txt){
                onChangeValue?.call();
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    editingController.dispose();
    super.dispose();
  }

  static int get allFundamentalCount => allFundamentals.length;

  void pickFreeProperty(List<FundamentalView> currentSelected){
    fundamental.key = '';

    for(final fun in allFundamentals.entries){
      var exist = false;

      for(final view in currentSelected){
        if(view.state!.fundamental.key == fun.key){
          exist = true;
          break;
        }
      }

      if(exist){
        continue;
      }

      fundamental.key = fun.key;
      break;
    }
  }

  List<DropdownMenuItem<String>> getDropdownItems(List<FundamentalView> currentSelected, String myKey){
    final res = <DropdownMenuItem<String>>[];

    for(final fun in allFundamentals.entries){
      var exist = false;

      for(final view in currentSelected){
        if(myKey != fun.key && view.state!.fundamental.key == fun.key){
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
            .color(itemColor).bold(),
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

  void checkRepeatSelected(List<FundamentalView> currentSelected){
    final tempList = <String>[];

    for(final obj in currentSelected) {
      tempList.add(obj.state!.fundamental.key);
    }

    for(var p in currentSelected.reversed) {
      for(final p2 in currentSelected) {
        if(!identical(p, p2) && p.state!.fundamental.key == p2.state!.fundamental.key){
          p.state!.fundamental.key = findUnSelected(tempList)?? '';
          break;
        }
      }
    }
  }
}
