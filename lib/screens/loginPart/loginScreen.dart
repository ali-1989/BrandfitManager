import 'package:flutter/material.dart';

import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';
import 'package:iris_tools/widgets/text/autoDirection.dart';

import '/abstracts/stateBase.dart';
import '/screens/loginPart/loginScreenCtr.dart';
import '/tools/app/appSizes.dart';
import '/tools/app/appThemes.dart';
import '/tools/centers/localeCenter.dart';

class LoginScreen extends StatefulWidget {
  static const screenName = '/login_page';

  LoginScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LoginScreenState();
  }
}
///=======================================================================================================
class LoginScreenState extends StateBase<LoginScreen> {
  StateXController stateController = StateXController();
  LoginScreenCtr controller = LoginScreenCtr();

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
    super.dispose();
  }

  Widget getScaffold() {
    return WillPopScope(
      onWillPop: () => onWillBack(this),
      child: Scaffold(
        key: scaffoldKey,
        //resizeToAvoidBottomPadding: false, deprecate
        //resizeToAvoidBottomInset: false,
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
      title: Text(tC('login')!),
      /*actions: const <Widget>[
        (ModalRoute.of(state.context)?.canPop ?? false)?
        IconButton(
          onPressed: () => state.onBackButton(state),
          icon: (System.isAndroid()) ?
            Icon(Icons.arrow_back, textDirection: AppThemes.getOppositeDirection(),) :
            Icon(Icons.arrow_back_ios, textDirection: AppThemes.getOppositeDirection(),),
        )
        : SizedBox(height: 0, width: 0,),
      ],*/
    );
  }

  Widget getBody() {
    return DecoratedBox(
      decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login.jpg'),
            fit: BoxFit.fill,
            //colorFilter: ColorFilter.mode(AppThemes.currentTheme.primaryColor, BlendMode.color),
          )
      ),

      child: ListView(
        padding: const EdgeInsets.all(5.0),
        children: <Widget>[
          const SizedBox(height: 70,),
          Center(
            child: AutoSizeText(
              '${LocaleCenter.appLocalize.translateCapitalize('loginDescription')}',
              style: AppThemes.baseTextStyle().copyWith(
                  color: Colors.white,
                  fontSize: AppSizes.fwFontSize(25)
              ),
              strutStyle: AppThemes.strutStyle,
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 30,),

          /// ---------------------------------- form
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            duration: const Duration(seconds: 1),
            child: Align(
              child: ConstrainedBox(
                constraints: BoxConstraints.loose(const Size(400, double.infinity)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22.0),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 10,),

                        /// text fields
                        Column(
                          children: <Widget>[
                            /// username section
                            Container(
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.white)),
                              ),
                              child: AutoDirection(
                                  builder: (context, dCtr) {
                                    return TextFormField(
                                      controller: controller.userNameCtl,
                                      textDirection: dCtr.getTextDirection(controller.userNameCtl.text),
                                      validator: (_) => controller.validation(controller.userNameCtl),
                                      textInputAction: TextInputAction.next,
                                      style: AppThemes.baseTextStyle().copyWith(
                                        color: Colors.white,
                                      ),
                                      onTap: () {
                                        dCtr.manageSelection(controller.userNameCtl);
                                      },
                                      onChanged: (t){
                                        dCtr.onChangeText(t);
                                      },
                                      decoration: InputDecoration(
                                        hintText: '${t('userName', key2: 'or', key3: 'mobileNumber')}',
                                        border: InputBorder.none,
                                        hintStyle: const TextStyle(color: Colors.white),
                                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                                        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                                      ),
                                    );
                                  }
                              ),
                            ),

                            /// password section
                            Container(
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.white)),
                              ),
                              child: AutoDirection(
                                  builder: (context, dCtr) {
                                    return TextFormField(
                                      controller: controller.passwordCtl,
                                      textDirection: dCtr.getTextDirection(controller.passwordCtl.text),
                                      textInputAction: TextInputAction.done,
                                      obscureText: true,
                                      validator: (_) => controller.validation(controller.passwordCtl),
                                      style: AppThemes.baseTextStyle().copyWith(
                                        color: Colors.white,
                                      ),
                                      onTap: () {
                                        dCtr.manageSelection(controller.passwordCtl);
                                      },
                                      onChanged: (t){
                                        dCtr.onChangeText(t);
                                      },
                                      onFieldSubmitted: (_) {
                                        final c1 = controller.userNameCtl.text.isNotEmpty;
                                        final c2 = controller.passwordCtl.text.isNotEmpty;

                                        if(c1 & c2){
                                          controller.requestLogin();
                                        }
                                      },
                                      decoration: InputDecoration(
                                        hintText: '${LocaleCenter.appLocalize.translate('password')}',
                                        border: InputBorder.none,
                                        hintStyle: const TextStyle(color: Colors.white),
                                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                                        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                                      ),
                                    );
                                  }
                              ),
                            ),
                          ],
                        ),

                        /// buttons
                        const SizedBox(height: 50,),
                        TextButton(
                          onPressed: () => controller.forgetPasswordBtn(),
                          style: ButtonStyle(
                            splashFactory: NoSplash.splashFactory,
                            textStyle: MaterialStateProperty.all(AppThemes.baseTextStyle().copyWith(
                              fontSize: AppSizes.mTextSize(2.0),
                              color: Colors.white,
                              decorationColor: Colors.white,
                              decoration: TextDecoration.underline,
                            )),
                            backgroundColor: MaterialStateProperty.all(Colors.transparent),
                            foregroundColor: MaterialStateProperty.resolveWith((states) {
                              const interactiveStates = <MaterialState>{
                                MaterialState.selected,
                                MaterialState.pressed,
                                MaterialState.hovered,
                                MaterialState.focused,
                                MaterialState.dragged,
                              };

                              if (states.any(interactiveStates.contains)) {
                                return AppThemes.currentTheme.primaryColor;
                              }

                              return Colors.white;
                            }),
                          ),
                          child: Text('${tC('forgotPassword')}',
                            strutStyle: AppThemes.strutStyle,
                          ),
                        ),

                        const SizedBox(height: 10,),
                        TextButton(
                          onPressed: () => controller.registerBtn(),
                          style: ButtonStyle(
                            splashFactory: NoSplash.splashFactory,
                            textStyle: MaterialStateProperty.all(AppThemes.baseTextStyle().copyWith(
                              fontSize: AppSizes.mTextSize(2.0),
                              color: Colors.white,
                              decorationColor: Colors.white,
                              decoration: TextDecoration.underline,
                            )),
                            backgroundColor: MaterialStateProperty.all(Colors.transparent),
                            foregroundColor: MaterialStateProperty.resolveWith((states) {
                              const interactiveStates = <MaterialState>{
                                MaterialState.selected,
                                MaterialState.pressed,
                                MaterialState.hovered,
                                MaterialState.focused,
                                MaterialState.dragged,
                              };

                              if (states.any(interactiveStates.contains)) {
                                return AppThemes.currentTheme.primaryColor;
                              }

                              return Colors.white;
                            }),
                          ),
                          child: Text('${tC('createAccount')}',
                            strutStyle: AppThemes.strutStyle,
                          ),
                        ),

                        const SizedBox(height: 20,),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                child: Text('${LocaleCenter.appLocalize.translateCapitalize('login')}'),
                                onPressed: () => controller.requestLogin(),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20,),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  ///=======================================================================================================
}





