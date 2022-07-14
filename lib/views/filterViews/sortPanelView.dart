import 'package:flutter/material.dart';

import 'package:iris_tools/widgets/optionsRow/radioRow.dart';

import '/system/extensions.dart';
import '/system/queryFiltering.dart';

class SortPanelView extends StatefulWidget {
  final FilterRequest filter;

  SortPanelView(this.filter, {Key? key}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SortPanelViewState();
  }
}
///============================================================================================
class SortPanelViewState extends State<SortPanelView> {
  List<SortingViewModel> sortList = [];

  @override
  void initState() {
    super.initState();

    sortList = widget.filter.sortingViewList;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.topCenter,
      widthFactor: 0.8,
      //heightFactor: 0.92,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 22, 10, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text('${context.tInMap('optionsKeys', 'sorting')}').bold().fsR(2, max: 16)),
              const SizedBox(height: 12,),
              const Divider(),

              ...List.generate(sortList.length, (index) {
                return RadioRow(
                  value: sortList[index].getTranslateKey(),
                  groupValue: widget.filter.getSortViewSelected()?.getTranslateKey()?? '',
                  onChanged: (v){
                    //sortList[index].mustUseForQuery = v;
                    widget.filter.addSortView(sortList[index].key, isAsc: sortList[index].isASC, isDefault: true);
                    setState(() {});
                  },
                  description: Text('${context.tInMap('optionsKeys', sortList[index].getTranslateKey())}'),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
