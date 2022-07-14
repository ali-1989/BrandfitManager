import 'package:flutter/material.dart';

import 'package:iris_tools/api/managers/orientationManager.dart';

import '/managers/settingsManager.dart';
import '/system/keys.dart';
import '/tools/centers/localeCenter.dart';
import '/tools/centers/wsCenter.dart';
import '/views/loadingScreen.dart';

/// with SingleTickerProviderStateMixin
/// with TickerProviderStateMixin
abstract class StateBase<W extends StatefulWidget> extends State<W> {
	GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

	@override
  void didUpdateWidget(W oldWidget) {
		super.didUpdateWidget(oldWidget);
  }

  @override
	void initState() {
		super.initState();

		WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
			WsCenter.addMessageListener(onWebsocketMessage);
		});
	}

	@override
	Widget build(BuildContext context) {
		return const Center(child: Text('State-Base'),);
	}

	@override
	void dispose() {
		WsCenter.removeMessageListener(onWebsocketMessage);

		super.dispose();
	}

	void update() {
		if(mounted) {
		  setState(() {});
		}
	}

	void onWebsocketMessage(dynamic data){
		String? command = '';
		String? section = '';

		if(data is Map){
			section = data[Keys.section];
			command = data[Keys.command];
		}

		if(section == 'none' || command == 'UpdateProfileSettings') {
			return;
		}

		update();
	}

	void updateParent(){
		final arg = ModalRoute.of(context)?.settings.arguments;

		if(arg is StateBase) {
		  arg.update();
		}
	}

	void rotateToDefaultOrientation() {
		OrientationManager.setAppRotation(SettingsManager.appRotationState);
	}

	void rotateToPortrait() {
		if(!OrientationManager.isPortrait(context)) {
		  OrientationManager.fixPortraitModeOnly();
		}
	}

	void rotateToLandscape() {
		if(!OrientationManager.isLandscape(context)) {
		  OrientationManager.fixLandscapeModeOnly();
		}
	}

	String? t(String key, {String? key2, String? key3}) {
		var res1 = LocaleCenter.appLocalize.translate(key);

		if(res1 == null) {
		  return null;
		}

		if(key2 != null) {
		  res1 += ' ' + (LocaleCenter.appLocalize.translate(key2)?? '');
		}

		if(key3 != null) {
		  res1 += ' ' + (LocaleCenter.appLocalize.translate(key3)?? '');
		}

		return res1;
	}
	//------------------------------------------------------
	String? tC(String key, {String? key2, String? key3}) {
		var res1 = LocaleCenter.appLocalize.translateCapitalize(key);

		if(res1 == null) {
		  return null;
		}

		if(key2 != null) {
		  res1 += ' ' + (LocaleCenter.appLocalize.translate(key2)?? '');
		}

		if(key3 != null) {
		  res1 += ' ' + (LocaleCenter.appLocalize.translate(key3)?? '');
		}

		return res1;
	}

	Map<String, dynamic>? tAsMap(String key) {
		return LocaleCenter.appLocalize.translateMap(key);
	}

	Map<String, String>? tAsStringMap(String key, String subMapKey) {
		final res = tAsMap(key)?[subMapKey];

		if(res is Map){
			return res.map<String, String>((key, value) => MapEntry(key, value.toString()));
		}

		return res;
	}

	String? tInMap(String key, String subKey) {
		return tAsMap(key)?[subKey];
	}

	dynamic tDynamicOrFirst(String key, String subKey) {
		final list = tAsMap(key);

		if(list == null) {
		  return null;
		}

		final Iterable<MapEntry> tra = list.entries;
		MapEntry? find;

		try {
			find = tra.firstWhere((element) {
				return element.key == subKey;
			});
		}
		catch (e){}

		if(find != null) {
		  return find.value;
		}

		return tra.first.value;
	}

	String? tJoin(String key, {String join = ''}) {
		final list = tAsMap(key);

		if(list == null) {
		  return null;
		}

		var res = '';

		for(final s in list.entries){
			res += s.value.toString() + join;
		}

		if(res.length > join.length) {
			res = res.substring(0, res.length - join.length);
		}

		return res;
	}

	void addPostOrCall(Function() fn){
		if(!mounted){
			return;
		}

		var status = (context as Element).dirty;

		if(status) {
			WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
				fn.call();
			});
		}
		else {
			fn.call();
		}
	}

	void showLoading({bool canBack = false, Duration? startDelay}){
		return LoadingScreen.showLoading(context, canBack: canBack, startDelay: startDelay);
	}

	Future hideLoading(){
		return LoadingScreen.hideLoading(context);
	}

	// Btn back
	void onBackButton<s extends StateBase>(s state, {dynamic result}) {
		// when call [maybePop()] , onWillBack will call
		// when call [Pop()] , onWillBack not call
		Navigator.of(state.context).maybePop(result);
	}

	// before close (mayPop), keyboard backKey, onBackButton
	Future<bool> onWillBack<s extends StateBase>(s state) {
		if (state.scaffoldKey.currentState?.isDrawerOpen?? false) {
			Navigator.of(state.context).pop();
			return Future<bool>.value(false);
		}

		// if true: popPage,  false: not close page
		return Future<bool>.value(true);
	}
}

/*
	## override onWillBack in children (Screen|Page):

	@override
  Future<bool> onWillBack<s extends StateBase>(s state) {
    if (weSlideController.isOpened) {
      weSlideController.hide();
      return Future<bool>.value(false);
    }

		return Future<bool>.value(true);
    // do not use this, not work: return super.onWillBack(state);
  }

	.............
	WillPopScope(
			onWillPop: () => state.onWillBack(state),
			child: ...)
 --------------------------------------------------------------------------------------
 sample of build():

 state.mediaQuery ??= MediaQuery.of(state.context).size;

  return WillPopScope(
    onWillPop: () => state.onWillBack(state),
    child: Material( //or Scaffold
        child: SizedBox(
          width: state.mediaQuery.width,
          height: state.mediaQuery.height,
          child: SafeArea(
            child:
 --------------------------------------------------------------------------------------
 */
