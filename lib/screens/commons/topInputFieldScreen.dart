import 'package:flutter/material.dart';

import 'package:animate_do/animate_do.dart';

import '/abstracts/stateBase.dart';
import '/system/icons.dart';
import '/tools/app/appSizes.dart';
import '/tools/app/appThemes.dart';
import '/views/messageViews/communicationErrorView.dart';
import '/views/messageViews/serverResponseWrongView.dart';
import '/views/preWidgets.dart';

/// AppNavigator.pushNextTransparentPage(
//      context, TopInputFieldScreen(), name: TopInputFieldScreen.screenName).then((value) {
//          if(value != null){}
//      });

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
///================================================================================================
class TopInputFieldScreen extends StatefulWidget {
  static const screenName = 'TopInputFieldScreen';
  final String? title;
  final String? description;
  final String? hint;
  final String? buttonText;
  final TextEditingController? editingController;
  final Color? background;
  final Color? fieldBackground;
  final Color? appBarColor;
  final double? fieldWith;
  final int? maxLine;
  final double? topOffset;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final ButtonCallBack? buttonClick;
  final EdgeInsets? padding;

  TopInputFieldScreen({
    this.title,
    this.description,
    this.hint,
    this.editingController,
    this.buttonText,
    this.fieldBackground,
    this.background,
    this.appBarColor,
    this.padding,
    this.topOffset,
    this.textInputAction,
    this.textInputType,
    this.maxLine,
    this.fieldWith,
    this.buttonClick,
    Key? key,
    }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TopInputFieldScreenState();
  }
}
///================================================================================================
class TopInputFieldScreenState extends StateBase<TopInputFieldScreen> {
  String currentViewState = ViewState.state$normal;
  late TextEditingController editCtr;
  late FocusNode focus;
  late Color backColor;

  @override
  void initState() {
    super.initState();

    editCtr = widget.editingController?? TextEditingController();
    backColor = widget.background?? Colors.black.withAlpha(60);
    focus = FocusNode(canRequestFocus: true, descendantsAreFocusable: false);

    Future.delayed(const Duration(milliseconds: 600), (){
      focus.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    rotateToPortrait();

    return getScaffold(this);
  }

  @override
  void dispose() {
    //widget.editingController?.dispose();
    editCtr.dispose();
    super.dispose();
  }

  ///=======================================================================================================
  Widget getScaffold(TopInputFieldScreenState state) {
    return WillPopScope(
      onWillPop: () => state.onWillBack(state),
      child: SizedBox(
        width: AppSizes.getScreenWidth(state.context),
        height: AppSizes.getScreenHeight(state.context),
        child: Scaffold(
          backgroundColor: state.backColor,
          appBar: AppBar(
            backgroundColor: state.widget.appBarColor,
            title: Text(state.widget.title?? ''),
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(IconList.checkM),
              onPressed: (){
                if(state.widget.buttonClick != null){
                  state.widget.buttonClick?.call(state.editCtr.text);
                }
                else {
                  Navigator.of(state.context).pop(state.editCtr.text);
                }
              },
            ),
            actions: [
              IconButton(
                icon: Icon(IconList.close),
                onPressed: (){
                  Navigator.of(state.context).pop();
                },
              ),
            ],
          ),
          body: SafeArea(child: getBuilder(state)),
        ),
      ),
    );
  }
  ///========================================================================================================
  Widget getBuilder(TopInputFieldScreenState state) {
    return Builder(
      builder: (BuildContext context) {
        switch(state.currentViewState){
          case ViewState.state$loading:
            return PreWidgets.flutterLoadingWidget$Center();
          case ViewState.state$netDisconnect:
            return CommunicationErrorView(state, tryAgain: tryAgain);
          case ViewState.state$serverNotResponse:
            return ServerResponseWrongView(state, tryAgain: tryAgain);
          default:
            return getBody(state);
        }
      },
    );
  }
  ///========================================================================================================
  Widget getBody(TopInputFieldScreenState state) {
    final border = OutlineInputBorder(borderSide: BorderSide(color: AppThemes.currentTheme.textColor));

    return SlideInDown(
      child: ColoredBox(
        color: state.widget.fieldBackground?? AppThemes.currentTheme.backgroundColor,
        child: Padding(
          //padding: state.widget.margin?? EdgeInsets.zero,
          padding: state.widget.padding?? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
          child: ListView(
            shrinkWrap: true,
            children: [
              SizedBox(height: state.widget.topOffset?? 10.0,),

              if(widget.description != null)
                Text('${widget.description}'),
              if(widget.description != null)
                const SizedBox(height: 10.0,),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      width: state.widget.fieldWith?? double.infinity,
                      child: TextField(
                        controller: state.editCtr,
                        focusNode: state.focus,
                        textInputAction: state.widget.textInputAction?? TextInputAction.done,
                        keyboardType: state.widget.textInputType?? TextInputType.name,
                        minLines: 1,
                        maxLines: state.widget.maxLine,
                        decoration: InputDecoration(
                          hintText: state.t(state.widget.hint?? ''),
                          border: border,
                          disabledBorder: border,
                          enabledBorder: border,
                          focusedBorder: border,
                          errorBorder: border,
                        ),
                      ),
                    ),
                  ),

                  if(state.widget.buttonClick != null)
                    const SizedBox(width: 30,),

                  if(state.widget.buttonClick != null)
                    ElevatedButton(
                      child: Text(state.widget.buttonText?? 'ok'),
                      onPressed: (){
                        //FocusHelper.hideKeyboardByUnFocus(state.context);
                        state.widget.buttonClick?.call(state.editCtr.text);
                      },
                    ),
                ],
              ),

              const SizedBox(height: 30,),
            ],
          ),
        ),
      ),
    );
  }
  ///========================================================================================================
  void tryAgain(State state){
    if(state is TopInputFieldScreenState) {
      state.currentViewState = ViewState.state$loading;
      state.update();
    }
  }
}
