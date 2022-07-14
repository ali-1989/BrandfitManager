import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/localeHelper.dart';
import 'package:iris_tools/modules/stateManagers/selfRefresh.dart';

import '/abstracts/stateBase.dart';
import '/tools/app/appSizes.dart';
import '/tools/app/appThemes.dart';
import '/views/messageViews/communicationErrorView.dart';
import '/views/messageViews/serverResponseWrongView.dart';
import '/views/preWidgets.dart';

/// AppNavigator.pushNextPage(
/*      context, InputFieldScreen(), name: InputFieldScreen.screenName).then((value) {
          if(value != null){}
      });
*/

/// OverlayScreenView view = OverlayScreenView(
/*     content: InputFieldScreen(),
       routingName: InputFieldScreen.screenName,
       backgroundColor: AppThemes.currentTheme.backgroundColor,
     );

     OverlayDialog().show(context, view).then((value){
      if(value != null){}
     });
*/

///  border: InputBorder.none,
///  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppThemes.currentTheme.textColor)),

///=============================================================================================
typedef ButtonCallBack = void Function(String text);

class ViewState {
  static const state$normal = 'Normal';
  static const state$empty = 'Empty';
  static const state$loading = 'Loading';
  static const state$error = 'Error';
  static const state$serverNotResponse = 'ServerNotResponse';
  static const state$netDisconnect = 'NetIsDisconnect';
  static const state$needLogin = 'NeedLogin';
  static const state$warning = 'Warning';
}
///=============================================================================================

class InputFieldScreen extends StatefulWidget {
  static const String screenName = 'InputFieldScreen';
  final String? title;
  final String? description;
  final String? hint;
  final String? buttonText;
  final TextEditingController? editingController;
  final TextStyle? descriptionStyle;
  final Color? background;
  final InputDecoration? fieldDecorate;
  final Color? appBarColor;
  final double? fieldWith;
  final int? maxLine;
  final double? topOffset;
  final TextInputAction? textInputAction;
  final ButtonCallBack? buttonClick;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final ButtonStyle? buttonStyle;

  InputFieldScreen({
    this.title,
    this.hint,
    this.description,
    this.descriptionStyle,
    this.editingController,
    this.buttonText,
    this.fieldDecorate,
    this.background,
    this.appBarColor,
    this.margin,
    this.padding,
    this.topOffset,
    this.textInputAction,
    this.maxLine,
    this.fieldWith,
    this.buttonClick,
    this.buttonStyle,
    Key? key,
    }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return InputFieldScreenState();
  }
}
///=======================================================================================================
class InputFieldScreenState extends StateBase<InputFieldScreen> {
  String currentViewState = ViewState.state$normal;
  late TextEditingController editCtr;
  late FocusNode focus;
  late Color backColor;
  late InputDecoration inputDecorate;
  late ButtonStyle buttonStyle;

  @override
  void initState() {
    super.initState();

    editCtr = widget.editingController?? TextEditingController();
    backColor = widget.background?? Colors.white;
    focus = FocusNode(canRequestFocus: true, descendantsAreFocusable: false);
    final border = OutlineInputBorder(borderSide: BorderSide(color: AppThemes.currentTheme.textColor));
    inputDecorate = widget.fieldDecorate ?? InputDecoration(
      hintText: t(widget.hint?? ''),
      border: border,
      disabledBorder: border,
      enabledBorder: border,
      focusedBorder: border,
      errorBorder: border,
    );

    buttonStyle = widget.buttonStyle?? ButtonStyle(
      minimumSize: MaterialStateProperty.all(const Size(double.infinity, 40)),
    );

    Future.delayed(const Duration(milliseconds: 700), (){
      focus.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    rotateToPortrait();

    return getScaffold();
  }

  @override
  void dispose() {
    //widget.editingController?.dispose();
    editCtr.dispose();
    super.dispose();
  }

  Widget getScaffold() {
    return WillPopScope(
      onWillPop: () => onWillBack(this),
      child: SizedBox(
        width: AppSizes.getScreenWidth(context),
        height: AppSizes.getScreenHeight(context),
        child: Scaffold(
          backgroundColor: backColor,
          appBar: AppBar(
            backgroundColor: widget.appBarColor,
            title: Text(widget.title?? ''),
            automaticallyImplyLeading: true,
          ),
          body: SafeArea(
            child: getMainBuilder()
          ),
        ),
      ),
    );
  }

  Widget getMainBuilder() {
    return Builder(
      builder: (BuildContext context) {
        switch(currentViewState){
          case ViewState.state$loading:
            return PreWidgets.flutterLoadingWidget$Center();
          case ViewState.state$netDisconnect:
            return CommunicationErrorView(this, tryAgain: tryAgain);
          case ViewState.state$serverNotResponse:
            return ServerResponseWrongView(this, tryAgain: tryAgain);
          default:
            return getBody();
        }
      },
    );
  }

  Widget getBody() {
    return Padding(
      padding: widget.margin?? EdgeInsets.zero,
      child: ListView(
        children: [
          SizedBox(height: widget.topOffset?? 0.0,),

          if(widget.description != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('${widget.description}', style: widget.descriptionStyle,),
            ),

          if(widget.description != null)
            const SizedBox(height: 16),

          Padding(
            padding: widget.padding?? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: widget.fieldWith?? double.infinity,
                        child: SelfRefresh(
                            builder: (context, ctr) {
                              return TextField(
                                  controller: editCtr,
                                  focusNode: focus,
                                  textInputAction: widget.textInputAction?? TextInputAction.done,
                                  textDirection: ctr.getOrDefault('direction', LocaleHelper.autoDirection(editCtr.text)),
                                  minLines: 1,
                                  maxLines: widget.maxLine,
                                  onTap: () {
                                    FocusHelper.fullSelect(editCtr);
                                  },
                                  onChanged: (t){
                                    ctr.set('direction', LocaleHelper.autoDirection(t));
                                    ctr.update();
                                  },
                                  decoration: inputDecorate
                              );
                            }
                        ),
                      ),
                    ),
                  ],
                ),

                if(widget.buttonClick != null)
                  const SizedBox(height: 40,),

                if(widget.buttonClick != null)
                  Align(
                    child: ElevatedButton(
                      style: buttonStyle,
                      child: Text(widget.buttonText?? 'ok'),
                      onPressed: (){
                        FocusHelper.hideKeyboardByUnFocus(context);

                        if(widget.buttonClick != null){
                          widget.buttonClick?.call(editCtr.text);
                        }
                        else {
                          Navigator.of(context).pop(editCtr.text);
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  ///========================================================================================================
  void tryAgain(State state){
    if(state is InputFieldScreenState) {
      currentViewState = ViewState.state$loading;
      update();
    }
  }

}




/*
var content = InputFieldScreen(
      buttonClick: uploadTitle,
      editingController: nameCtr,
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 26),
      hint: t('title'),
      buttonText: tC('apply'),
      title: tC('new', key2: 'title'),
    );

    AppNavigator.pushNextPage(
     context, content, name: InputFieldScreen.screenName).then((value) {
          if(value != null){}
          update();
      });
 */
