import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/inputFormatter.dart';
import 'package:iris_tools/api/helpers/localeHelper.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/features/overlayDialog.dart';
import 'package:iris_tools/widgets/icon/titleIcon.dart';
import 'package:iris_tools/widgets/irisImageView.dart';
import 'package:iris_tools/modules/stateManagers/selfRefresh.dart';
import 'package:iris_tools/widgets/text/clickable.dart';
import 'package:iris_tools/widgets/text/titleInfo.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '/abstracts/stateBase.dart';
import '/models/dataModels/advertisingModel.dart';
import '/screens/advertisingPart/advertisingScreen.dart';
import '/screens/advertisingPart/viewAdvertising/advertisingListViewCtr.dart';
import '/screens/commons/imageFullScreen.dart';
import '/system/downloadUpload.dart';
import '/system/enums.dart';
import '/system/extensions.dart';
import '/system/icons.dart';
import '/system/keys.dart';
import '/system/multiViewDialog.dart';
import '/tools/app/appNavigator.dart';
import '/tools/app/appThemes.dart';
import '/tools/centers/directoriesCenter.dart';
import '/tools/centers/sheetCenter.dart';
import '/tools/dateTools.dart';
import '/tools/permissionTools.dart';
import '/tools/widgetTools.dart';
import '/views/brokenImageView.dart';
import '/views/dateViews/selectDateTimeCalendarView.dart';
import '/views/preWidgets.dart';

class AdvertisingListView extends StatefulWidget {
  final AdvertisingModel model;
  final AdvertisingScreenState parentState;

  AdvertisingListView(this.model, this.parentState, {Key? key}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AdvertisingListViewState();
  }
}
///==============================================================================================
class AdvertisingListViewState extends StateBase<AdvertisingListView> {
  AdvertisingListViewCtr controller = AdvertisingListViewCtr();

  @override
  void initState() {
    super.initState();
    controller.onInitState(this);
  }

