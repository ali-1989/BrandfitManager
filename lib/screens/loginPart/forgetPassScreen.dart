import 'package:flutter/material.dart';

import 'package:animate_do/animate_do.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';
import 'package:simple_timer/simple_timer.dart';

import '/abstracts/stateBase.dart';
import '/screens/loginPart/forgetPassScreenCtr.dart';
import '/tools/app/appSizes.dart';
import '/tools/app/appThemes.dart';
import '/tools/centers/localeCenter.dart';

class ForgetPassScreen extends StatefulWidget {
	static const screenName = 'ForgetPassScreen';

	ForgetPassScreen({Key? key}) : super(key: key);

	@override
	State<StatefulWidget> createState() {
		return ForgetPassScreenState();
	}
}
///==============================================================================================================
class ForgetPassScreenState extends StateBase<ForgetPassScreen> with SingleTickerProviderStateMixin{
	StateXController stateController = StateXController();
	ForgetPassScreenCtr controller = ForgetPassScreenCtr();


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
				appBar: getAppbar(),
				body: SafeArea(
					child: getMainBuilder(),
				),
			),
		);
	}

	Widget getMainBuilder() {
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

	PreferredSizeWidget getAppbar() {
		return AppBar(
			title: Text(tC('passwordRecovery')!),
		);
	}

	Widget getBody() {
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
									'${LocaleCenter.appLocalize.translateCapitalize('passwordRecovery')}',
									style: const TextStyle(fontSize: 28),
								),
								const SizedBox(height: 8,),
								Text('${LocaleCenter.appLocalize.translate('passwordRecoveryDescription')}',
										style: const TextStyle(fontSize: 12)),
							]),
				),

				const SizedBox(height: 34,),

				/// sec2
				Expanded(
					child: FadeInUp(
						delay: const Duration(milliseconds: 300),
						duration: const Duration(seconds: 1),
						child: Align(
							alignment: Alignment.topCenter,
							child: ConstrainedBox(
								constraints: BoxConstraints.loose(const Size(400, double.infinity)),
								child: SingleChildScrollView(
									child: Padding(
										padding: const EdgeInsets.symmetric(horizontal: 30.0),
										child: Column(
											children: <Widget>[
												const SizedBox(height: 22,),

												/// inputField
												Padding(
													padding: const EdgeInsets.symmetric(horizontal: 20.0),

													/// mobile field
													child: DecoratedBox(
														decoration: BoxDecoration(
															border: Border(bottom: BorderSide(color: AppThemes.currentTheme.textColor)),
														),
														child: TextField(
															textDirection: TextDirection.ltr,
															controller: controller.mobileFieldController,
															keyboardType: TextInputType.phone,
															textInputAction: TextInputAction.done,
															style: AppThemes.baseTextStyle(),
															onSubmitted: (_) => FocusScope.of(context).unfocus(),
															decoration: InputDecoration(
																hintText: '${tC('mobileNumber')}',
																border: InputBorder.none,
																focusColor: AppThemes.currentTheme.textColor,
																hintStyle: TextStyle(color: AppThemes.currentTheme.textColor),
																focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppThemes.currentTheme.textColor)),
																enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppThemes.currentTheme.textColor)),
															),
														),
													),
												),

												const SizedBox(height: 20,),

												SizedBox(
													width: 74, height: 74,
													child: SimpleTimer(
														controller: controller.timerController,
														timerStyle: TimerStyle.ring,
														progressTextStyle: TextStyle(color: AppThemes.currentTheme.differentColor),
														progressIndicatorColor: ColorHelper.changeLight(AppThemes.currentTheme.primaryColor),
														backgroundColor: AppThemes.currentTheme.differentColor,
														onEnd: (){controller.timerEnd();},
														duration: const Duration(seconds: 60),
													),),

												const SizedBox(height: 25,),

												///  sendBtn
												Builder(
													builder: (ctx){
														final isActive = stateController.stateDataOrDefault('activeBtn', true);

														return FractionallySizedBox(
															widthFactor: 0.5,
															child: ElevatedButton(
																onPressed:isActive? () => controller.onSendInfoClick() : null,
																child: Row(
																	mainAxisSize: MainAxisSize.min,
																	children: <Widget>[
																		const Icon(Icons.send),
																		const SizedBox(width: 6,),
																		Text('${LocaleCenter.appLocalize.translateCapitalize('send')}'),
																	],
																),
															),
														);
													},
												),

												const SizedBox(height: 10,),
											],
										),
									),
								),
							),
						),
					),
				),
			],
		);
	}
///==============================================================================================================
}
