part of 'registerScreen.dart';

class RegisterScreenP1 extends StatefulWidget {
  static const screenName = 'RegisterScreenP1';
  final RegisterScreenCtr parentCtr;

  const RegisterScreenP1(this.parentCtr, {Key? key,}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RegisterScreenP1State();
  }
}
///========================================================================================================
class RegisterScreenP1State extends StateBase<RegisterScreenP1> with AutomaticKeepAliveClientMixin {
  StateXController stateController = StateXController();
  RegisterScreenP1Ctr controller = RegisterScreenP1Ctr();

  late BorderRadius inputBorder;
  BoxConstraints inputParentConstraint = BoxConstraints.loose(const Size(500, 70));
  EdgeInsets inputParentPadding = const EdgeInsets.symmetric(horizontal: 4, vertical: 0);
  late BoxDecoration inputParentDecoration;
  late InputDecoration inputDecode;

  //save state in pageView
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    controller.onInitState(this);

    inputBorder = const BorderRadius.all(Radius.circular(10));
    inputParentDecoration = BoxDecoration(
      //color: AppThemes.currentTheme.accentColor.withAlpha(160),
      borderRadius: inputBorder,
      border: Border.all(
        color: AppThemes.currentTheme.textColor.withAlpha(200),
        style: BorderStyle.solid, width: 0.7,
      ),
    );

    inputDecode = ColorTheme.noneBordersInputDecoration;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
      child: SizedBox(
        width: AppSizes.getScreenWidth(context),
        height: AppSizes.getScreenHeight(context),
        child: Scaffold(
          body: SafeArea(child: getMainBuilder()),
        ),
      ),
    );
  }

  Widget getMainBuilder() {
    return StateX(
        isMain: true,
        controller: stateController,
        builder: (context, ctr, data) {
          return getBody();
        }
    );
  }

  Widget getBody(){
    return Form(
        key: controller.formKeyCtr,
        child: MaxWidth(
          maxWidth: 380,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: <Widget>[
              const SizedBox(height: 30,),
              Center(
                child: Text('${tC('pleaseFillOptions')}',
                  style: AppThemes.baseTextStyle().copyWith(
                    fontSize: AppThemes.currentTheme.fontSize + 5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              SizedBox(height: AppSizes.mSize(2),),
              FlipInX(
                delay: controller.inputAnimationDelay,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: (){
                    controller.openSelectCountry();
                  },
                  child: Container(
                    padding: inputParentPadding,
                    constraints: inputParentConstraint,
                    decoration: inputParentDecoration,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(controller.selectedCountry),
                            const RotatedBox(
                                quarterTurns: 2,
                                child: Icon(Icons.arrow_back_ios_rounded, size: 10,)
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: AppSizes.mSize(2),),
              FlipInX(
                delay: controller.inputAnimationDelay,
                child: Container(
                  padding: inputParentPadding,
                  constraints: inputParentConstraint,
                  decoration: inputParentDecoration,
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(controller.selectedCountryCode,),
                        ),

                        Expanded(
                          child: TextFormField(
                            controller: controller.mobileCtl,
                            maxLines: 1,
                            keyboardType: TextInputType.phone,
                            //style: TextStyle(height: 1.1),
                            inputFormatters: [
                              InputFormatter.inputFormatterMobileNumber(),
                              InputFormatter.inputFormatterMaxLen(20),
                            ],
                            //validator: (_) => validation(state, state.mobileCtl),
                            textInputAction: TextInputAction.next,
                            decoration: inputDecode.copyWith(
                              hintText: '${t('mobileNumber')}',
                              //isCollapsed: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: AppSizes.mSize(2),),
              FlipInX(
                delay: controller.inputAnimationDelay,
                child: Container(
                  padding: inputParentPadding,
                  constraints: inputParentConstraint,
                  decoration: inputParentDecoration,
                  child: SelfRefresh(
                    builder: (BuildContext context, UpdateController selfCtr) {
                      return TextFormField(
                        controller: controller.userNameCtl,
                        textDirection: selfCtr.getOrDefault('direction', AppThemes.textDirection),
                        maxLines: 1,
                        validator: (_) => controller.validation(controller.userNameCtl),
                        textInputAction: TextInputAction.next,
                        decoration: inputDecode.copyWith(
                          hintText: '${LocaleCenter.appLocalize.translate('userName')}',
                          labelText: '${LocaleCenter.appLocalize.translate('userName')}',
                        ),
                        onChanged: (t){
                          t = t.trim();
                          t = LocaleHelper.removeNoneViewable(t);

                          if(t.isNotEmpty) {
                            if (LocaleHelper.hasRtlChar(t.substring(0, 1))) {
                              selfCtr.set('direction', TextDirection.rtl);
                            } else {
                              selfCtr.set('direction', TextDirection.ltr);
                            }

                            selfCtr.update();
                          }
                        },
                      );
                    },
                  ),
                ),
              ),

              SizedBox(height: AppSizes.mSize(2),),
              FlipInX(
                delay: controller.inputAnimationDelay,
                child: Container(
                  padding: inputParentPadding,
                  constraints: inputParentConstraint,
                  decoration: inputParentDecoration,
                  child: TextFormField(
                    controller: controller.passwordCtl,
                    maxLines: 1,
                    validator: (_) => controller.validation(controller.passwordCtl),
                    textInputAction: TextInputAction.next,
                    decoration: inputDecode.copyWith(
                      hintText: '${LocaleCenter.appLocalize.translate('password')}',
                      labelText: '${LocaleCenter.appLocalize.translate('password')}',
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: AppSizes.mSize(2),
              ),
              FlipInX(
                delay: controller.inputAnimationDelay,
                child: Container(
                  padding: inputParentPadding,
                  constraints: inputParentConstraint,
                  decoration: inputParentDecoration,
                  child: TextFormField(
                    controller: controller.password2Ctl,
                    maxLines: 1,
                    validator: (_) => controller.validation(controller.password2Ctl),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).unfocus();
                    },
                    decoration: inputDecode.copyWith(
                      hintText: '${LocaleCenter.appLocalize.translate('repeatPassword')}',
                      labelText: '${LocaleCenter.appLocalize.translate('repeatPassword')}',
                      //filled: true,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25,),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${tC("youHaveAnAccount")}',
                      style: AppThemes.infoTextStyle(),
                    ),

                    const SizedBox(width: 6,),

                    InkWell(
                      onTap: controller.clickOnHaveAccount,
                      child: Text(
                        '${LocaleCenter.appLocalize.translateCapitalize('login')}',
                        style: AppThemes.currentTheme.textUnderlineStyle,
                      ),
                    ),
                  ]
              ),

              const SizedBox(height: 25,),

              /*MaxWidth(
                maxWidth: 500,
                child: FractionallySizedBox(
                  widthFactor: 0.7,
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      controller.gotoPage2();
                    },
                    child: Text(t('next')!),
                  ),
                ),
              ),*/

              Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                    onPressed: () {
                      controller.gotoNextPage();
                    },
                    child: Text(t('next')!),
                  )
                  ),
                ],
              ),

              const SizedBox(height: 10,),
            ],
          ),
        )
    );
  }
  ///========================================================================================================
}


