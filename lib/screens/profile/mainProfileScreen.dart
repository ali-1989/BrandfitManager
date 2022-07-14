import 'package:flutter/material.dart';

import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:iris_tools/modules/propertyNotifier/propertyChangeConsumer.dart';
import 'package:iris_tools/widgets/attribute.dart';
import 'package:iris_tools/widgets/icon/circularIcon.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';

import '/abstracts/stateBase.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/screens/profile/mainProfileCtr.dart';
import '/screens/profile/personalInfoScreen.dart';
import '/system/extensions.dart';
import '/system/icons.dart';
import '/tools/app/appNavigator.dart';
import '/tools/app/appSizes.dart';
import '/tools/app/appThemes.dart';
import '/views/loadingScreen.dart';

class UserProfileScreen extends StatefulWidget {
  static final screenName = 'UserProfileScreen';

  UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UserProfileScreenState();
  }
}
///=====================================================================================
class UserProfileScreenState extends StateBase<UserProfileScreen> {
  StateXController stateController = StateXController();
  MainProfileCtr controller = MainProfileCtr();

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
    stateController.dispose();
    controller.onDispose();

    super.dispose();
  }

  Widget getScaffold() {
    return WillPopScope(
      onWillPop: () => onWillBack(this),
      child: SizedBox(
        width: AppSizes.getScreenWidth(context),
        height: AppSizes.getScreenHeight(context),
        child: Scaffold(
          key: scaffoldKey,
          appBar: getAppbar(),
          body: getBuilder(),
        ),
      ),
    );
  }
  
  PreferredSizeWidget getAppbar() {
    return AppBar(
      title: Text(tC('profile')!),
    );
  }

  Widget getBuilder(){
    return StateX(
      controller: stateController,
      isMain: true,
        builder: (ctx, ctr, data){
          return getBody();
    });
  }

  Widget getBody() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [

        SizedBox(
          width: AppSizes.getScreenWidth(context),
          height: 120,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Attribute(
                  controller: controller.popMenuAtt,
                  childBuilder:(ctx, ctr){
                    return PropertyChangeConsumer<UserModel, UserModelNotifierMode>(
                      model: controller.user,
                      onAnyInstance: true,
                      properties: [UserModelNotifierMode.profilePath],
                      builder: (context, model, property){
                        if(model?.profileProvider != null) {
                          if(controller.isLoadingShow) {
                            controller.isLoadingShow = false;

                            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                              LoadingScreen.hideLoading(context);
                            });//dont remove
                          }

                          return GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            excludeFromSemantics: true,
                            onTap: (){
                              controller.showAvatarPic();
                            },
                            child: Hero(
                                tag: 'profileHero',
                                child: CircleAvatar(backgroundImage: model!.profileProvider, radius: 50,)
                            ),
                          );
                        }

                        return const Icon(Icons.account_circle, size: 110,);
                      },
                    );
                  },
                ),

                Align(
                  alignment: AlignmentDirectional.topStart,
                  child: Transform.translate(
                    offset: Offset(AppThemes.isLtrDirection()?-12:12, 10),
                    child: CircularIcon(
                      icon: Icons.add,
                      backColor: AppThemes.currentTheme.fabBackColor,
                      itemColor: AppThemes.currentTheme.fabItemColor,
                      padding: 8,
                    ).wrapMaterial(
                      onTapDelay: (){controller.showAvatarMenu();},
                    ),
                  ),
                ),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AutoSizeText(
                        controller.user.nameFamily,
                        maxLines: 1,
                        wrapWords: false,
                        softWrap: false,
                        overflow: TextOverflow.clip,
                        style: AppThemes.baseTextStyle().copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: AppThemes.baseTextStyle().fontSize! +4,
                        ),
                      ),

                      const SizedBox(height: 8,),

                      AutoSizeText(
                        controller.user.userName,
                        maxLines: 1,
                        wrapWords: false,
                        softWrap: false,
                        overflow: TextOverflow.clip,
                        style: AppThemes.baseTextStyle().copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            children: <Widget>[
              ///------- personalInformation     Icons.account_box_outlined
              genListItem(IconList.accountTie, '${tC('personalInformation')}', (){
                AppNavigator.pushNextPage(context, PersonalInfoScreen(), name: PersonalInfoScreen.screenName).then((value){
                  update();
                });
              }),

              ],
            ),
          ),
        ],
    );
  }
  ///========================================================================================================
  Widget genListItem(IconData icon, String title, Function onPress){
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: AppThemes.currentTheme.fabBackColor.withAlpha(150),
          width: 0.8,
        ),
      ),
      child: InkWell(
        onTap: (){onPress.delay().then((value) => value.call());},
        splashColor: AppThemes.currentTheme.fabBackColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          child: Row(
            children: [
              CircularIcon(
                icon: icon,
                size: 32,
                itemColor: AppThemes.currentTheme.fabBackColor,
                backColor: AppThemes.currentTheme.fabBackColor.withAlpha(70),
              ),
              const SizedBox(width: 16,),
              Text(title).bold(),
              const Expanded(child: SizedBox(),),
              Icon(Icons.arrow_back_ios_sharp, size:14,textDirection: AppThemes.getOppositeDirection(),)
            ],
          ),
        ),
      ),
    );
  }
}
