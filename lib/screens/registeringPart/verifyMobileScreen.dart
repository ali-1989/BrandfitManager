import 'package:flutter/material.dart';

import 'package:animate_do/animate_do.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/api/helpers/localeHelper.dart';
import 'package:iris_tools/widgets/maxWidth.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:simple_timer/simple_timer.dart';

import '/abstracts/stateBase.dart';
import '/screens/registeringPart/verifyMobileScreenCtr.dart';
import '/tools/app/appSizes.dart';
import '/tools/app/appThemes.dart';
import '/tools/centers/localeCenter.dart';

class VerifyMobileScreen extends StatefulWidget {
	static const screenName = 'VerifyMobileScreen';
	final String mobileNumber;
	final String phoneCode;

	VerifyMobileScreen(
			this.mobileNumber,
			this.phoneCode, {
				Key? key,
			}) : super(key: key);

	@override
	State<StatefulWidget> createState() {
		return VerifyMobileScreenState();
	}
}
///===============================================================================================================
class VerifyMobileScreenState extends StateBase<VerifyMobileScreen> with SingleTickerProviderStateMixin{
	var stateController = StateXController();
	var controller = VerifyMobileScreenCtr();

	@override
	void initState() {
		super.initState();
		controller.onInitState(this);
	}

	@override
	Widget build(BuildContext context) {
		rotateToPortrait();
		controller.onBuild();

		return getScaffold();
	}

	@override
	void dispose() {
		controller.onDispose();
		stateController.dispose();
		
		super.dispose();
	}

	Widget getScaffold() {
		return WillPopScope(
			onWillPop: () => onWillBack(this),
			child: Scaffold(
				key: scaffoldKey,
				appBar: AppBar(),
				body: SafeArea(
					child: getMainBuilder(),
				),
			),
		);
	}

	getMainBuilder() {
		return StateX(
				isMain: true,
				controller: stateController,
				builder: (context, ctr, data) {
					return Stack(
						fit: StackFit.expand,
						children: [
							Builder(
								builder: (context) {
									return getBody();
								},
							),
						],
					);
				}
		);
	}

	Widget getBody() {
		Color c = AppThemes.currentTheme.primaryColor;
		c = ColorHelper.getUnNearColor(c, Colors.white, Colors.black);

		return Column(
			children: <Widget>[
				/// sec1
				Container(
					width: AppSizes.getScreenWidth(context),
					padding: const EdgeInsets.symmetric(horizontal: 22),
					child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: <Widget>[
								const SizedBox(height: 35,),
								Text(
									'${LocaleCenter.appLocalize.translateCapitalize('validation')}',
									style: const TextStyle(fontSize: 32),
								),
								const SizedBox(height: 8,),
								Text(tC('validationDescription')!
										.replaceFirst('#1', LocaleHelper.embedLtr(widget.phoneCode + widget.mobileNumber)),
										style: const TextStyle(fontSize: 15)),
							]),
				),

				/// space
				const SizedBox(height: 45,),

				/// sec2
				Expanded(
					child: FadeInUp(
						delay: const Duration(milliseconds: 300),
						duration: const Duration(seconds: 1),
						child: SingleChildScrollView(
							child: Padding(
								padding: const EdgeInsets.symmetric(horizontal: 18.0),
								child: Column(
									children: <Widget>[
										const SizedBox(height: 30,),

										/// inputPin
										FadeInUp(
											delay: const Duration(milliseconds: 500),
											duration: const Duration(seconds: 1),
											child: Directionality(
												textDirection: TextDirection.ltr,
												child: Padding(
													padding: const EdgeInsets.all(8.0),
													child: MaxWidth(
														maxWidth: 370,
														child: PinCodeTextField(
															length: 5,
															enableActiveFill: true,
															autoDismissKeyboard: true,
															autoDisposeControllers: false,
															controller: controller.pinController,
															animationType: AnimationType.scale,
															animationDuration: const Duration(milliseconds: 300),
															backgroundColor: Colors.transparent,
															//errorAnimationController: errorController,
															//controller: textEditingController,
															onChanged: (_){},
															onSubmitted: (_){},
															onCompleted: (_) {},
															beforeTextPaste: (text) {
																return true;
															},
															pinTheme: PinTheme(
																shape: PinCodeFieldShape.box,
																borderRadius: BorderRadius.circular(5),
																fieldHeight: AppSizes.mSize(8),
																fieldWidth: AppSizes.mSize(6.2),
																activeFillColor: Colors.white.withAlpha(50),
																activeColor: Colors.pink,
																disabledColor: Colors.grey,
																inactiveColor: c,
																inactiveFillColor: Colors.transparent,
																selectedColor: ColorHelper.changeLight(c),
																selectedFillColor: c,
															),
															appContext: context,
														),
													),
												),
											),
										),

										const SizedBox(height: 20,),
										SizedBox(width: 74, height: 74,
											child: SimpleTimer(
												controller: controller.timerController,
												timerStyle: TimerStyle.ring,
												progressTextStyle: TextStyle(color: AppThemes.currentTheme.differentColor),
												progressIndicatorColor: AppThemes.currentTheme.differentColor,
												backgroundColor: AppThemes.currentTheme.inactiveTextColor,
												onEnd: (){
													controller.onTimerEnd();
													},
												duration: const Duration(seconds: 60),
											),),

										/// ResendBtn
										const SizedBox(height: 20,),

										Builder(
											builder: (ctx){
												bool isActive = stateController.stateDataOrDefault('activeBtn', false);

												TextStyle style = isActive?
												AppThemes.currentTheme.textUnderlineStyle
														: AppThemes.baseTextStyle().copyWith(
													color: AppThemes.currentTheme.inactiveTextColor,);

												return InkWell(
													enableFeedback: false,
													onTap:isActive? () => controller.resendCode(): null,
													child: Text('${tC('resendCode')}',
														style: style,
														textScaleFactor: 1.2,
													),
												);
											},
										),

										const SizedBox(height: 25,),

										Row(
											children: [
												Expanded(
													child: ElevatedButton(
														onPressed: () => controller.verify(),
														child: Text(t('verify')!),
													),
												),
											],
										),

										const SizedBox(height: 10,),
									],
								),
							),
						),
					),
				),
			],
		);
	}
	///===============================================================================================================
}
