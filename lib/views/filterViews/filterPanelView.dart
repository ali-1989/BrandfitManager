import 'package:flutter/material.dart';

import 'package:iris_tools/widgets/optionsRow/checkRow.dart';
import 'package:iris_tools/widgets/optionsRow/radioRow.dart';
import 'package:iris_tools/widgets/slider/buRangeSlider.dart';

import '/system/extensions.dart';
import '/system/queryFiltering.dart';
import '/tools/app/appThemes.dart';

class FilterPanelView extends StatefulWidget {
  final FilterRequest filter;

  FilterPanelView(this.filter, {Key? key}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return FilterPanelViewState();
  }
}
///============================================================================================
class FilterPanelViewState extends State<FilterPanelView> {
  List<FilteringViewModel> filterList = [];

  @override
  void initState() {
    super.initState();

    filterList = widget.filter.filterViewList.where((element) => !element.hasNotView).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.topCenter,
      widthFactor: 0.85,
      //heightFactor: 0.92,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 22, 10, 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Center(
                        child: Text('${context.tInMap('optionsKeys', 'filtering')}').bold().fsR(2, max: 16)
                    ),
                    Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: SizedBox(
                        width: 50,
                        child: TextButton(
                          child: Text('${context.tC('clean')}'),

                          onPressed: (){
                            for (var element in filterList) {element.clear();}

                            setState(() {});
                          },
                        ),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 12,),
                const Divider(),
                const SizedBox(height: 12,),
                ...genList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> genList(){
    final result = <Widget>[];

    final divider = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(color: AppThemes.currentTheme.textColor,),
    );

    for(int i = 0; i< filterList.length; i++){
      final fItem = filterList[i];

      if(fItem.type == FilterType.checkbox){
        final cView = CheckBoxRow(
          description: Text('${context.tInMap('optionsKeys', fItem.key)}'),
          value: fItem.selectedValue == fItem.key,
          onChanged: (v){
            if(v != null && v) {
              fItem.selectedValue = fItem.key;
            }
            else {
              fItem.selectedValue = null;
            }

            setState(() {});
          },
        );

        result.add(cView);

        if(i < filterList.length-1) {
          result.add(divider);
        }
      }

      if(fItem.type == FilterType.radio){
        final resultColumn = <Widget>[];

        final titleView = Text('${context.tInMap('optionsKeys', fItem.key)}').bold();
        resultColumn.add(titleView);

        for(var sub in fItem.subViews){
          final r = RadioRow(
            value: sub.key,
            groupValue: fItem.selectedValue,
            description: Text('${context.tInMap('optionsKeys', sub.key)}'),
            onChanged: (v){
              if(v != null && v != fItem.selectedValue) {
                fItem.selectedValue = sub.key;
              }
              else {
                fItem.selectedValue = null;
              }

              setState(() {});
            },
          );

          resultColumn.add(r);
        }

        final rView = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: resultColumn,
        );

        result.add(rView);

        if(i < filterList.length-1) {
          result.add(divider);
        }
      }

      if(fItem.type == FilterType.range){
        final int min = fItem.subViews[0].v1?? 1;
        final int max = fItem.subViews[0].v2?? 100;
        final int sMin = fItem.selectedV1?? min;
        final int sMax = fItem.selectedV2?? max;

        final rangeView = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${context.tInMap('optionsKeys', fItem.key)}').bold(),
                SizedBox(
                  width: 50,
                  child: TextButton(
                    child: Text('${context.tC('clean')}'),
                    onPressed: (){
                      fItem.clear();

                      setState(() {});
                    },
                  ),
                )
              ],
            ),

            const SizedBox(height: 12,),

            Directionality(
              textDirection: TextDirection.ltr,
              child: BuRangeSlider(
                min: min,
                max: max,
                fullWidth: true,
                values: RangeValues(sMin.toDouble(), sMax.toDouble()),
                onChanged: (RangeValues val){
                  fItem.selectedV1 = val.start.toInt();
                  fItem.selectedV2 = val.end.toInt();

                  setState(() {});
                },
              ),
            ),
          ],
        );

        result.add(rangeView);

        if(i < filterList.length-1) {
          result.add(divider);
        }
      }
    }

    return result;
  }
}
