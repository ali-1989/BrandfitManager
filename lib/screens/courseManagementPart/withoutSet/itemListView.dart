part of 'managementWithoutSetScreen.dart';

class ItemListView extends StatefulWidget {
  final CourseModel model;
  final UserModel user;
  final CacheMap<String, Uint8List> imageCache;
  final List<ItemListViewState> stateList;

  ItemListView(this.model, this.imageCache, this.user, this.stateList, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ItemListViewState();
  }
}
///======================================================================================
class ItemListViewState extends StateBase<ItemListView> {
  var controller = ItemListViewCtr();

  @override
  void initState() {
    super.initState();
    controller.onInitState(this);
  }

  @override
  Widget build(BuildContext context) {
    controller.onBuild();
    controller.downloadImage();

    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: controller.gotoFullInfo,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                controller.model.title,
                                softWrap: true,
                                overflow: TextOverflow.fade,)
                                  .boldFont().bold(),
                            ),

                            /*Icon(IconList.dotsVerM, size: 18,)
                            //.toColor(Colors.white)
                            .primaryOrAppBarItemOnBackColor()
                            .wrapMaterial(
                              padding: EdgeInsets.all(7),
                              //materialColor: Colors.black.withAlpha(50),
                              onTapDelay: (){
                                showEditSheet();
                              }
                            ),*/
                          ],
                        ),

                        SizedBox(height: 4,),
                        Row(
                          children: [
                            Text('${controller.model.creatorUserName}')
                                .boldFont().alpha(),
                          ],
                        ),

                        SizedBox(height: 8,),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          textDirection: TextDirection.ltr,
                          mainAxisAlignment: AppThemes.isRtlDirection()? MainAxisAlignment.end : MainAxisAlignment.start,
                          children: [
                            Text('${CurrencyTools.formatCurrencyString(controller.model.price)} ')
                                .boldFont().alpha(),
                            SizedBox(width: 8,),
                            Text('${controller.model.currencyModel.currencyCode}')
                                .subFont().alpha(),
                          ],
                        ),

                        Row(
                          children: [
                            Flexible(
                              child: CheckBoxRow(
                                  value: controller.model.hasExerciseProgram,
                                  description: Text('${tInMap('courseManagementScreen', 'exercise')}').alpha(),
                                  onChanged: (v){}
                              ),
                            ),

                            Flexible(
                              child: CheckBoxRow(
                                  value: controller.model.hasFoodProgram,
                                  description: Text('${tInMap('courseManagementScreen', 'food')}').alpha(),
                                  onChanged: (v){}
                              ),
                            )
                          ],
                        ),

                        Visibility(
                          visible: controller.model.isBlock,
                            child: Row(
                              children: [
                                Icon(IconList.lock)
                                    .primaryOrAppBarItemOnBackColor(),
                              ],
                            )
                        ),

                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: TextButton(
                              onPressed: (){
                                showEditSheet();
                              },
                              child: Text('${t('settings')}')
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: SizedBox(
                      width: 120,
                      height: 140,
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: IrisImageView(
                          beforeLoadWidget: Image.asset('assets/images/placeHolder.png'),
                          filterQuality: FilterQuality.low,
                          url: controller.model.imageUri,
                          imagePath: DirectoriesCenter.getSavePathUri(controller.model.imageUri, SavePathType.COURSE_PHOTO),
                          cacheManager: widget.imageCache,
                          cacheKey: Keys.genCacheKey_course(controller.model),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
    var wList = <Map>[];

    wList.add({
      'title': '${tInMap('courseManagementScreen','properties')}',
      'icon': IconList.apps2,
      'fn': (){controller.showInfo();}});


    wList.add({
      'title': '${controller.model.isBlock? t('unblocking'): t('block')}',
      'icon': controller.model.isBlock? IconList.eye: IconList.eyeOff,
      'fn': (){
        yesFn(){
          AppNavigator.pop(context);
          controller.blockUnblock();
        }

        if(controller.model.isBlock){
          controller.blockUnblock();
          return;
        }

        DialogCenter().showYesNoDialog(context,
            yesFn: yesFn,
            desc: t('wantToBlockThisItem'));
      }
    });


    Widget genView(elm){
      return ListTile(
        title: Text(elm['title']),
        leading: Icon(elm['icon']),
        onTap: (){
          SheetCenter.closeSheetByName(context, 'EditMenu');
          elm['fn']?.call();
        },
      );
    }

    SheetCenter.showSheetMenu
      (context,
        wList.map(genView).toList(),
        'EditMenu'
    );
  }

}