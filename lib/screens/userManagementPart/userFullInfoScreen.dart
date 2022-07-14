import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/api/helpers/localeHelper.dart';
import 'package:iris_tools/widgets/irisImageView.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';

import '/abstracts/stateBase.dart';
import '/models/dataModels/usersModels/appUserModel.dart';
import '/screens/userManagementPart/userFullInfoCtr.dart';
import '/system/extensions.dart';
import '/system/icons.dart';
import '/system/session.dart';
import '/tools/app/appThemes.dart';
import '/tools/dateTools.dart';

class UserFullInfoScreen extends StatefulWidget {
  static const screenName = 'UserFullInfoScreen';
  final AppUserModel userModel;

  const UserFullInfoScreen({
    Key? key,
    required this.userModel,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => UserFullInfoScreenState();
}
///=====================================================================================
class UserFullInfoScreenState extends StateBase<UserFullInfoScreen> {
  StateXController stateController = StateXController();
  UserFullInfoCtr controller = UserFullInfoCtr();

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

  Widget getScaffold(){
    return Scaffold(
      appBar: AppBar(
        title: Text('${controller.pupilModel.userName}'),
      ),
      body: SafeArea(
          child: getMainBuilder()
      ),
    );
  }

  Widget getMainBuilder(){
    return StateX(
        isMain: true,
        controller: stateController,
        builder: (context, ctr, data) {
          return getBody();
        }
    );
  }

  Widget getBody(){
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 180,
            width: double.infinity,
            child: ColoredBox(
              color: ColorHelper.textToColor(controller.pupilModel.userName?? ''),
              child: GestureDetector(
                onTap: (){
                  controller.showFullScreenImage();
                },
                child: Hero(
                  tag: 'h${controller.pupilModel.userId}',
                  child: IrisImageView(
                    height: 180,
                    imagePath: controller.pupilModel.profileImagePath,
                    url: controller.pupilModel.profileImageUri,
                  ),
                ),
              ),
            ),
          ),

          Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Chip(
                          label: Text('ID: ${controller.pupilModel.userId}'),
                        ),
                      ],
                    ),

                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: IconButton(
                        icon: Icon(IconList.dotsVerM)
                            .primaryOrAppBarItemOnBackColor(),
                        alignment: Alignment.centerLeft,
                        onPressed: (){
                          controller.showEditSheet();
                        },
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 2,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  
                  children: [
                    Text('${context.tC('userName')}')
                        .boldFont().color(AppThemes.currentTheme.primaryColor),

                    Text('${controller.pupilModel.userName}',)
                        .boldFont().color(AppThemes.currentTheme.primaryColor),
                  ],
                ),

                const SizedBox(height: 6,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  
                  children: [
                    Text('${context.tC('name')}'),

                    Text('${controller.pupilModel.name}',).boldFont(),
                  ],
                ),

                const SizedBox(height: 6,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  
                  children: [
                    Text('${context.tC('family')}'),

                    Text('${controller.pupilModel.family}',).boldFont(),
                  ],
                ),

                const SizedBox(height: 6,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  
                  children: [
                    Text('${context.tC('country')}'),

                    Text(LocaleHelper.embedLtr(controller.pupilModel.countryCode?? ''),).boldFont(),
                  ],
                ),

                const SizedBox(height: 6,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  
                  children: [
                    Text('${context.tC('mobileNumber')}'),

                    Text(controller.pupilModel.mobileNumber?? '').boldFont(),
                  ],
                ),

                const SizedBox(height: 6,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text('${context.tC('gender')}'),

                    Text(Session.getSexEquivalent(controller.pupilModel.sexInt)).boldFont(),
                  ],
                ),

                const SizedBox(height: 6,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text('${context.tC('age')}'),

                    Text('${controller.pupilModel.age}').boldFont(),
                  ],
                ),

                const SizedBox(height: 6,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  
                  children: [
                    Text('${context.tC('birthDate')}'),

                    Text(DateTools.dateRelativeByAppFormat(controller.pupilModel.birthDate)).boldFont(),
                  ],
                ),

                const SizedBox(height: 6,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  
                  children: [
                    Text('${context.tC('joinDate')}'),

                    Text(DateTools.dateAndHmRelative(controller.pupilModel.joinDate)).boldFont(),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Visibility(
                        visible: controller.pupilModel.isBlocked,
                        child: Chip(
                          label: Text('${context.tC('blocked')}'),
                          backgroundColor: AppThemes.currentTheme.warningColor,
                        )
                    ),

                    const SizedBox(width: 4),
                    Visibility(
                        visible: controller.pupilModel.isDeleted,
                        child: Chip(
                          label: Text('${context.tC('deleted')}'),
                          backgroundColor: AppThemes.currentTheme.errorColor,
                        )
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
