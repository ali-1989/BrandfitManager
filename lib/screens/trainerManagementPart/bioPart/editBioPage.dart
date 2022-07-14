import 'package:flutter/material.dart';

import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';

import '/abstracts/stateBase.dart';
import '/system/keys.dart';
import '/system/requester.dart';
import '/system/session.dart';
import '/tools/centers/sheetCenter.dart';

class EditBioPage extends StatefulWidget {
  static const screenName = 'EditBioPage';
  final quill.Delta? preBio;

  const EditBioPage({this.preBio, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EditBioPageState();
}
///==========================================================================================
class _EditBioPageState extends StateBase<EditBioPage> {
  late quill.QuillController controller;
  late Requester commonRequester;
  List? callBackPop;

  @override
  void initState() {
    super.initState();

    if(widget.preBio == null) {
      controller = quill.QuillController.basic();
    }
    else {
      controller = quill.QuillController(
        document: quill.Document.fromDelta(widget.preBio!),
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    commonRequester = Requester();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        Future.delayed(Duration(milliseconds: 100), (){
          Navigator.of(context).pop(callBackPop);
        });

        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${tInMap('bioPage', 'editPageTitle')}'),
        ),

        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 10,),
              quill.QuillToolbar.basic(
                  controller: controller,
                multiRowsDisplay: true,
                showRedo: false,
                showDividers: false,
                showClearFormat: true,
                showCameraButton: false,
                showCodeBlock: false,
                showBackgroundColorButton: false,
                showImageButton: false,
                showInlineCode: false,
                showListCheck: false,
                showVideoButton: false,
                showLink: false,
                showAlignmentButtons: true,
                showQuote: false,
              ),

              SizedBox(height: 14,),
              Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: quill.QuillEditor.basic(
                        controller: controller,
                        readOnly: false,
                      ),
                    ),
                  ),
              ),

              SizedBox(height: 10,),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () async {
                      requestSave();
                    },
                    child: Text('${t('save')}')
                ),
              ),

              SizedBox(height: 10,),
            ],
          ),
        ),
      ),
    );
  }
  ///-----------------------------------------------------------------------------------
  void requestSave() {
    FocusHelper.hideKeyboardByService();
    final user = Session.getLastLoginUser()!;

    final js = <String, dynamic>{};
    js[Keys.request] = 'SetTrainerBio';
    js[Keys.userId] = user.userId;
    js[Keys.forUserId] = user.userId;
    js[Keys.data] = JsonHelper.objToJson(controller.document.toDelta().toJson());
    //js[Keys.filtering] = filterRequest.toMap();

    commonRequester.requestPath = RequestPath.SetData;
    commonRequester.bodyJson = js;

    commonRequester.httpRequestEvents.onFailState = (req) async {
      await hideLoading();
      SheetCenter.showSheet$OperationFailedTryAgain(context);
    };

    commonRequester.httpRequestEvents.onResultError = (req, data) async {
      return true;
    };

    commonRequester.httpRequestEvents.onResultOk = (req, data) async {
      callBackPop = controller.document.toDelta().toJson();
      await hideLoading();
      SheetCenter.showSheet$SuccessOperation(context);
    };

    showLoading();
    commonRequester.request(context);
  }
}
