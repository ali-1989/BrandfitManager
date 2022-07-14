part of 'registerScreen.dart';

class RegisterScreenP3 extends StatefulWidget {
  static const screenName = 'RegisterScreenP3';
  final RegisterScreenCtr parentCtr;

  RegisterScreenP3(this.parentCtr, {Key? key,}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RegisterScreenP3State();
  }
}
///========================================================================================================
class RegisterScreenP3State extends StateBase<RegisterScreenP3> with AutomaticKeepAliveClientMixin {
  var stateController = StateXController();
  var controller = RegisterScreenP3Ctr();


  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    controller.onInitState(this);
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
    return MaxWidth(
      maxWidth: 380,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: <Widget>[
          const SizedBox(height: 60,),

          FlipInX(
            delay: controller.inputAnimationDelay,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('${tC('gender')}:').bold().fs(16),
                SizedBox(height: AppSizes.fwSize(16),),
                ToggleSwitch(
                  initialLabelIndex: controller.selectedGender,
                  cornerRadius: 12.0,
                  //minWidth: 100,
                  //activeBgColor: AppThemes.isNearColor(AppThemes.currentTheme.primaryColor, Colors.white)? Colors.black: AppThemes.currentTheme.primaryColor,
                  activeBgColor: [AppThemes.currentTheme.activeItemColor],
                  activeFgColor: Colors.white,
                  totalSwitches: 2,
                  textDirectionRTL: true,
                  inactiveBgColor: AppThemes.currentTheme.inactiveBackColor,
                  inactiveFgColor: AppThemes.currentTheme.inactiveTextColor,
                  labels: [tC('male')!, tC('female')!],//, '< ${state.tC('gender')} >'
                  onToggle: (index) {
                    controller.selectedGender = index!;
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 45,),
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

          const SizedBox(height: 10,),
        ],
      ),
    );
  }
///========================================================================================================
}
