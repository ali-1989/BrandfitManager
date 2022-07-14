import 'package:flutter/material.dart';

import 'package:animate_do/animate_do.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:iris_tools/api/helpers/inputFormatter.dart';
import 'package:iris_tools/api/helpers/localeHelper.dart';
import 'package:iris_tools/dateSection/ADateStructure.dart';
import 'package:iris_tools/dateSection/calendarTools.dart';
import 'package:iris_tools/models/dataModels/colorTheme.dart';
import 'package:iris_tools/widgets/maxWidth.dart';
import 'package:iris_tools/modules/stateManagers/selfRefresh.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '/abstracts/stateBase.dart';
import '/managers/settingsManager.dart';
import '/screens/commons/countrySelect.dart';
import '/screens/registeringPart/registerScreenCtr.dart';
import '/screens/registeringPart/registerScreenP1Ctr.dart';
import '/screens/registeringPart/registerScreenP2Ctr.dart';
import '/screens/registeringPart/registerScreenP3Ctr.dart';
import '/screens/registeringPart/registerScreenP4Ctr.dart';
import '/screens/registeringPart/verifyMobileScreen.dart';
import '/system/extensions.dart';
import '/system/keys.dart';
import '/tools/app/appNavigator.dart';
import '/tools/app/appSizes.dart';
import '/tools/app/appThemes.dart';
import '/tools/centers/localeCenter.dart';
import '/tools/dateTools.dart';

part 'registerScreenP1.dart';
part 'registerScreenP2.dart';
part 'registerScreenP3.dart';
part 'registerScreenP4.dart';

class RegisterScreen extends StatefulWidget {
  static const screenName = '/register_page';

  const RegisterScreen({Key? key,}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RegisterScreenState();
  }
}
///========================================================================================================
class RegisterScreenState extends StateBase<RegisterScreen> {
  var stateController = StateXController();
  var controller = RegisterScreenCtr();
  

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

  @override
  Future<bool> onWillBack<S extends StateBase>(S state) {
    RegisterScreenState mState = state as RegisterScreenState;

    if (controller.pageController.page!.round() == 0) {
      return super.onWillBack(mState);
    }

    controller.pageController.jumpToPage(controller.pageController.page!.round() - 1);
    return Future<bool>.value(false);
  }

  Widget getScaffold() {
    return WillPopScope(
      onWillPop: () => onWillBack(this),
      child: SizedBox(
        width: AppSizes.getScreenWidth(context),
        height: AppSizes.getScreenHeight(context),
        child: Scaffold(
          appBar: AppBar(title: Text(tC('register')!),),
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

  Widget getBody(){
    /*return Navigator(
      key: state.internalNavKey,
      onGenerateRoute: (rs) {
        return MaterialPageRoute(builder: (ctx) => RegisterScreenP1(state), settings: RouteSettings(name: 'registerP1'));
      },
    );*/
    return PageView(
      controller: controller.pageController,
      pageSnapping: true,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        RegisterScreenP1(controller),
        RegisterScreenP2(controller),
        RegisterScreenP3(controller),
        RegisterScreenP4(controller),
      ],
    );
  }
  ///========================================================================================================
  Widget getMobileView(BuildContext ctx){
    String mobile = stateController.objectOrDefault(Keys.mobileNumber, '0');
    String pre = stateController.objectOrDefault(Keys.phoneCode, '0');

    return Positioned(
      top: 0, left: 0, right: 0,
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Row(
              textDirection: AppThemes.getOppositeDirection(),
              children: [
                Flash(
                  child: ElevatedButton(
                    child: Text(context.tC('sendVerifyCode')!),
                    onPressed: () {
                      AppNavigator.pushNextPage(context, VerifyMobileScreen(mobile, pre), name: 'VerifyMobile');
                    },
                  ),
                ),
              ]
          ),
        ),
      ),
    );
  }
}

