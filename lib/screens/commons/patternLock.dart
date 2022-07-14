import 'package:flutter/material.dart';

import 'package:pattern_lock/pattern_lock.dart';

import '/abstracts/stateBase.dart';
import '/tools/app/appNavigator.dart';
import '/tools/app/appSizes.dart';

typedef OnPattern = bool Function(BuildContext context, List<int>? pattern);
///================================================================================================
class PatternLockScreen extends StatefulWidget {
  static const screenName = 'PatternLockScreen';
  final PatternLockController? controller;
  final String title;
  final String description;
  final OnPattern? onBack;
  final OnPattern? onResult;

  PatternLockScreen({
    Key? key,
    this.controller,
    this.title = '',
    this.description = '',
    this.onBack,
    this.onResult,
    }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PatternLockScreenState();
  }
}
///================================================================================================
class PatternLockScreenState extends StateBase<PatternLockScreen> {
  late String title;
  late String description;
  List<int>? result;

  @override
  void initState() {
    super.initState();

    title = widget.title;
    description = widget.description;

    if(widget.controller != null){
      widget.controller!._state = this;
    }
  }

  @override
  Widget build(BuildContext context) {
    rotateToPortrait();

    return getScaffold();
  }

  @override
  void dispose() {
    widget.controller?._state = null;

    super.dispose();
  }

  @override
  Future<bool> onWillBack<S extends StateBase>(S state) {
    if(widget.onBack != null){
      final res = widget.onBack!.call(context, result);
      return Future<bool>.value(res);
    }

    AppNavigator.pop(context, result: result);
    return Future<bool>.value(false);
  }

  Widget getScaffold() {
    return WillPopScope(
      onWillPop: () => onWillBack(this),
      child: Scaffold(
        key: scaffoldKey,
        appBar: getAppbar(),
        body: getBody(),
      ),
    );
  }

  PreferredSizeWidget getAppbar() {
    return AppBar(
      title: Text(title),
    );
  }

  Widget getBody() {
    return SizedBox(
      width: AppSizes.getScreenWidth(context),
      height: AppSizes.getScreenHeight(context),

      child: Column(
        children: <Widget>[
          const SizedBox(height: 40,),
          Text(description, style: const TextStyle(fontSize: 15),),
          const SizedBox(height: 20,),
          Expanded(
            child: PatternLock(
              selectedColor: Colors.red,
              pointRadius: 8,
              dimension: 3,
              relativePadding: 0.6,
              selectThreshold: 20,
              showInput: true,
              fillPoints: true,

              onInputComplete: (List<int> input) {
                result = input;
                final pop = widget.onResult?.call(context, input)?? false;

                if(pop){
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
          const SizedBox(height: 20,),
        ],
      ),
    );
  }
}
///================================================================================================
class PatternLockController {
  PatternLockScreenState? _state;

  void setTitle(String title){
    if(_state == null || !_state!.mounted){
      return;
    }

    _state!.title = title;
    _state!.update();
  }

  void setDescription(String description){
    if(_state == null || !_state!.mounted){
      return;
    }

    _state!.description = description;
    _state!.update();
  }

  void pop(){
    if(_state == null || !_state!.mounted){
      return;
    }

    Navigator.of(_state!.context).pop();
  }
}

