import 'package:flutter/material.dart';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/modules/irisDialog/irisDialog.dart';
import 'package:iris_tools/widgets/text/autoDirection.dart';

import '/system/extensions.dart';
import '/tools/app/appThemes.dart';

//import 'package:rflutter_alert/rflutter_alert.dart';

class DialogCenter {
	static final _instance = DialogCenter._();
	static bool _isInit = false;

	static DialogCenter get instance {
		return _instance;
	}

	static late IrisDialogDecoration _dialogDecoration;

	IrisDialogDecoration get dialogDecoration => _dialogDecoration;

	static void _init(){
		if(!_isInit){
			_prepareDialogDecoration();
			_isInit = true;
		}
	}

	DialogCenter._(){
		_init();
	}

	factory DialogCenter(){
		return _instance;
	}

	static void _prepareDialogDecoration(){
		_dialogDecoration = IrisDialogDecoration();

		Color textColor(){
			if(ColorHelper.isNearColor(AppThemes.currentTheme.dialogBackColor, Colors.white)) {
			  return Colors.black;
			}

			return Colors.white;
		}

		_dialogDecoration.descriptionColor = textColor();
		//_dialogDecoration.titleColor = textColor();
		_dialogDecoration.titleColor = Colors.white;
		_dialogDecoration.titleBackgroundColor = AppThemes.currentTheme.accentColor;
		_dialogDecoration.iconBackgroundColor = Colors.black;
		_dialogDecoration.positiveButtonTextColor = AppThemes.currentTheme.buttonTextColor;
		_dialogDecoration.negativeButtonTextColor = AppThemes.currentTheme.buttonTextColor;
		_dialogDecoration.positiveButtonBackColor = AppThemes.buttonBackgroundColor();
		_dialogDecoration.negativeButtonBackColor = AppThemes.buttonBackgroundColor();
	}
	///============================================================================================================
	Future showDialog(
			BuildContext context,
			{
				String? title,
				String? desc,
				String? yesText,
				Widget? descView,
				Widget? icon,
				Function? yesFn,
				bool dismissOnButtons = true,
				IrisDialogDecoration?	decoration,
			}) {
		return IrisDialog.show(
			context,
			descriptionText: desc,
			descriptionWidget: descView,
      positiveButtonText: yesText?? context.tC('yes')!,
			title: title,
			icon: icon,
			positivePress: (ctx)=> yesFn?.call(),
			dismissOnButtons: dismissOnButtons,
			decoration: decoration ?? DialogCenter.instance.dialogDecoration,
		);
	}

	Future showDialogLargeIcon(
			BuildContext context,
			IconData icon,
			{
				String? title,
				String? desc,
				Widget? descView,
				IrisDialogDecoration?	decoration,
			}) {
		return IrisDialog.show(
			context,
			descriptionText: desc,
			descriptionWidget: descView,
      positiveButtonText: context.tC('yes')!,
			title: title,
			decoration: decoration ?? DialogCenter.instance.dialogDecoration,
			icon: Icon(icon, size: 45),
		);
	}

  Future showYesNoDialog(
			BuildContext context, {
				String? desc,
				Widget? descView,
				String? yesText,
				Function? yesFn,
				String? noText,
				Function? noFn,
				String? title,
				Widget? icon,
				bool dismissOnButtons = true,
				IrisDialogDecoration?	decoration,
		}){

		return IrisDialog.show(
			context,
			descriptionText: desc,
			descriptionWidget: descView,
			positiveButtonText: yesText?? context.tC('yes')!,
			negativeButtonText: noText?? context.tC('no')!,
			title: title,
			decoration: decoration?? DialogCenter.instance.dialogDecoration,
			icon: icon,
			dismissOnButtons: dismissOnButtons,
			positivePress: (ctx)=> yesFn?.call(),
			negativePress: (ctx)=> noFn?.call(),
		);
	}

	Future showTextInputDialog(
			BuildContext context, {
				required Widget descView,
				String? yesText,
				required Function(String txt) yesFn,
				Function(String txt)? onChange,
				String? noText,
				String? initValue,
				Function? noFn,
				String? title,
				Widget? icon,
				bool canDismiss = true,
				TextInputType textInputType = TextInputType.text,
				IrisDialogDecoration?	decoration,
		}){

		final ctr = TextEditingController();

		if(initValue != null){
			ctr.text = initValue;
		}

		onPosClick(){
			final txt = ctr.text;
			yesFn.call(txt);
		}

		final rejectView = Column(
			mainAxisSize: MainAxisSize.min,
			children: [
				descView,
				SizedBox(height: 15,),
				AutoDirection(
						builder: (context, dCtr){
							return TextField(
								controller: ctr,
								textDirection: dCtr.getTextDirection(ctr.text),
								textInputAction: TextInputAction.done,
								keyboardType: textInputType,
								maxLines: 1,
								expands: false,
								onChanged: (t){
									dCtr.onChangeText(t);
									onChange?.call(t);
								},
							);
						}
				),
			],
		);

		final dec = DialogCenter.instance.dialogDecoration.copy();
		dec.negativeButtonBackColor = Colors.transparent;
		dec.negativeButtonTextColor = Colors.black;

		return IrisDialog.show(
			context,
			descriptionWidget: rejectView,
			positiveButtonText: yesText?? context.tC('yes')!,
			negativeButtonText: noText,
			title: title,
			decoration: decoration?? DialogCenter.instance.dialogDecoration,
			icon: icon,
			canDismissible: canDismiss,
			dismissOnButtons: false,
			positivePress: (ctx)=> onPosClick.call(),
			negativePress: noFn != null? (ctx)=> noFn.call() : null,
		);
	}

	void showSuccessDialog(BuildContext context, String? title, String desc) {//shield-check, sticker-check, thump-up
		showDialog(context, title: title, desc: desc, icon: Icon(CommunityMaterialIcons.shield_check, size: 48, color: Colors.green,));
	}

	void showWarningDialog(BuildContext context, String? title, String desc) {
		showDialog(context, title: title, desc: desc, icon: Icon(CommunityMaterialIcons.alert_octagon, size: 48, color: Colors.orange,));
	}

	void showInfoDialog(BuildContext context, String? title, String desc) { //library
		showDialog(context, title: title, desc: desc, icon: Icon(CommunityMaterialIcons.information, size: 48, color: Colors.blue,));
	}

	Future showErrorDialog(BuildContext context, String? title, String desc) { //alert, minus-circle
		return showDialog(context, title: title, desc: desc, icon: Icon(CommunityMaterialIcons.alert, size: 48, color: Colors.redAccent,));
	}
	///============================================================================================================
	Future showDialog$NetDisconnected(BuildContext context) {
		return showErrorDialog(context,
			context.tC('systemMessage')!,
			context.tC('netConnectionIsDisconnect')!,);
	}

	Future<bool> showDialog$wantClose(BuildContext context, {Widget? view}) {
		final x = IrisDialog.show<bool>(
			context,
			descriptionWidget: view?? Text(
          context.tC('wantToLeave')!,
          style: AppThemes.baseTextStyle().copyWith(
            fontSize: 16,
          ),
        ),
      positiveButtonText: context.tC('yes')!,
      negativeButtonText: context.tC('no')!,
			decoration: DialogCenter.instance.dialogDecoration,
			positivePress: (ctx){
				return true;
				//Navigator.of(context).pop<bool>(true);
			},
			negativePress: (ctx)=> false,
		);

		return Future<bool>((){
			return x.then((value) {
				if(value != null) {
				  return value;
				}

				return false;
			});
		});
	}
}
