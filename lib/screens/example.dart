import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/stateX.dart';

import '/abstracts/stateBase.dart';
import '/tools/centers/dialogCenter.dart';

class ExampleScreen extends StatefulWidget {
  static const screenName = 'ExampleScreen';

  ExampleScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ExampleScreenState();
  }
}
///=======================================================================================================
class ExampleScreenState extends StateBase<ExampleScreen> {
  StateXController stateController = StateXController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    rotateToPortrait();

    return getScaffold();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void update() {
    super.update();
  }

  Widget getScaffold() {
    return WillPopScope(
      onWillPop: () => onWillBack(this),
      child: Scaffold(
        appBar: AppBar(),
        body: SafeArea(
        child: getBody(),
        )
      ),
    );
  }

  Widget getBody(){
    return StateX(
      isMain: true,
      controller: stateController,
      builder: (context, controller, sendData) {
        return ElevatedButton(
            onPressed: (){
              DialogCenter().showDialog(context,
                desc: 'ali is good',
                title: 'title is this'
              );
            },
            child: const Text('Dialog')
        );
      },
    );
  }
}

