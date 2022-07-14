import 'dart:io';

import 'package:brandfit_manager/database/models/requestHybridModelDb.dart';
import 'package:flutter/material.dart';

import 'package:animate_do/animate_do.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/features/overlayDialog.dart';
import 'package:iris_tools/widgets/irisImageView.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '/abstracts/stateBase.dart';
import '/models/dataModels/courseModels/courseQuestionModel.dart';
import '/models/dataModels/photoDataModel.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/system/extensions.dart';
import '/tools/app/appThemes.dart';
import '/tools/bmiTools.dart';
import '/views/brokenImageView.dart';
import '/views/preWidgets.dart';

class RequestDataShowScreen extends StatefulWidget {
  static const screenName = 'RequestDataShowScreen';
  final RequestHybridModelDb requestModel;
  final UserModel userInfo;
  final UserModel trainerInfo;
  final CourseQuestionModel questionInfo;

  RequestDataShowScreen({
    Key? key,
    required this.requestModel,
    required this.userInfo,
    required this.trainerInfo,
    required this.questionInfo,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RequestDataShowScreenState();
  }
}
///=========================================================================================================
class RequestDataShowScreenState extends StateBase<RequestDataShowScreen> {
  StateXController stateController = StateXController();
  late final UserModel userInfo;
  late final UserModel trainerInfo;
  late final CourseQuestionModel questionInfo;
  late final Map illNameMap;
  late final Map gymToolsTypeMap;
  late final Map exercisePlaceTypeMap;
  late final Map goalOfBuyMap;
  late final Map nonWorkingActivityMap;
  late final Map jobTypesMap;

  @override
  void initState() {
    super.initState();

    userInfo = widget.userInfo;
    trainerInfo = widget.trainerInfo;
    questionInfo = widget.questionInfo;
    illNameMap = tAsMap('illness')?? {};
    gymToolsTypeMap = tAsMap('gymToolsType')?? {};
    exercisePlaceTypeMap = tAsMap('exercisePlaceType')?? {};
    goalOfBuyMap = tAsMap('goalOfBuyCourse')?? {};
    nonWorkingActivityMap = tAsMap('nonWorkingActivity')?? {};
    jobTypesMap = tAsMap('jobTypes')?? {};
  }

  @override
  Widget build(BuildContext context) {
    rotateToPortrait();

    return getScaffold();
  }

  @override
  void dispose() {
    stateController.dispose();

    super.dispose();
  }