  @override
  Widget build(BuildContext context) {
    controller.onBuild();

    if(controller.model.advFile == null){
      if(controller.model.imageUri != null){

        controller.model.imagePath ??= DirectoriesCenter.getSavePathUri(controller.model.imageUri, SavePathType.ADVERTISING);

        PermissionTools.requestStoragePermission().then((permission){
          if (permission != PermissionStatus.granted){
            return;
          }

          final f = FileHelper.getFile(controller.model.imagePath!);

          f.exists().then((exist){
            if(exist){
              controller.model.advFile = f;
              update();
            }
            else {
              final tag = Keys.genDownloadTag_advertising(controller.model);
              final item = DownloadUpload.downloadManager.createDownloadItem(controller.model.imageUri!,tag: tag, savePath: controller.model.imagePath!);
              item.category = DownloadCategory.advertisingManager.toString();
              item.subCategory = controller.model.id.toString();
              item.attach = controller.model;
              DownloadUpload.downloadManager.enqueue(item);
            }
          });
        });
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            GestureDetector(
                onTap: (){
                  if(controller.model.advFile == null){
                    return;
                  }

                  final view = ImageFullScreen(
                    imageType: ImageType.File,
                    heroTag: 'h${controller.model.id}',
                    imageObj: controller.model.advFile!,
                  );

                  AppNavigator.pushNextPageExtra(context, view, name: ImageFullScreen.screenName);
                },
                child: Hero(
                  tag: 'h${controller.model.id}',
                  child: LayoutBuilder(
                      builder: (context, c) {
                        return Stack(
                          children: [
                            IrisImageView(
                              height: 200,
                              width: c.maxWidth,
                              cacheManager: controller.parentState.controller.imageCache,
                              cacheKey: Generator.hashMd5(controller.model.imagePath?? ''),
                              beforeLoadWidget: PreWidgets.flutterLoadingWidget$Center(),
                              errorWidget: BrokenImageView(),
                              imagePath: controller.model.imagePath,
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              filterQuality: FilterQuality.medium,
                            ),

                            Align(
                              alignment: const FractionalOffset(0.01, 0),
                              child: Icon(IconList.dotsVerM, size: 17,)
                                  //.primaryOrAppBarItemOnBackColor()
                                  .toColor(Colors.white)
                                  .wrapMaterial(
                                padding: const EdgeInsets.all(6.0),
                                materialColor: Colors.grey.withAlpha(120),
                                onTapDelay: showEditSheet
                              )
                            ),
                          ],
                        );
                      }
                  ),
                )
            ),

            const SizedBox(height: 8,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TitleInfo(
                  title: '${context.tC('creator')}: ',
                  info: '${controller.model.creatorUserName}',
                ),

                Chip(
                  label: Text('id: ${controller.model.id}'),
                ),
              ],
            ),

            //const SizedBox(height: 8,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TitleInfo(
                  title: '${context.tC('title')}: ',
                  info: controller.model.title?? '',
                  maxLines: 1,
                ),
              ],
            ),

            const SizedBox(height: 8,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TitleInfo(
                  title: '${context.tC('tag')}: ',
                  info: controller.model.tag?? '',
                  maxLines: 1,
                ),

                TitleInfo(
                  title: '${context.tC('type')}: ',
                  info: controller.typeMap[controller.model.type]?? '',
                  maxLines: 1,
                ),
              ],
            ),

            const SizedBox(height: 8,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TitleInfo(
                  title: '${context.tC('creationDate')}: ',
                  info: DateTools.dateAndHmRelative(controller.model.registerDate, isUtc: false),
                ),

                TitleInfo(
                  title: '${context.tC('order')}: ',
                  info: '${controller.model.orderNum?? ''}',
                ),
              ],
            ),

            const SizedBox(height: 8,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TitleInfo(
                  title: '${context.tC('startDate')}: ',
                  info: DateTools.dateAndHmRelative(controller.model.startShowDate, isUtc: false),
                ),
              ],
            ),

            const SizedBox(height: 8,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                TitleInfo(
                  title: '${context.tC('finishDate')}: ',
                  info: DateTools.dateAndHmRelative(controller.model.finishShowDate, isUtc: false),
                ),
              ],
            ),

            const SizedBox(height: 8,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TitleIcon(
                  title: '${context.tC('presentable')}: ',
                  icon: Icon(controller.model.canShow? IconList.checkedBoxM : IconList.checkBlankBoxM),
                ),

                TitleIcon(
                  title: '${context.tInMap('addAdvertisingPage', 'inRange')}: ',
                  icon: Icon(controller.model.inRange? IconList.checkedBoxM : IconList.checkBlankBoxM),
                ),
              ],
            ),

            const SizedBox(height: 8,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClickableUrl(
                  text: controller.model.clickLink?? 'noLink',
                  url: controller.model.clickLink?? 'noLink',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.onDispose();

    super.dispose();
  }
  ///========================================================================================================
  void showEditSheet(){
    Widget build(BuildContext ctx){
      final v = ColoredBox(
        color: AppThemes.currentTheme.backgroundColor,
        child: SizedBox(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 33),
            child: Table(
              defaultColumnWidth: const FractionColumnWidth(0.5),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              textDirection: TextDirection.ltr,
              children: [
                TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: ElevatedButton(
                          child: Text('${context.tC('edit', key2: 'title')}'),
                          onPressed: (){
                            SheetCenter.closeSheetByName(context, 'EditAdvertising');
                            showEditTitleScreen('EditTitleScreen');
                          },
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: ElevatedButton(
                          child: Text('${context.tC('edit', key2: 'image')}'),
                          onPressed: (){
                            SheetCenter.closeSheetByName(context, 'EditAdvertising');
                            showEditImageScreen('EditImageScreen');
                          },
                        ),
                      )
                    ]
                ),

                TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: ElevatedButton(
                          child: Text('${context.tC('edit', key2: 'tag')}'),
                          onPressed: (){
                            SheetCenter.closeSheetByName(context, 'EditAdvertising');
                            showEditTagScreen('EditTagScreen');
                          },
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: ElevatedButton(
                          child: Text('${context.tC('edit', key2: 'type')}'),
                          onPressed: (){
                            SheetCenter.closeSheetByName(context, 'EditAdvertising');
                            showEditTypeScreen('EditTypeScreen');
                          },
                        ),
                      )
                    ]
                ),

                TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: ElevatedButton(
                          child: Text('${context.tC('edit', key2: 'startDate')}'),
                          onPressed: (){
                            SheetCenter.closeSheetByName(context, 'EditAdvertising');
                            showEditStartDateScreen('EditStartDateScreen');
                          },
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: ElevatedButton(
                          child: Text('${context.tC('edit', key2: 'finishDate')}'),
                          onPressed: (){
                            SheetCenter.closeSheetByName(context, 'EditAdvertising');
                            showEditFinishDateScreen('EditFinishDateScreen');
                          },
                        ),
                      )
                    ]
                ),

                TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: ElevatedButton(
                          child: Text('${context.tC('edit', key2: 'order')}'),
                          onPressed: (){
                            SheetCenter.closeSheetByName(context, 'EditAdvertising');
                            showEditOrderScreen('EditOrderScreen');
                          },
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: ElevatedButton(
                          child: Text('${context.tC('edit', key2: 'link')}'),
                          onPressed: (){
                            SheetCenter.closeSheetByName(context, 'EditAdvertising');
                            showEditLinkScreen('EditLinkScreen');
                          },
                        ),
                      )
                    ]
                ),

                TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: ElevatedButton(
                          child: controller.model.canShow?
                          Text('${context.tC('doNotShow')}')
                              : Text('${context.tC('show')}'),
                          onPressed: (){
                            SheetCenter.closeSheetByName(context, 'EditAdvertising');
                            controller.changeShowState();
                          },
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: ElevatedButton(
                          child: Text('${context.tC('delete')}'),
                          onPressed: (){
                            SheetCenter.closeSheetByName(context, 'EditAdvertising');
                            controller.deleteAdvertising();
                          },
                        ),
                      ),
                    ]
                ),
              ],
            ),
          ),
        ),
      );

      return MultiViewDialog.addCloseBtn(context,
          v, alignment: Alignment.bottomCenter, navName: 'EditAdvertising');
      //return v;
    }

    SheetCenter.showModalSheet(context, build, routeName: 'EditAdvertising');
  }

  void showEditTitleScreen(String screenName){
    final textFieldCtr = TextEditingController();
    textFieldCtr.text = widget.model.title?? '';

    final Widget screen = Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 42),
        child: Column(
          children: [
            SelfRefresh(
                builder: (BuildContext context, UpdateController controller) {
                  return TextFormField(
                    textDirection: controller.getOrDefault('direction', LocaleHelper.autoDirection(textFieldCtr.text)),
                    controller: textFieldCtr,
                    textInputAction: TextInputAction.next,
                    style: AppThemes.baseTextStyle(),
                    onTap: () {
                      FocusHelper.fullSelect(textFieldCtr);
                    },
                    onChanged: (t){
                      controller.set('direction', LocaleHelper.autoDirection(t));
                      controller.update();
                    },
                    onFieldSubmitted: (_) {
                      /*no need focusNode.nextFocus();*/
                    },
                    decoration: InputDecoration(
                      hintText: '${t('title')}',
                      border: InputBorder.none,
                    ),
                  );
                }
            ),

            const SizedBox(height: 40,),
            Center(
              child: ElevatedButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 50)),
                ),
                onPressed: (){
                  controller.uploadTitle(textFieldCtr.text);
                },
                child: Text('${tC('apply')}'),
              ),
            )
          ],
        ),
      ),
    );

    final view = OverlayScreenView(
      content: SizedBox.expand(
        child: screen,
      ),
      routingName: screenName,
      backgroundColor: AppThemes.currentTheme.backgroundColor,
    );

    OverlayDialog().show(context, view).then((value){
      update();
    });
  }

  void showEditTagScreen(String screenName){
    final usernameCtr = TextEditingController();
    usernameCtr.text = widget.model.tag?? '';

    final Widget screen = Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 42),
        child: Column(
          children: [
            SelfRefresh(
                builder: (BuildContext context, UpdateController controller) {
                  return TextFormField(
                    textDirection: controller.getOrDefault('direction', LocaleHelper.autoDirection(usernameCtr.text)),
                    controller: usernameCtr,
                    textInputAction: TextInputAction.next,
                    style: AppThemes.baseTextStyle(),
                    onTap: () {
                      FocusHelper.fullSelect(usernameCtr);
                    },
                    onChanged: (t){
                      controller.set('direction', LocaleHelper.autoDirection(t));
                      controller.update();
                    },
                    onFieldSubmitted: (_) {
                      /*no need focusNode.nextFocus();*/
                    },
                    decoration: InputDecoration(
                      hintText: '${t('tag')}',
                      border: InputBorder.none,
                    ),
                  );
                }
            ),

            const SizedBox(height: 40,),
            Center(
              child: ElevatedButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 50)),
                ),
                onPressed: (){
                  controller.uploadTag(usernameCtr.text);
                },
                child: Text('${tC('apply')}'),
              ),
            )
          ],
        ),
      ),
    );

    final view = OverlayScreenView(
      content: SizedBox.expand(
        child: screen,
      ),
      routingName: screenName,
      backgroundColor: AppThemes.currentTheme.backgroundColor,
    );

    OverlayDialog().show(context, view).then((value){
      update();
    });
  }

  void showEditTypeScreen(String screenName){
    final typeMap = tAsStringMap('addAdvertisingPage', 'types')!;
    final List<String> typeTranslates = typeMap.values.toList();
    int selectedType = typeTranslates.indexWhere((element) => element == typeMap[widget.model.type]);

    if(selectedType < 0){
      selectedType = 0;
    }

    final content = SelfRefresh(
      builder: (ctx, ctr){
        return ColoredBox(
          color: AppThemes.currentTheme.backgroundColor,
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${t('type')}').color(Colors.black),

                  SizedBox(height: 12,),
                  ToggleSwitch(
                    initialLabelIndex: selectedType,
                    cornerRadius: 12.0,
                    //minWidth: 100,
                    radiusStyle: false,
                    activeBgColor: [AppThemes.currentTheme.activeItemColor],
                    activeFgColor: Colors.white,
                    totalSwitches: 3,
                    textDirectionRTL: true,
                    inactiveBgColor: AppThemes.currentTheme.inactiveBackColor,
                    inactiveFgColor: AppThemes.currentTheme.inactiveTextColor,
                    labels: typeTranslates,
                    onToggle: (index) {
                      selectedType = index!;
                      ctr.update();
                    },
                  ),

                  SizedBox(height: 35,),
                  ElevatedButton(
                    onPressed: (){
                      controller.uploadType(typeMap.entries.firstWhere((element) => element.value == typeTranslates[selectedType]).key);
                    },
                    child: Text('${t('apply')}'),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );

    SheetCenter.showSheetCustom(
      context,
      content,
      routeName: 'EditType',
    ).then((value){
      update();
    });
  }

  void showEditStartDateScreen(String screenName){
    void showCalendar(){
      SheetCenter.showSheetCustom(
        context,
        SelectDateTimeCalendarView(currentDate: widget.model.startShowDate,),
        routeName: 'StartDateScreen',
        backgroundColor: Colors.transparent,
        isScrollControlled: false,
      ).then((value){
        if(value == null){
          return;
        }

        controller.uploadDate(value, 'start_date');
      });
    }
    //..................................................
    final Widget view = SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20,),

          ElevatedButton(
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(const Size(200, 50)),
                shape: MaterialStateProperty.all(ShapeList.stadiumBorder$Outlined),
                foregroundColor: MaterialStateProperty.all(AppThemes.currentTheme.buttonTextColorOnPrimary),
                backgroundColor: MaterialStateProperty.all(AppThemes.currentTheme.buttonBackColorOnPrimary),
              ),
              onPressed: () {
                SheetCenter.closeSheetByName(context, 'ChooseDateOperation');
                controller.uploadDate(null, 'start_date');
              },
              child: Text('${tC('delete')}')
          ),

          const SizedBox(height: 16,),
          ElevatedButton(
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(const Size(200, 50)),
                shape: MaterialStateProperty.all(ShapeList.stadiumBorder$Outlined),
                foregroundColor: MaterialStateProperty.all(AppThemes.currentTheme.buttonTextColorOnPrimary),
                backgroundColor: MaterialStateProperty.all(AppThemes.currentTheme.buttonBackColorOnPrimary),
              ),
              onPressed: (){
                SheetCenter.closeSheetByName(context, 'ChooseDateOperation');
                showCalendar();
              },
              child: Text('${tC('edit')}')
          ),

          const SizedBox(height: 16,),
        ],
      ),
    );

    if(controller.model.startShowDate != null) {
      SheetCenter.showSheetCustom(context, view, routeName: 'ChooseDateOperation');
    }
    else {
      showCalendar();
    }
  }

  void showEditFinishDateScreen(String screenName){
    void showCalendar(){
      SheetCenter.showSheetCustom(
        context,
        SelectDateTimeCalendarView(currentDate: widget.model.finishShowDate,),
        routeName: 'FinishDateScreen',
        backgroundColor: Colors.transparent,
        isScrollControlled: false,
      ).then((value){
        if(value == null){
          return;
        }

        controller.uploadDate(value, 'finish_date');
      });
    }
    //..................................................
    final Widget view = SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20,),

          ElevatedButton(
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(const Size(200, 50)),
                shape: MaterialStateProperty.all(ShapeList.stadiumBorder$Outlined),
                foregroundColor: MaterialStateProperty.all(AppThemes.currentTheme.buttonTextColorOnPrimary),
                backgroundColor: MaterialStateProperty.all(AppThemes.currentTheme.buttonBackColorOnPrimary),
              ),
              onPressed: () {
                SheetCenter.closeSheetByName(context, 'ChooseDateOperation');
                controller.uploadDate(null, 'finish_date');
              },
              child: Text('${tC('delete')}')
          ),

          const SizedBox(height: 16,),
          ElevatedButton(
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(const Size(200, 50)),
                shape: MaterialStateProperty.all(ShapeList.stadiumBorder$Outlined),
                foregroundColor: MaterialStateProperty.all(AppThemes.currentTheme.buttonTextColorOnPrimary),
                backgroundColor: MaterialStateProperty.all(AppThemes.currentTheme.buttonBackColorOnPrimary),
              ),
              onPressed: (){
                SheetCenter.closeSheetByName(context, 'ChooseDateOperation');
                showCalendar();
              },
              child: Text('${tC('edit')}')
          ),

          const SizedBox(height: 16,),
        ],
      ),
    );

    if(controller.model.finishShowDate != null) {
      SheetCenter.showSheetCustom(context, view, routeName: 'ChooseDateOperation');
    }
    else {
      showCalendar();
    }
  }

  void showEditOrderScreen(String screenName){
    final textFieldCtr = TextEditingController();
    textFieldCtr.text = widget.model.orderNum?.toString()?? '';

    final Widget screen = Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 42),
        child: Column(
          children: [
            SelfRefresh(
                builder: (BuildContext context, UpdateController controller) {
                  return TextField(
                    textDirection: controller.getOrDefault('direction', LocaleHelper.autoDirection(textFieldCtr.text)),
                    controller: textFieldCtr,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    inputFormatters: [InputFormatter.inputFormatterDigitsOnly()],
                    style: AppThemes.baseTextStyle(),
                    onTap: () {
                      FocusHelper.fullSelect(textFieldCtr);
                    },
                    onChanged: (t){
                      controller.set('direction', LocaleHelper.autoDirection(t));
                      controller.update();
                    },
                    decoration: InputDecoration(
                      hintText: '${t('order')}',
                      border: InputBorder.none,
                    ),
                  );
                }
            ),

            const SizedBox(height: 40,),
            Center(
              child: ElevatedButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 50)),
                ),
                onPressed: (){
                  final x = textFieldCtr.text;

                  if(x.isEmpty){
                    SheetCenter.showSheetNotice(context, tC('pleaseFillOptions')!);
                    return;
                  }

                  final n = MathHelper.toInt(x, def: -1);

                  if(n < 0){
                    SheetCenter.showSheetNotice(context, tC('valueEnteredIsIncorrect')!);
                    return;
                  }

                  controller.uploadOrder(n);
                },
                child: Text('${tC('apply')}'),
              ),
            )
          ],
        ),
      ),
    );

    final view = OverlayScreenView(
      content: SizedBox.expand(
        child: screen,
      ),
      routingName: screenName,
      backgroundColor: AppThemes.currentTheme.backgroundColor,
    );

    OverlayDialog().show(context, view).then((value){
      if(value == null){
        return;
      }

      update();
    });
  }

  void showEditLinkScreen(String screenName){
    final textFieldCtr = TextEditingController();
    textFieldCtr.text = widget.model.clickLink?? '';

    final Widget screen = Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 42),
        child: Column(
          children: [
            SelfRefresh(
                builder: (BuildContext context, UpdateController controller) {
                  return TextField(
                    textDirection: controller.getOrDefault('direction', LocaleHelper.autoDirection(textFieldCtr.text)),
                    controller: textFieldCtr,
                    minLines: 2,
                    maxLines: 3,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    style: AppThemes.baseTextStyle(),
                    onTap: () {
                      FocusHelper.fullSelect(textFieldCtr);
                    },
                    onChanged: (t){
                      controller.set('direction', LocaleHelper.autoDirection(t));
                      controller.update();
                    },
                    decoration: InputDecoration(
                      hintText: '${t('link')}',
                      border: InputBorder.none,
                    ),
                  );
                }
            ),

            const SizedBox(height: 40,),
            Center(
              child: ElevatedButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 50)),
                ),
                onPressed: (){
                  controller.uploadLink(textFieldCtr.text);
                },
                child: Text('${tC('apply')}'),
              ),
            )
          ],
        ),
      ),
    );

    final view = OverlayScreenView(
      content: SizedBox.expand(
        child: screen,
      ),
      routingName: screenName,
      backgroundColor: AppThemes.currentTheme.backgroundColor,
    );

    OverlayDialog().show(context, view).then((value){
      update();
    });
  }

  void showEditImageScreen(String screenName){
    final wList = <Map>[];

    wList.add({'title': '${t('camera')}',
      'icon': IconList.videoCamera,
      'fn': (){
        PermissionTools.requestCameraStoragePermissions().then((value) {
          if(value == PermissionStatus.granted){
            ImagePicker().pickImage(source: ImageSource.camera).then((value) {
              if(value == null) {
                return;
              }

              controller.editImage(value.path);
            });
          }
        });
      }});

    wList.add({'title': '${t('gallery')}',
      'icon': IconList.media,
      'fn': (){
        PermissionTools.requestStoragePermission().then((value) {
          if(value == PermissionStatus.granted){
            ImagePicker().pickImage(source: ImageSource.gallery).then((value) {
              if(value == null) {
                return;
              }

              controller.editImage(value.path);
            });
          }
        });
      }
    });


    Widget genView(elm){
      return ListTile(
        title: Text(elm['title']),
        leading: Icon(elm['icon']),
        onTap: (){
          SheetCenter.closeSheetByName(context, 'ChoosePhotoSource');
          elm['fn']?.call();
        },
      );
    }

    SheetCenter.showSheetMenu(context,
      wList.map(genView).toList(),
      'ChoosePhotoSource',);
  }

}

