import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/widgets/irisImageView.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';

import '/abstracts/stateBase.dart';
import '/models/dataModels/courseModels/courseModel.dart';
import '/screens/courseManagementPart/fullInfoPart/courseFullInfoCtr.dart';
import '/system/extensions.dart';
import '/tools/app/appThemes.dart';
import '/tools/currencyTools.dart';
import '/tools/dateTools.dart';

class CourseFullInfoScreen extends StatefulWidget {
  static const screenName = 'UserFullInfoScreen';
  final CourseModel courseModel;

  const CourseFullInfoScreen({
    Key? key,
    required this.courseModel,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => CourseFullInfoScreenState();
}
///=====================================================================================
class CourseFullInfoScreenState extends StateBase<CourseFullInfoScreen> {
  StateXController stateController = StateXController();
  CourseFullInfoCtr controller = CourseFullInfoCtr();

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
        title: Text(controller.courseModel.title),
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
              color: ColorHelper.textToColor(controller.courseModel.title),
              child: GestureDetector(
                onTap: (){
                  controller.showFullScreenImage();
                },
                child: Hero(
                  tag: 'h${controller.courseModel.id}',
                  child: IrisImageView(
                    height: 180,
                    imagePath: controller.courseModel.imagePath,
                    url: controller.courseModel.imageUri,
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
                          label: Text('ID: ${controller.courseModel.id}'),
                        ),
                      ],
                    ),

                    /*Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: IconButton(
                        icon: Icon(IconList.dotsVerM)
                            .primaryOrAppBarItemOnBackColor(),
                        alignment: Alignment.centerLeft,
                        onPressed: (){
                          controller.showEditSheet();
                        },
                      ),
                    )*/
                  ],
                ),

                const SizedBox(height: 2,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  
                  children: [
                    Text('${context.tC('title')}')
                        .boldFont().color(AppThemes.currentTheme.primaryColor),

                    Text(controller.courseModel.title,)
                        .boldFont().color(AppThemes.currentTheme.primaryColor),
                  ],
                ),


                const SizedBox(height: 6,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text('${context.tC('trainer')}'),

                    Text(controller.courseModel.creatorUserName?? '').boldFont(),
                  ],
                ),

                const SizedBox(height: 6,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  
                  children: [
                    Text('${context.tC('price')}'),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      textDirection: TextDirection.ltr,
                      //mainAxisAlignment: AppThemes.isRtlDirection()? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        Text(CurrencyTools.formatCurrencyString(controller.courseModel.price),)
                            .boldFont(),
                        SizedBox(width: 8,),
                        Text('${controller.courseModel.currencyModel.currencyCode}')
                            .subFont().alpha(),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 6,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text('${tInMap('courseManagementScreen', 'exercise')}'),

                    Text(controller.courseModel.hasExerciseProgram? '${t('yes')}': '${t('no')}').boldFont(),
                  ],
                ),

                const SizedBox(height: 6,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text('${tInMap('courseManagementScreen', 'food')}'),

                    Text(controller.courseModel.hasFoodProgram? '${t('yes')}': '${t('no')}').boldFont(),
                  ],
                ),

                const SizedBox(height: 6,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text('${t('creationDate')}'),
                    Text(DateTools.dateOnlyRelative(controller.courseModel.creationDate)).boldFont(),
                  ],
                ),

                const SizedBox(height: 6,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text('${t('startDate')}'),
                    Text(DateTools.dateOnlyRelative(controller.courseModel.startBroadcastDate)).boldFont(),
                  ],
                ),

                const SizedBox(height: 6,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text('${t('finishDate')}'),
                    Text(DateTools.dateOnlyRelative(controller.courseModel.finishBroadcastDate)).boldFont(),
                  ],
                ),

                const SizedBox(height: 6,),
                Card(
                  color: Colors.grey.shade200,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(controller.courseModel.description).boldFont(),
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
