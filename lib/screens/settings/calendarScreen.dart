import 'package:flutter/material.dart';

import 'package:community_material_icon/community_material_icon.dart';
import 'package:iris_tools/dateSection/calendarTools.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import '/abstracts/stateBase.dart';
import '/managers/settingsManager.dart';
import '/screens/settings/settingsScreen.dart';
import '/system/extensions.dart';
import '/tools/app/appNavigator.dart';
import '/tools/app/appSizes.dart';
import '/tools/app/appThemes.dart';
import '/tools/dateTools.dart';

class CalendarScreen extends StatefulWidget {
  static const screenName = 'CalendarScreen';

  CalendarScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CalendarScreenState();
  }
}
///========================================================================================================
class CalendarScreenState extends StateBase<CalendarScreen> {
  late SettingsScreenState parentState;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    rotateToPortrait();
    parentState = AppNavigator.getArgumentsOf(context) as SettingsScreenState;

    return getScaffold(this);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget getScaffold(CalendarScreenState state) {

    return WillPopScope(
      onWillPop: () => state.onWillBack(state),
      child: Scaffold(
        key: state.scaffoldKey,
        appBar: getAppbar(state),
        body: getBody(state),
      ),
    );
  }

  getAppbar(CalendarScreenState state) {
    return AppBar(
      title: Text(state.context.tC('calendar')!),
    );
  }

  getBody(CalendarScreenState state) {
    String today = state.tC('today')!;

    return SizedBox(
      width: AppSizes.getScreenWidth(state.context),
      height: AppSizes.getScreenHeight(state.context),

      child: ListView(
          children: [
            UnconstrainedBox(
              alignment: AlignmentDirectional.centerStart,
              child: ConstrainedBox(
                constraints: BoxConstraints.loose(const Size(800, double.infinity)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Card(
                    shape: RoundedRectangleBorder(side: const BorderSide(width: 1.6), borderRadius: BorderRadius.circular(5.0)),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Text('$today: ${DateTools.dateRelativeByAppFormat(DateHelper.getNow())}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        )
                    ),
                  ),
                ),
              ),
            ),
            /// --------------------------------------------- Calendar
            parentState.genHeader(state.tC('calendar')!),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints.loose(const Size(800, double.infinity)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                    child:Card(
                      color: AppThemes.currentTheme.accentColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                            child: Row(
                                children: <Widget>[
                                  const Icon(CommunityMaterialIcons.gamepad, size: 18,).whiteOrAppBarItemOnPrimary(),
                                  const SizedBox(width: 5,),
                                  Text(state.tC('chooseYourCalendarType')!, textScaleFactor: 1.2 ,).whiteOrAppBarItemOnPrimary(),]
                            ),
                          ),

                          const SizedBox(height: 5,),

                          Column(
                            children: getCalendarItems(state),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            /// --------------------------------------------- Format
            parentState.genHeader(state.tC('format')!),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints.loose(const Size(800, double.infinity)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                    child:Card(
                      color: AppThemes.currentTheme.accentColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                            child: Row(
                                children: <Widget>[
                                  const Icon(CommunityMaterialIcons.gamepad, size: 18,).whiteOrAppBarItemOnPrimary(),
                                  const SizedBox(width: 5,),
                                  Text(state.tC('selectDateDisplayFormat')!, textScaleFactor: 1.2 ,).whiteOrAppBarItemOnPrimary(),]
                            ),
                          ),

                          const SizedBox(height: 5,),

                          Column(
                            children: getFormatItems(state),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          ]
      ),
    );
  }
  ///========================================================================================================
  List<Widget> getCalendarItems(CalendarScreenState state){
    List<Widget> res = [];
    List<CalendarType> cal = DateTools.calendarList;

    for(var i in cal){
      Row r = Row(
        children: [
          Radio(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            groupValue: SettingsManager.settingsModel.calendarType,
            value: i,
            onChanged: (val) {
              DateTools.saveAppCalendar((val! as CalendarType), context: state.context);
              state.update();
              state.updateParent();
            },
          ).intelliWhite(),

          Text('${tInMap('calendarOptions', i.name)}').whiteOrAppBarItemOnPrimary(),
        ],
      );

      res.add(r);
    }

    return res;
  }

  List<Widget> getFormatItems(CalendarScreenState state){
    List<Widget> res = [];
    List<String> cal = DateTools.dateFormats;

    for(var i in cal){
      var now = DateTime.now();

      Row r = Row(
        children: [
          Radio(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            groupValue: SettingsManager.settingsModel.dateFormat,
            value: i,
            onChanged: (val) {
              SettingsManager.settingsModel.dateFormat = val! as String;
              state.update();
              state.updateParent();
              SettingsManager.saveSettings(context: state.context);
            },
          ).intelliWhite(),

          Text(DateTools.dateRelativeByAppFormat(now, format: i, isUtc: false)).whiteOrAppBarItemOnPrimary(),
        ],
      );

      res.add(r);
    }

    return res;
  }
}



