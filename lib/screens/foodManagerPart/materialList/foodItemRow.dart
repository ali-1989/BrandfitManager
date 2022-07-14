import 'package:flutter/material.dart';

import '/abstracts/stateBase.dart';
import '/models/dataModels/foodModels/materialFundamentalModel.dart';
import '/models/dataModels/foodModels/materialModel.dart';
import '/screens/foodManagerPart/materialList/foodItemRowCtr.dart';
import '/screens/foodManagerPart/materialList/foodMaterialListScreen.dart';
import '/system/extensions.dart';
import '/system/icons.dart';
import '/system/keys.dart';
import '/tools/app/appThemes.dart';

class FoodItemRow extends StatefulWidget {
  final MaterialModel foodModel;
  final FoodMaterialListScreenState parentState;

  FoodItemRow(this.foodModel, this.parentState, {Key? key}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FoodItemRowState();
  }
}
///===============================================================================================
class FoodItemRowState extends StateBase<FoodItemRow> {
  final controller = FoodItemRowCtr();

  @override
  void initState() {
    super.initState();
    controller.onInitState(this);
  }

  @override
  Widget build(BuildContext context) {
    controller.onBuild();

    return getBody();
  }

  @override
  void dispose() {
    controller.onDispose();
    super.dispose();
  }

  Widget getBody() {
    var itemColor = AppThemes.currentTheme.whiteOrBlackOn(AppThemes.currentTheme.primaryWhiteBlackColor);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Card(
                      color: AppThemes.currentTheme.primaryWhiteBlackColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 8),
                        child: Text(controller.materialModel.matchTitle?? controller.materialModel.orgTitle)
                            .bold()
                            .color(itemColor),
                      ),
                    ),

                    Text('  ${tInMap('foodProgramScreen', '${controller.materialModel.type}')}').subFont(),
                  ],
                ),

                Icon(IconList.dotsVer, size: 16,
                  color: AppThemes.currentTheme.primaryWhiteBlackColor,)
                    .wrapMaterial(
                  materialColor: AppThemes.currentTheme.primaryWhiteBlackColor.withAlpha(50),
                  padding: const EdgeInsets.all(7),
                  onTapDelay: (){
                    controller.showEditMenu();
                  },
                ),
              ],
            ),

            Row(
              children: [
                if(!controller.materialModel.canShow)
                  Icon(IconList.eyeOff).primaryOrAppBarItemOnBackColor(),
              ],
            ),
            const SizedBox(height: 6,),

            if(controller.materialModel.alternatives.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${tInMap('foodProgramScreen','sameWords')}:')
                            .bold(weight: FontWeight.w900),
                      ],
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            alignment: WrapAlignment.start,
                            crossAxisAlignment: WrapCrossAlignment.start,
                            runAlignment: WrapAlignment.start,
                            direction: Axis.horizontal,
                            spacing: 4,
                            children: [
                              ...genAlternativesItems(controller.materialModel.alternatives)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${tInMap('foodProgramScreen','values')}:')
                      .bold(weight: FontWeight.w900),


                  Visibility(
                    visible: controller.materialModel.mainFundamentals.isNotEmpty,
                    child: Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            alignment: WrapAlignment.start,
                            crossAxisAlignment: WrapCrossAlignment.start,
                            runAlignment: WrapAlignment.start,
                            direction: Axis.horizontal,
                            spacing: 2,
                            runSpacing: 2,
                            children: [
                              ...genMainFundamentals(controller.materialModel.mainFundamentals)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Visibility(
                      visible: controller.materialModel.mainFundamentals.isNotEmpty && controller.materialModel.otherFundamentals.isNotEmpty,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Divider(),
                      )
                  ),

                  Visibility(
                      visible: controller.materialModel.otherFundamentals.isNotEmpty,
                      child: Row(
                        children: [
                          Expanded(
                            child: Wrap(
                              alignment: WrapAlignment.start,
                              crossAxisAlignment: WrapCrossAlignment.start,
                              runAlignment: WrapAlignment.start,
                              direction: Axis.horizontal,
                              spacing: 2,
                              runSpacing: 2,
                              children: [
                                ...genOtherFundamentals(controller.materialModel.otherFundamentals)
                              ],
                            ),
                          ),
                        ],
                      )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  ///========================================================================================================
  List<Widget> genAlternativesItems(List alternatives){
    List<Widget> res = [];

    for(var i in alternatives){
      /*var w = Chip(
        padding: EdgeInsets.zero,
        //labelPadding: EdgeInsets.symmetric(horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        label: Text('$i'),
      );*/

      var w = RichText(
        text: TextSpan(text: '$i',
            style: const TextStyle(color: Colors.black),
            children: const [
          TextSpan(text: '/'),
        ]),
      );
      res.add(w);
    }

    return res;
  }

  List<Widget> genMainFundamentals(List<MaterialFundamentalModel> prop){
    List<Widget> res = [];

    prop.sort((e1, e2){
      if(e1.key == e2.key){
        return 0;
      }

      int? idx1 = Keys.mainMaterialFundamentals.indexOf(e1.key);
      int? idx2 = Keys.mainMaterialFundamentals.indexOf(e2.key);

      return idx1.compareTo(idx2);
    });

    for(final i in prop){
      final d = '${tAsMap('materialFundamentals')![i.key]}: ${i.value}';
      /*var w = Chip(
        padding: EdgeInsets.zero,
        labelPadding: EdgeInsets.symmetric(horizontal: 6),
        label: Text(d.localeNum(Settings.appLocale))
            .bold()
            .color(AppThemes.currentTheme.whiteOrBlackOn(AppThemes.themeData.chipTheme.backgroundColor)),
      );*/

      final w = OutlinedButton(
          onPressed: (){},
          child: Text(d.localeNum()).alpha()
      );

      res.add(w);
    }

    return res;
  }

  List<Widget> genOtherFundamentals(List<MaterialFundamentalModel> other){
    List<Widget> res = [];

    for(final i in other){
      final d = '${tAsMap('materialFundamentals')?[i.key]}: ${i.value}';

      final w = OutlinedButton(
          onPressed: (){},
          child: Text(d.localeNum()).alpha()
      );

      res.add(w);
    }

    return res;
  }
}
