import 'package:flutter/material.dart';

import 'package:iris_tools/widgets/optionsRow/radioRow.dart';

import '/system/extensions.dart';
import '/system/queryFiltering.dart';

class SearchPanelView extends StatefulWidget {
  final FilterRequest filter;

  SearchPanelView(
    this.filter, {
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SearchPanelViewState();
  }
}
///============================================================================================
class SearchPanelViewState extends State<SearchPanelView> {
  List<SearchingViewModel> searchViews = [];


  @override
  void initState() {
    super.initState();

    searchViews = widget.filter.searchingViewList;
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Text('${context.tInMap('optionsKeys', 'searching')}').bold().fsR(2, max: 16)),
                const SizedBox(height: 12,),
                const Divider(),

                ...List.generate(searchViews.length, (index) {
                  return RadioRow(
                    value: searchViews[index].key,
                    groupValue: widget.filter.selectedSearchKey?? '',
                    onChanged: (v){
                      widget.filter.selectedSearchKey = v;

                      setState(() {});
                    },
                    description: Text('${context.tInMap('optionsKeys', searchViews[index].key)}'),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
