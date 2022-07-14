import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/helpers/pathHelper.dart';
import 'package:iris_tools/features/overlayDialog.dart';
import 'package:iris_tools/modules/stateManagers/stateX.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '/abstracts/viewController.dart';
import '/models/dataModels/photoDataModel.dart';
import '/models/dataModels/usersModels/appUserModel.dart';
import '/models/dataModels/usersModels/userModel.dart';
import '/screens/trainerManagementPart/bioPart/bioScreen.dart';
import '/system/enums.dart';
import '/system/keys.dart';
import '/system/queryFiltering.dart';
import '/system/requester.dart';
import '/system/session.dart';
import '/tools/centers/dialogCenter.dart';
import '/tools/centers/directoriesCenter.dart';
import '/tools/centers/httpCenter.dart';
import '/tools/centers/snackCenter.dart';
import '/tools/uriTools.dart';
import '/views/brokenImageView.dart';
import '/views/loadingScreen.dart';

class BioScreenCtr implements ViewController {
  late BioScreenState state;
  late Requester commonRequester;
  late FilterRequest filterRequest;
  late UserModel user;
  late AppUserModel trainerModel;
  late quill.QuillController bioCtr;
  String? biography;
  List<PhotoDataModel> photos = [];

  @override
  void onInitState<E extends State>(E state){
    this.state = state as BioScreenState;

    state.stateController.mainState = StateXController.state$loading;
    bioCtr = quill.QuillController.basic();

    user = Session.getLastLoginUser()!;
    trainerModel = state.widget.trainerModel;
    filterRequest = FilterRequest();
    filterRequest.limit = 100;

    commonRequester = Requester();

    prepareFilterOptions();
    requestBio();
  }

  @override
  void onBuild(){
  }

  @override
  void onDispose(){
    HttpCenter.cancelAndClose(commonRequester.httpRequester);
  }

  void prepareFilterOptions(){
    filterRequest.addSearchView(SearchKeys.titleKey);
  }
  ///========================================================================================================
  void openGallery(int idx){
    final pageController = PageController(initialPage: idx,);

    final Widget gallery = PhotoViewGallery.builder(
      scrollPhysics: BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      enableRotation: false,
      gaplessPlayback: true,
      reverse: false,
      //customSize: Size(AppSizes.getScreenWidth(state.context), 200),
      itemCount: photos.length,
      pageController: pageController,
      //onPageChanged: onPageChanged,
      backgroundDecoration: BoxDecoration(
        color: Colors.black,
      ),
      builder: (BuildContext context, int index) {
        final ph = photos.elementAt(index);

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

              ? CircularProgressIndicator()
              : CircularProgressIndicator(value: progress.cumulativeBytesLoaded / progress.expectedTotalBytes!,),
        ),
      ),
    );

    final osv = OverlayScreenView(
      content: gallery,
      routingName: 'Gallery',
    );

    OverlayDialog().show(state.context, osv);
  }

  void deleteDialog(PhotoDataModel photo){
    final desc = state.tC('wantToDeleteThisItem')!;

    void yesFn(){
      deletePhoto(photo);
    }

    DialogCenter().showYesNoDialog(state.context, desc: desc, yesFn: yesFn,);
  }

  void deletePhoto(PhotoDataModel photo) {
    final js = <String, dynamic>{};
    js[Keys.request] = 'DeleteBioPhoto';
    js[Keys.userId] = user.userId;
    js[Keys.forUserId] = trainerModel.userId;
    js[Keys.imageUri] = photo.uri;

    commonRequester.requestPath = RequestPath.SetData;
    commonRequester.bodyJson = js;

    commonRequester.httpRequestEvents.onFailState = (req) async {
      await LoadingScreen.hideLoading(state.context);
      SnackCenter.showSnack$OperationFailed(state.context);
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      return true;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      await LoadingScreen.hideLoading(state.context);

      try {
        photos.removeWhere((e) => e.uri == photo.uri);
      }
      catch (e){}

      state.stateController.updateMain();
    };

    LoadingScreen.showLoading(state.context, canBack: false);
    commonRequester.request(state.context);
  }

  void requestBio() {
    FocusHelper.hideKeyboardByService();

    final js = <String, dynamic>{};
    js[Keys.request] = 'GetTrainerBio';
    js[Keys.userId] = user.userId;
    js[Keys.forUserId] = trainerModel.userId;
    //js[Keys.filtering] = filterRequest.toMap();

    commonRequester.requestPath = RequestPath.GetData;
    commonRequester.bodyJson = js;

    commonRequester.httpRequestEvents.onFailState = (req) async {
      state.stateController.mainStateAndUpdate(StateXController.state$serverNotResponse);
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      return true;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      biography = data['bio'];
      final images = data['photos'];
      final domain = data[Keys.domain];

      for(final k in images){
        final name = PathHelper.getFileName(k);
        final pat = DirectoriesCenter.getSavePathByPath(SavePathType.USER_PROFILE, name)!;

        final p = PhotoDataModel();
        p.uri = UriTools.correctAppUrl(k, domain: domain);
        p.localPath = pat;

        photos.add(p);
      }

      if(biography != null) {
        var bioList = JsonHelper.jsonToList(biography)!;

        bioCtr = quill.QuillController(
            document: quill.Document.fromJson(bioList),
            selection: TextSelection.collapsed(offset: 0)
        );
      }

      state.stateController.mainStateAndUpdate(StateXController.state$normal);
    };

    commonRequester.request(state.context);
  }
}
