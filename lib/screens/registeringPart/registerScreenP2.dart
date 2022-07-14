part of 'registerScreen.dart';

class RegisterScreenP2 extends StatefulWidget {
  static const screenName = 'RegisterScreenP2';
  final RegisterScreenCtr parentCtr;

  const RegisterScreenP2(this.parentCtr, {Key? key,}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RegisterScreenP2State();
  }
}
///========================================================================================================
class RegisterScreenP2State extends StateBase<RegisterScreenP2> with AutomaticKeepAliveClientMixin {
  var stateController = StateXController();
  var controller = RegisterScreenP2Ctr();

  late BorderRadius inputBorder;
  var inputParentConstraint = BoxConstraints.loose(Size(500, 70));
  var inputParentPadding = EdgeInsets.symmetric(horizontal: 4, vertical: 0);
  late BoxDecoration inputParentDecoration;
  late InputDecoration inputDecode;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    controller.onInitState(this);

    inputBorder = BorderRadius.all(Radius.circular(10));
    inputParentDecoration = BoxDecoration(
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

  getMainBuilder() {
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
            padding: EdgeInsets.symmetric(horizontal: 20),
            children: <Widget>[
              SizedBox(height: 60,),
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
                child: Container(
                  padding: inputParentPadding,
                  constraints: inputParentConstraint,
                  decoration: inputParentDecoration,
                  child: TextFormField(
                    controller: controller.nameCtl,
                    maxLines: 1,
                    validator: (_) => controller.validation(controller.nameCtl),
                    textInputAction: TextInputAction.next,
                    decoration: inputDecode.copyWith(
                      hintText: '${LocaleCenter.appLocalize.translate('name')}',
                      labelText: '${LocaleCenter.appLocalize.translate('name')}',
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
                  child: TextFormField(
                    controller: controller.familyCtl,
                    maxLines: 1,
                    validator: (_) => controller.validation(controller.familyCtl),
                    textInputAction: TextInputAction.next,
                    decoration: inputDecode.copyWith(
                      hintText: '${LocaleCenter.appLocalize.translate('family')}',
                      labelText: '${LocaleCenter.appLocalize.translate('family')}',
                    ),
                  ),
                ),
              ),

              SizedBox(height: 45,),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.gotoNextPage();
                      },
                      child: Text(tC('next')!),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10,),
            ],
          ),
        )
    );
  }
  ///========================================================================================================
}
