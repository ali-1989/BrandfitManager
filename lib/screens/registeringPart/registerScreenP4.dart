part of 'registerScreen.dart';

class RegisterScreenP4 extends StatefulWidget {
  static const screenName = 'RegisterScreenP4';
  final RegisterScreenCtr parentCtr;

  RegisterScreenP4(this.parentCtr, {Key? key,}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RegisterScreenP4State();
  }
}
///========================================================================================================
class RegisterScreenP4State extends StateBase<RegisterScreenP4> with AutomaticKeepAliveClientMixin {
  var stateController = StateXController();
  var controller = RegisterScreenP4Ctr();

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
          body: SafeArea(
          child: getMainBuilder()
          ),
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
          SizedBox(height: AppSizes.fwSize(50),),
          Text('${tC('descriptionSelectBirthDate')}:',
            style: TextStyle(fontSize: AppSizes.fwFontSize(16)),
          ).bold().infoColor(),
          SizedBox(height: AppSizes.fwSize(20),),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${tInMap('registeringPage' ,'yourAge')}: ').bold().fsR(2),
                  Text('${controller.age}').bold().fsR(2).color(AppThemes.currentTheme.infoColor),
                ],
              ),

              SizedBox(
                height: 46,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        //borderRadius: BorderRadius.circular(10),
                        dropdownColor: Colors.grey[400],
                        value: SettingsManager.settingsModel.calendarType,
                        onChanged: (newValue) {
                          controller.changeCalendar(newValue as CalendarType);

                          stateController.updateMain();
                        },
                        items: DateTools.calendarList.map((cal) => DropdownMenuItem(
                          value: cal,
                          child: Text('${tInMap('calendarOptions', cal.name)}'),
                        ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.fwSize(15),),

          FlipInX(
            delay: controller.inputAnimationDelay,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  //width: AppSizes.rSize(90),
                  height: AppSizes.fwSize(120),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    textDirection: TextDirection.ltr,
                    children: [
                      ///--- year
                      NumberPicker(
                        minValue: DateTools.calMinBirthdateYear(),
                        maxValue: DateTools.calMaxBirthdateYear(),
                        value: controller.selectedYear,
                        axis: Axis.vertical,
                        textStyle: AppThemes.baseTextStyle().copyWith(
                          fontSize: AppSizes.fwFontSize(16),
                          fontWeight: FontWeight.bold,
                        ),
                        selectedTextStyle: TextStyle(
                          fontSize: AppSizes.fwFontSize(16),
                          fontWeight: FontWeight.bold,
                          color: AppThemes.currentTheme.activeItemColor,
                        ),
                        haptics: true,
                        zeroPad: true,
                        itemHeight: 40,
                        itemWidth: 60,
                        textMapper: (t){
                          return t.toString().localeNum();
                        },
                        onChanged: (val){
                          controller.selectedYear = val;
                          controller.calcBirthdate();
                          stateController.updateMain();
                        },
                      ),

                      ///--- month
                      SizedBox(
                        width: AppSizes.fwSize(60),
                        child: NumberPicker(
                          minValue: 1,
                          maxValue: 12,
                          value: controller.selectedMonth,
                          axis: Axis.vertical,
                          textStyle: AppThemes.baseTextStyle().copyWith(
                            fontSize: AppSizes.fwFontSize(15),
                            fontWeight: FontWeight.bold,
                          ),
                          selectedTextStyle: TextStyle(
                            fontSize: AppSizes.fwFontSize(16),
                            fontWeight: FontWeight.bold,
                            color: AppThemes.currentTheme.activeItemColor,//AppThemes.checkPrimaryByWB(AppThemes.currentTheme.primaryColor, AppThemes.currentTheme.differentColor),
                          ),
                          haptics: true,
                          zeroPad: true,
                          itemHeight: 40,
                          itemWidth: 40,
                          infiniteLoop: true,
                          textMapper: (t){
                            return t.toString().localeNum();
                          },
                          onChanged: (val){
                            controller.selectedMonth = val;
                            controller.calcBirthdate();
                            stateController.updateMain();
                          },
                        ),
                      ),

                      ///--- day
                      SizedBox(
                        width: AppSizes.fwSize(60),
                        child: NumberPicker(
                          minValue: 1,
                          maxValue: controller.maxDayOfMonth,
                          value: controller.selectedDay,
                          axis: Axis.vertical,
                          textStyle: AppThemes.baseTextStyle().copyWith(
                            fontSize: AppSizes.fwFontSize(15),
                            fontWeight: FontWeight.bold,
                          ),
                          selectedTextStyle: TextStyle(
                            fontSize: AppSizes.fwFontSize(16),
                            fontWeight: FontWeight.bold,
                            color: AppThemes.currentTheme.activeItemColor,
                          ),
                          haptics: true,
                          zeroPad: true,
                          itemHeight: 40,
                          itemWidth: 40,
                          infiniteLoop: true,
                          textMapper: (t){
                            return t.toString().localeNum();
                          },
                          onChanged: (val){
                            controller.selectedDay = val;
                            controller.calcBirthdate();
                            stateController.updateMain();
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),

          SizedBox(height: AppSizes.fwSize(20),),

          /*Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.translate(
                offset: Offset(0, -6),
                child: Checkbox(
                  value: controller.isAcceptTerms,
                  onChanged: (v){
                    controller.isAcceptTerms = v?? false;
                    stateController.updateMain();
                  },
                ),
              ),

              Expanded(
                child: ParsedText(
                  text: tInMap('registeringPage', 'myAcceptTerm&Conditions')!,
                  style: AppThemes.infoTextStyle(),
                  parse: [
                    MatchText(
                        pattern: 'XX',
                        type: ParsedType.CUSTOM,
                        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                        renderText: ({required String str, required String pattern}) {
                          Map<String, String> res = {};
                          res['display'] = tInMap('registeringPage', 'term&Conditions')!;
                          res['value'] = '-';
                          return res;
                        },
                        onTap: (url){
                          AppNavigator.pushNextPage(context, TermScreen(), name: 'TermScreen');
                        }
                    ),
                  ],
                  selectable: false,
                ),
              ),
            ],
          ),*/

          const SizedBox(height: 40,),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    controller.gotoNextPage();
                  },
                  child: Text(tC('register')!),
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