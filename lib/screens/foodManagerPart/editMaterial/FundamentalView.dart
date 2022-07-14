import 'package:flutter/material.dart';

import '/abstracts/stateBase.dart';
import '/models/holderModels/fundamentalHolder.dart';

typedef FundamentalBuilder = Widget Function(TextEditingController textEditingController);
///===================================================================================================
class FundamentalView extends StatefulWidget {
  final FundamentalHolder fundamentalHolder;
  final FundamentalBuilder builder;

  FundamentalView({
    required this.fundamentalHolder,
    required this.builder,
    Key? key,
  }) : super(key: key);


  @override
  State<StatefulWidget> createState(){
    return FundamentalViewState();
  }
}
///===================================================================================================
class FundamentalViewState extends StateBase<FundamentalView> {
  late TextEditingController editingController;


  @override
  void initState() {
    super.initState();

    editingController = TextEditingController();
    widget.fundamentalHolder.editingController = editingController;
  }

  @override
  void didUpdateWidget(FundamentalView oldWidget) {
    super.didUpdateWidget(oldWidget);

    widget.fundamentalHolder.editingController = editingController;
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(editingController);
  }

  @override
  void dispose() {
    try{
      editingController.dispose();
    }
    catch (e){}

    super.dispose();
  }
}
