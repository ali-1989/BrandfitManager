import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/api/timerTools.dart';
import 'package:iris_tools/features/overlayDialog.dart';
import 'package:lottie/lottie.dart';

import '/tools/app/appNavigator.dart';
import '/tools/app/appThemes.dart';

class LoadingScreen {
	LoadingScreen._();

	static bool isLoading = false;
	static bool mustShowLoading = false;
	static int startShowLoading = 0;
	static OverlayScreenView? loadingOverlay;

	///===============================================================================================
	static void showLoading(BuildContext context, {
		bool canBack = true,
		Color? color,
		Color? dimColor,
		Duration closeDuration = const Duration(seconds: 60),
		Duration? startDelay = const Duration(milliseconds: 200),
	}) async {
		mustShowLoading = true;

		if (startDelay != null) {
			await Future.delayed(startDelay, () {});
		}

		if (!mustShowLoading || isLoading) {
			return;
		}

		var lottieColor = AppThemes.currentTheme.primaryColor;

		if(ColorHelper.isNearColor(lottieColor, Colors.white)) {
		  lottieColor = Colors.black;
		} else if(ColorHelper.isNearColor(lottieColor, Colors.black)) {
		  lottieColor = Colors.white;
		}

		final backColor = Colors.transparent;

		loadingOverlay = OverlayScreenView(
				routingName: 'Loading' + Generator.generateKey(8),
				content: _getLoadingView(),
				backgroundColor: backColor,
		);

		mustShowLoading = false;
		isLoading = true;
		startShowLoading = DateTime.now().millisecondsSinceEpoch;

		final fut = OverlayDialog().show(
			context,
				loadingOverlay!,
				canBack: canBack,
		);

		final cancelTimer = TimerTools.timer(closeDuration, () {
			isLoading = false;
			OverlayDialog().hideByOverlay(context, loadingOverlay!);
		});

		await fut.then((value) {
			isLoading = false;
			cancelTimer.cancel();
		});
	}

	static Future hideLoading(BuildContext context) async {
		//rint('--hide ${StackTrace.current}');
		if(!isLoading && !mustShowLoading) {
			return;
		}

		if(mustShowLoading || startShowLoading < 1) {
			mustShowLoading = false;
			return;
		}

		final nowInMill = DateTime.now().millisecondsSinceEpoch;

		if(startShowLoading + 800 < nowInMill) {
			OverlayDialog().hideByOverlay(context, loadingOverlay!);
			isLoading = false;
			startShowLoading = 0;
			return;
		}
		else {
			await Future.delayed(Duration(milliseconds: (nowInMill + 1200) - startShowLoading), (){});
			OverlayDialog().hideByOverlay(context, loadingOverlay!);
			isLoading = false;
			startShowLoading = 0;
			return;
		}
	}

	static bool existLoadingOverlay(BuildContext context) {
		final os = AppNavigator.findAncestorWidgetOfExactType<OverlayScreenView>(context);
		return os != null && os.routeName.startsWith('Loading');
	}

	static Widget _getLoadingView(){
		var lottieColor = AppThemes.currentTheme.primaryColor;

		if(ColorHelper.isNearColor(lottieColor, Colors.white)) {
		  lottieColor = Colors.black;
		} else if(ColorHelper.isNearColor(lottieColor, Colors.black)) {
		  lottieColor = Colors.white;
		}

		return BackdropFilter(
				filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
				child: DecoratedBox(
						decoration: BoxDecoration(
							gradient: RadialGradient(
								colors: [
									Colors.transparent,
									Color(0x10000000),
									Color(0x30000000),
									Color(0x60000000),
								],
								stops: [0.0, 0.4, 0.8, 1.0],
								tileMode: TileMode.clamp,
								radius: 0.9,
							),
						),
						child: Center(
							child: Lottie.asset(
						'assets/raw/lottie1.json',
								width: 200,
								height: 200,
								reverse: false,
								animate: true,
								fit: BoxFit.fill,
						delegates: LottieDelegates(
							values: [
								ValueDelegate.strokeColor(
									['heartStroke', '**'],
									value: lottieColor,
								),
								ValueDelegate.color(
									['heartFill', 'Group 1', '**'],
									value: lottieColor,
								),
							],
						),
							),
						)
				)
		);
	}
}