  Widget getScaffold(){
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.requestModel.title),
      ),
      body: getMainBuilder(),
    );
  }

  Widget getMainBuilder(){
    return WillPopScope(
        onWillPop: () => onWillBack(this),
      child: StateX(
          isMain: true,
          controller: stateController,
          builder: (context, ctr, data) {
            return Builder(
              builder: (context) {
                return getBody();
              },
            );
          }
      ),
    );
  }

  Widget getBody(){
    return StateX(
      isSubMain: true,
      controller: stateController,
      builder: (ctx, ctr, data){
        return ListView(
          children: [
            FlipInY(
              child: Card(
                elevation: 0,
                color: AppThemes.currentTheme.primaryColor.withAlpha(50),
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [
                            ColorHelper.darkPlus(AppThemes.currentTheme.primaryColor),
                            ColorHelper.lightPlus(AppThemes.currentTheme.primaryColor),
                          ]
                      )
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${userInfo.userName} (${userInfo.nameFamily})')
                                .bold().fsR(2).boldFont().color(Colors.white),

                            /*IrisImageView(

                              ),*/
                          ],
                        ),
                        const SizedBox(height: 10,),

                        const Divider(indent: 10, endIndent: 10, color: Colors.white, thickness: 2,),

                        const SizedBox(height: 8,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${t('age')}: ').color(Colors.white),
                                Text('${userInfo.age}').color(Colors.white),
                              ],
                            ),

                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${t('gender')}: ').color(Colors.white),
                                Text('${questionInfo.sex == 1? t('man'): t('woman')}').color(Colors.white),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${t('heightMan')}: ').color(Colors.white),
                                Text('${questionInfo.height}').color(Colors.white),
                              ],
                            ),

                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${t('weight')}: ').color(Colors.white),
                                Text('${questionInfo.weight}').color(Colors.white),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('BMI: ').color(Colors.white),
                                Text('${BmiTools.calculateBmi(questionInfo.height, questionInfo.weight)}').color(Colors.white),
                              ],
                            ),

                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('BMR: ').color(Colors.white),
                                Text(
                                    '${BmiTools.calculateBmr(questionInfo.height, questionInfo.weight, userInfo.age, userInfo.sex)}'
                                ).color(Colors.white),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            ElasticIn(//Pulse,
              child: Card(
                elevation: 0,
                color: AppThemes.currentTheme.primaryColor.withAlpha(50),
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ...ColorHelper.getColorGradient(AppThemes.currentTheme.primaryColor).reversed,
                        //ColorHelper.darkPlus(AppThemes.currentTheme.primaryColor),
                      ]
                    )
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${trainerInfo.userName} (${trainerInfo.nameFamily})')
                                .bold().fsR(2).boldFont().color(Colors.white),

                            /*IrisImageView(

                            ),*/
                          ],
                        ),
                        const SizedBox(height: 10,),

                        const Divider(indent: 10, endIndent: 10, color: Colors.white, thickness: 2),

                        const SizedBox(height: 8,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${t('age')}: ').color(Colors.white),
                                Text('${trainerInfo.age}').color(Colors.white),
                              ],
                            ),

                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${t('gender')}: ').color(Colors.white),
                                Text('${trainerInfo.sex == 1? t('man'): t('woman')}').color(Colors.white),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Card(
              elevation: 0,
              color: AppThemes.currentTheme.primaryColor.withAlpha(70),
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${tInMap('requestDataShowPage', 'illList')}:').boldFont(),
                    const SizedBox(height: 10,),
                    Wrap(
                      direction: Axis.horizontal,
                      children: [
                        ...questionInfo.illList.map((e) => Chip(label: Text('${illNameMap[e]}'))).toList(),
                      ],
                    ).wrapBoxBorder(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),

                    const SizedBox(height: 10,),
                    Text('${tInMap('requestDataShowPage', 'illDescription')}:').boldFont(),
                    const SizedBox(height: 10,),
                    getInfoView(questionInfo.illDescription),

                    const SizedBox(height: 10,),
                    Text('${tInMap('requestDataShowPage', 'medicationUse')}:').boldFont(),
                    const SizedBox(height: 10,),
                    getInfoView(questionInfo.illMedications),

                    const SizedBox(height: 10,),
                    Text('${tInMap('requestDataShowPage', 'dietDescription')}:').boldFont(),
                    const SizedBox(height: 10,),
                    getInfoView(questionInfo.dietDescription),

                    const SizedBox(height: 10,),
                    Text('${tInMap('requestDataShowPage', 'harmDescription')}:').boldFont(),
                    const SizedBox(height: 10,),
                    getInfoView(questionInfo.harmDescription),

                    const SizedBox(height: 10,),
                    Text('${tInMap('requestDataShowPage', 'sportsRecordsDescription')}:').boldFont(),
                    const SizedBox(height: 10,),
                    getInfoView(questionInfo.sportsRecordsDescription),

                    const SizedBox(height: 10,),
                    Row(
                      children: [
                        Text('${tInMap('requestDataShowPage', 'sleepHoursAtNight')}:').boldFont(),
                        Text('${questionInfo.sleepHoursAtNight}'),
                      ],
                    ),

                    const SizedBox(height: 10,),
                    Row(
                      children: [
                        Text('${tInMap('requestDataShowPage', 'sleepHoursAtDay')}:').boldFont(),
                        Text('${questionInfo.sleepHoursAtDay}'),
                      ],
                    ),

                    const SizedBox(height: 10,),
                    Row(
                      children: [
                        Text('${tInMap('requestDataShowPage', 'exerciseHours')}:').boldFont(),
                        Text('${questionInfo.exerciseHours}'),
                      ],
                    ),

                    const SizedBox(height: 10,),
                    Row(
                      children: [
                        Text('${tInMap('requestDataShowPage', 'jobType')}:').boldFont(),
                        Text('${jobTypesMap[questionInfo.jobType]}'),
                      ],
                    ),

                    const SizedBox(height: 10,),
                    Row(
                      children: [
                        Text('${tInMap('requestDataShowPage', 'noneWorkActivity')}:').boldFont(),
                        Text('${nonWorkingActivityMap[questionInfo.noneWorkActivity]}'),
                      ],
                    ),

                    Visibility(
                      visible: questionInfo.exercisePlaceType != null,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10,),
                            Row(
                              children: [
                                Text('${tInMap('requestDataShowPage', 'exercisePlaceType')}: ').boldFont(),
                                Text('${exercisePlaceTypeMap[questionInfo.exercisePlaceType]}'),
                              ],
                            ),
                          ],
                        )
                    ),

                    Visibility(
                      visible: questionInfo.gymToolsType != null,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10,),
                            Row(
                              children: [
                                Text('${tInMap('requestDataShowPage', 'gymToolsType')}: ').boldFont(),
                                Text('${gymToolsTypeMap[questionInfo.gymToolsType]}'),
                              ],
                            ),

                            const SizedBox(height: 10,),
                            Text('${tInMap('requestDataShowPage', 'gymToolsDescription')}:').boldFont(),
                            const SizedBox(height: 10,),
                            getInfoView(questionInfo.gymToolsDescription),
                          ],
                        )
                    ),

                    Visibility(
                        visible: questionInfo.homeToolsDescription != null,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10,),
                            Text('${tInMap('requestDataShowPage', 'homeToolsDescription')}:').boldFont(),
                            const SizedBox(height: 10,),
                            Text('${questionInfo.homeToolsDescription}').wrapBoxBorder(
                              padding: const EdgeInsets.all(8),
                            ),
                          ],
                        )
                    ),

                    Visibility(
                        visible: questionInfo.exerciseTimesDescription != null,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10,),
                            Text('${tInMap('requestDataShowPage', 'exerciseTimesDescription')}:').boldFont(),
                            const SizedBox(height: 10,),
                            Text('${questionInfo.exerciseTimesDescription}').wrapBoxBorder(
                              padding: const EdgeInsets.all(8),
                            ),
                          ],
                        )
                    ),

                    const SizedBox(height: 10,),
                    Row(
                      children: [
                        Text('${tInMap('requestDataShowPage', 'goalOfBuy')}:').boldFont(),
                        Text('${goalOfBuyMap[questionInfo.goalOfBuy]}'),
                      ],
                    ),

                    const SizedBox(height: 10,),
                  ],
                ),
              ),
            ),

            if(questionInfo.experimentPhotos.isNotEmpty)
            Card(
              elevation: 0,
              color: AppThemes.currentTheme.primaryColor.withAlpha(50),
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${tInMap('requestDataShowPage', 'experimentPhotos')}:').boldFont(),

                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: questionInfo.experimentPhotos.length,
                          itemBuilder: (ctx, idx){
                          final ph = questionInfo.experimentPhotos[idx];

                            return GestureDetector(
                              onTap: () async{
                                if(await File(ph.getPath()!).exists()) {
                                  openGallery(questionInfo.experimentPhotos, idx);
                                }
                              },
                              child: IrisImageView(
                                width: 150,
                                imagePath: ph.getPath(),
                                url: ph.uri,
                                beforeLoadWidget: PreWidgets.flutterLoadingWidget$Center(),
                              ),
                            );
                          }
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if(questionInfo.bodyAnalysisPhotos.isNotEmpty)
              Card(
                elevation: 0,
                color: AppThemes.currentTheme.primaryColor.withAlpha(50),
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${tInMap('requestDataShowPage', 'bodyAnalysisPhotos')}:').boldFont(),

                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: questionInfo.bodyAnalysisPhotos.length,
                            itemBuilder: (ctx, idx){
                              final ph = questionInfo.bodyAnalysisPhotos[idx];

                              return GestureDetector(
                                onTap: () async{
                                  if(await File(ph.getPath()!).exists()) {
                                    openGallery(questionInfo.bodyAnalysisPhotos, idx);
                                  }
                                },
                                child: IrisImageView(
                                  width: 150,
                                  imagePath: ph.getPath(),
                                  url: ph.uri,
                                  beforeLoadWidget: PreWidgets.flutterLoadingWidget$Center(),
                                ),
                              );
                            }
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if(questionInfo.bodyPhotos.isNotEmpty)
              Card(
                elevation: 0,
                color: AppThemes.currentTheme.primaryColor.withAlpha(50),
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${tInMap('requestDataShowPage', 'bodyPhotos')}:').boldFont(),

                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: questionInfo.bodyPhotos.length,
                            itemBuilder: (ctx, idx){
                              final ph = questionInfo.bodyPhotos[idx];

                              return GestureDetector(
                                onTap: () async{
                                  if(await File(ph.getPath()!).exists()) {
                                    openGallery(questionInfo.bodyPhotos, idx);
                                  }
                                },
                                child: IrisImageView(
                                  width: 150,
                                  imagePath: ph.getPath(),
                                  url: ph.uri,
                                  beforeLoadWidget: PreWidgets.flutterLoadingWidget$Center(),
                                ),
                              );
                            }
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if(questionInfo.cardPhoto != null)
              Card(
                elevation: 0,
                color: AppThemes.currentTheme.primaryColor.withAlpha(50),
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${tInMap('requestDataShowPage', 'payPhotos')}:').boldFont(),

                      SizedBox(
                        height: 150,
                        child: GestureDetector(
                          onTap: () async{
                            if(await File(questionInfo.cardPhoto!.getPath()!).exists()) {
                              openGallery([questionInfo.cardPhoto!], 0);
                            }
                          },
                          child: IrisImageView(
                            width: 150,
                            imagePath: questionInfo.cardPhoto?.getPath(),
                            url: questionInfo.cardPhoto!.uri,
                            beforeLoadWidget: PreWidgets.flutterLoadingWidget$Center(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
  ///==========================================================================================================
  bool checkIsOk(String? d){
    return d != null && d.trim().isNotEmpty;
  }

  Widget getInfoView(String? info){
    if(checkIsOk(info)){
      return Text('$info').wrapBoxBorder(
        padding: const EdgeInsets.all(8),
      );
    }

    return Text('---').infoColor();
  }

  void openGallery(List<PhotoDataModel> list, int idx){
    final pageController = PageController(initialPage: idx,);

    final Widget gallery = PhotoViewGallery.builder(
      scrollPhysics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      enableRotation: false,
      gaplessPlayback: true,
      reverse: false,
      //customSize: Size(AppSizes.getScreenWidth(state.context), 200),
      itemCount: list.length,
      pageController: pageController,
      //onPageChanged: onPageChanged,
      backgroundDecoration: const BoxDecoration(
        color: Colors.black,
      ),
      builder: (BuildContext context, int index) {
        final ph = list.elementAt(index);

        return PhotoViewGalleryPageOptions(
            imageProvider: FileImage(File(ph.getPath()?? ''),),// NetworkImage(ph.uri),
            heroAttributes: PhotoViewHeroAttributes(tag: 'photo$idx'),
            basePosition: Alignment.center,
            gestureDetectorBehavior: HitTestBehavior.translucent,
            maxScale: 2.0,
            //minScale: 0.5,
            filterQuality: FilterQuality.medium,
            errorBuilder: (context, Object error, StackTrace? stackTrace){
              return BrokenImageView();
            }
        );
      },

      loadingBuilder: (context, progress) => Center(
        child: SizedBox(
          width: 70.0,
          height: 70.0,
          child: (progress == null || progress.expectedTotalBytes == null)
              ? const CircularProgressIndicator()
              : CircularProgressIndicator(value: progress.cumulativeBytesLoaded / progress.expectedTotalBytes!,),
        ),
      ),
    );

    final osv = OverlayScreenView(
      content: gallery,
      routingName: 'Gallery',
    );

    OverlayDialog().show(context, osv);
  }

}

