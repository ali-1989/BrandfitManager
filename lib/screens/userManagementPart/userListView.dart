part of 'userManagementScreen.dart';

class UserListView extends StatefulWidget {
  final AppUserModel model;
  final UserModel admin;
  final List<UserListViewState> stateList;

  UserListView(this.model, this.admin, this.stateList, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UserListViewState();
  }
}
///======================================================================================
class UserListViewState extends StateBase<UserListView> {
  UserListViewCtr controller = UserListViewCtr();

  @override
  void initState() {
    super.initState();
    controller.onInitState(this);
  }

  @override
  Widget build(BuildContext context) {
    controller.onBuild();

    if(controller.pupilModel.profileFile == null){
      if(controller.pupilModel.profileImageUri != null){

        controller.pupilModel.profileImagePath ??= DirectoriesCenter.getSavePathUri(controller.pupilModel.profileImageUri, SavePathType.USER_PROFILE);

        PermissionTools.isGrantedStoragePermission().then((permission){
          //if (permission != PermissionStatus.granted){
          if (!permission){
            return;
          }

          final f = FileHelper.getFile(controller.pupilModel.profileImagePath!);

          f.exists().then((exist){
            if(exist){
              controller.pupilModel.profileFile = f;
              update();
            }
            else {
              final item = DownloadUpload.downloadManager.createDownloadItem(
                  controller.pupilModel.profileImageUri!,
                  tag: Keys.genDownloadTag_serverUser(controller.pupilModel),
                  savePath: controller.pupilModel.profileImagePath!
              );
              item.category = DownloadCategory.userProfile.toString();
              item.subCategory = controller.pupilModel.userId.toString();
              item.attach = controller.pupilModel;

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
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: (){
                        if(controller.pupilModel.profileFile == null){
                          return;
                        }

                        final view = ImageFullScreen(
                          imageType: ImageType.File,
                          heroTag: 'h${controller.pupilModel.userId}',
                          imageObj: controller.pupilModel.profileFile!,
                        );
                        AppNavigator.pushNextPageExtra(context, view, name: ImageFullScreen.screenName);
                      },
                      child: AvatarChip(
                          backgroundColor: ColorHelper.textToColor(controller.pupilModel.userName?? ''),
                          label: Text('${controller.pupilModel.userName}').color(Colors.white),
                          padding: const EdgeInsets.all(3),
                          avatar: controller.pupilModel.profileFile == null? null
                              : Hero(
                            tag: 'h${controller.pupilModel.userId}',
                            child: ClipOval(
                              clipBehavior: Clip.antiAlias,
                              child: Image.file(controller.pupilModel.profileFile!, width: 30, height: 30, scale: 0.5,),
                            ),
                          )
                      ),
                    ),

                    if(controller.pupilModel.type == 3)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                        child: const Icon(Icons.wb_twighlight).primaryOrAppBarItemOnBackColor(),
                      ),
                  ],
                ),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Badge(
                      padding: const EdgeInsets.all(4),
                      alignment: Alignment.topLeft,
                      badgeColor: Colors.lightGreen,
                      showBadge: controller.pupilModel.isOnline,
                      position: BadgePosition.topStart(),
                      child: Text(controller.pupilModel.touchTime),
                    ),
                  ],
                )
              ],
            ),

            const SizedBox(height: 8,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('ID: ${controller.pupilModel.userId}')
                    .subFont().alpha().wrapDotBorder(alpha: 200, color: Colors.grey),
              ],
            ),

            const SizedBox(height: 8,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${context.tC('name')}'),
                Text('${controller.pupilModel.name}').boldFont(),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${context.tC('family')}'),
                Text('${controller.pupilModel.family}').boldFont(),
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

            Row(
              //mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: (){
                    controller.gotoFullInfoScreen();
                  },
                  child: Text('${t('more')}'),
                ),
              ],
            )
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
}