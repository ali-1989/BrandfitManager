part of 'managementByTrainerScreen.dart';

class CourseItemListView extends StatefulWidget {
  final CourseModel model;
  final UserModel admin;
  final List<CourseItemListViewState> stateList;

  CourseItemListView(this.model, this.admin, this.stateList, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CourseItemListViewState();
  }
}
///======================================================================================
class CourseItemListViewState extends StateBase<CourseItemListView> {
  var controller = CourseItemListViewCtr();

  @override
  void initState() {
    super.initState();
    controller.onInitState(this);
  }

  @override
  Widget build(BuildContext context) {
    controller.onBuild();

    /*if(controller.model.imageUri == null){
      if(controller.model.imageUri != null){

        if(controller.model.imagePath == null) {
          controller.model.imagePath =
              PublicAccess.getSavePath(controller.model.imageUri, SavePathType.COURSE_PHOTO);
        }

        PermissionTools.requestStoragePermission().then((permission){
          if (permission != PermissionStatus.granted){
            return;
          }

          var f = FileHelper.getFile(controller.model.imagePath!);

          f.exists().then((exist){
            if(exist){
              controller.model.imagePath = f.path;
              update();
            }
            else {
              var item = DownloadUpload.downloadManager
                  .createDownloadItem(controller.model.imageUri!, controller.model.imagePath!);
              item.category = DownloadCategory.USER_PROFILE.toString();
              item.subCategory = controller.model.id.toString();
              item.attach = controller.model;

              DownloadUpload.downloadManager.enqueue(item);
            }
          });
        });
      }
    }*/

    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(controller.model.title),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(IconList.dotsVerM)
                          .primaryOrAppBarItemOnBackColor(),
                      alignment: Alignment.centerLeft,
                      onPressed: (){
                        showEditSheet();
                      },
                    )
                  ],
                )
              ],
            ),

            SizedBox(height: 8,),
            /*Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              textDirection: TextDirection.ltr,
              children: [
                TitleInfo(
                  title: 'ID: ',
                  info: '${controller.model.userId}',
                  boldOption: BoldOption.TITLE,
                ),
                TitleInfo(
                  title: '${context.tC('userName')}: ',
                  info: '${controller.model.userName}',
                  boldOption: BoldOption.TITLE,
                ),
              ],
            ),*/

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
    var v = SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 33),
      child: Table(
        defaultColumnWidth: FractionColumnWidth(0.5),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        textDirection: TextDirection.ltr,
        children: [
          TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: ElevatedButton(
                    child: Text('${context.tC('edit', key2: 'name')}'),
                    onPressed: (){
                      SheetCenter.closeSheetByName(context, 'EditUser');
                      //showEditNameScreen('EditNameScreen');
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: ElevatedButton(
                    child: Text('${context.tC('edit', key2: 'userName')}'),
                    onPressed: (){
                      SheetCenter.closeSheetByName(context, 'EditUser');
                      //showEditUserNameScreen('EditUserNameScreen');
                    },
                  ),
                )
              ]
          ),

        ],
      ),
    );

    var sheet = SheetCenter.generateCloseSheet(context, v, 'EditUser', backColor: Colors.white);
    SheetCenter.showModalSheet(context, (_)=> sheet, routeName: 'EditUser');
  }

  /*void showEditNameScreen(String screenName){
    TextEditingController nameCtr = TextEditingController();
    TextEditingController familyCtr = TextEditingController();
    nameCtr.text = controller.model.name!;
    familyCtr.text = controller.model.family!;

    Widget screen = Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 42),
        child: Column(
          children: [
            SelfRefresh(
                childBuilder: (BuildContext context, UpdateController controller) {
                  return TextFormField(
                    textDirection: controller.getOrDefault('direction', LocaleHelper.autoDirection(nameCtr.text)),
                    controller: nameCtr,
                    //validator: (_) => validation(state, userNameCtl),
                    textInputAction: TextInputAction.next,
                    style: AppThemes.baseTextStyle(),
                    onTap: () {
                      FocusHelper.fullSelect(nameCtr);
                    },
                    onChanged: (t){
                      controller.set('direction', LocaleHelper.autoDirection(t));
                      controller.update();
                    },
                    onFieldSubmitted: (_) {
                      *//*no need focusNode.nextFocus();*//*
                    },
                    decoration: InputDecoration(
                      hintText: '${t('name')}',
                      border: InputBorder.none,
                    ),
                  );
                }
            ),

            SelfRefresh(
                childBuilder: (BuildContext context, UpdateController controller) {
                  return TextFormField(
                    textDirection: controller.getOrDefault('direction', LocaleHelper.autoDirection(familyCtr.text)),
                    controller: familyCtr,
                    //validator: (_) => validation(state, userNameCtl),
                    textInputAction: TextInputAction.done,
                    style: AppThemes.baseTextStyle(),
                    onTap: () {
                      FocusHelper.fullSelect(familyCtr);
                    },
                    onChanged: (t){
                      controller.set('direction', LocaleHelper.autoDirection(t));
                      controller.update();
                    },
                    onFieldSubmitted: (_) {
                      *//*no need focusNode.nextFocus();*//*
                    },
                    decoration: InputDecoration(
                      hintText: '${t('family')}',
                      border: InputBorder.none,
                      //hintStyle: TextStyle(color: Colors.white),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppThemes.currentTheme.textColor)),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppThemes.currentTheme.textColor)),
                    ),
                  );
                }
            ),

            SizedBox(height: 40,),
            Center(
              child: ElevatedButton(
                child: Text('${tC('apply')}'),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 50)),
                ),
                onPressed: (){
                  controller.uploadName(nameCtr.text, familyCtr.text);
                },
              ),
            )
          ],
        ),
      ),
    );

    OverlayScreenView view = OverlayScreenView(
      content: SizedBox.expand(
        child: screen,
      ),
      routingName: screenName,
      backgroundColor: AppThemes.currentTheme.backgroundColor,
    );

    OverlayDialog().show(context, view).then((value){
      nameCtr.dispose();
      familyCtr.dispose();
      update();
    });
  }

  void showEditGenderScreen(String screenName){
    int selectedGender = controller.model.sexInt!-1; //1 man, 2 woman

    if(selectedGender < 0){
      selectedGender = 0;
    }

    Widget view = MultiViewDialog.addCloseBtn(context,
      SizedBox(
        width: AppSizes.getScreenWidth(context),
        child: ColoredBox(
          color: AppThemes.currentTheme.backgroundColor,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 40),
            child: FlipInX(
              delay: Duration(milliseconds: 300),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('${tC('gender')}:').bold().fs(16),
                  SizedBox(height: AppSizes.fwSize(16),),
                  ToggleSwitch(
                    initialLabelIndex: selectedGender,
                    cornerRadius: 12.0,
                    //minWidth: 100,
                    activeBgColor: [AppThemes.currentTheme.activeItemColor],
                    inactiveBgColor: Colors.grey[400],
                    activeFgColor: Colors.white,
                    inactiveFgColor: AppThemes.currentTheme.inactiveTextColor,
                    totalSwitches: 2,
                    labels: [tC('male')!, tC('female')!],
                    onToggle: (index) {
                      selectedGender = index;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      withExpanded: false,
      navName: 'ChangeSex',
    );

    SheetCenter.showSheetCustom(
      context,
      view,
      positiveButton: ElevatedButton(
        child: Text('${tC('apply')}'),
        onPressed: (){
          controller.uploadGender(selectedGender+1);
        },
      ),
      routeName: 'ChangeSex',
      backgroundColor: Colors.transparent,
      contentColor: Colors.transparent,
      buttonBarColor: AppThemes.currentTheme.backgroundColor,
    ).then((value){
      update();
    });
  }

  void showEditBirthdateScreen(String screenName){
    DateTime birthDate = controller.model.birthDate?? DateTime(DateTime.now().year-10);
    bool isGregorian = Settings.calendarType.type == TypeOfCalendar.Gregorian;
    int selectedYear = birthDate.year;
    int selectedMonth = birthDate.month;

    if(!isGregorian) {
      ADateStructure solar = SolarHijriDate.convertGregorianToSolar(birthDate.year, birthDate.month, 1);
      selectedYear = solar.getYear();
      selectedMonth = solar.getMonth();
    }

    Widget view = MultiViewDialog.addCloseBtn(context,
      SizedBox(
        width: AppSizes.getScreenWidth(context),
        child: ColoredBox(
          color: AppThemes.currentTheme.backgroundColor,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 40),
            child: FlipInX(
              delay: Duration(milliseconds: 300),
              child: SelfRefresh(
                  childBuilder:(ctx, ctr){
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('${tC('birthDate')}:').bold().fs(16),
                        SizedBox(height: AppSizes.fwSize(16),),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          textDirection: TextDirection.ltr,
                          children: [
                            ///--- year
                            SizedBox(
                              //width: AppSizes.rSize(90),
                              height: AppSizes.fwSize(120),
                              child: NumberPicker(
                                minValue: isGregorian? DateTime.now().year-90 : SolarHijriDate().getYear()-90,
                                maxValue: isGregorian? DateTime.now().year-7: SolarHijriDate().getYear()-7,
                                value: selectedYear,
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
                                textMapper: (t){
                                  return t.toString().localeNum(Settings.appLocale);
                                },
                                onChanged: (val){
                                  selectedYear = val;
                                  ctr.update();
                                },
                              ),
                            ),

                            ///--- month
                            SizedBox(
                              width: AppSizes.fwSize(60),
                              height: AppSizes.fwSize(120),
                              child: NumberPicker(
                                minValue: 1,
                                maxValue: 12,
                                value: selectedMonth,
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
                                infiniteLoop: true,
                                textMapper: (t){
                                  return t.toString().localeNum(Settings.appLocale);
                                },
                                onChanged: (val){
                                  selectedMonth = val;
                                  ctr.update();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
              ),
            ),
          ),
        ),
      ),
      navName: screenName,
    );

    SheetCenter.showSheetCustom(
      context,
      view,
      positiveButton: ElevatedButton(
        child: Text('${tC('apply')}'),
        onPressed: (){
          DateTime date;

          if(isGregorian)
            date = GregorianDate.date(selectedYear, selectedMonth, 1).convertToSystemDate();
          else
            date = SolarHijriDate.date(selectedYear, selectedMonth, 1).convertToSystemDate();

          controller.uploadBirthDate(date);
        },
      ),
      routeName: screenName,
      backgroundColor: Colors.transparent,
      contentColor: Colors.transparent,
      buttonBarColor: AppThemes.currentTheme.backgroundColor,
    ).then((value){
      update();
    });
  }*/
}