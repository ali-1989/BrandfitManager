import 'package:flutter/material.dart';

import '/abstracts/stateBase.dart';
import '/models/dataModels/foodModels/materialModel.dart';
import '/screens/foodManagerPart/editMaterial/editSameWordsScreenCtr.dart';
import '/system/extensions.dart';
import '/system/icons.dart';

class EditSameWordsScreen extends StatefulWidget {
  static final screenName = 'EditSameWordsScreen';
  final MaterialModel materialModel;

  EditSameWordsScreen(this.materialModel, {Key? key}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EditSameWordsScreenState();
  }
}
///=====================================================================================================
class EditSameWordsScreenState extends StateBase<EditSameWordsScreen> {
  var controller = EditSameWordScreenCtr();


  @override
  void initState() {
    super.initState();
    controller.onInitState(this);
  }

  @override
  Widget build(BuildContext context) {
    rotateToPortrait();
    controller.onBuild();

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30,),
            Expanded(
              child: Card(
                color: Colors.grey.shade300,
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${tInMap('foodProgramScreen','sameWords')}:')
                              .boldFont().alpha(),

                          IconButton(
                              icon: Icon(IconList.addCircle).primaryOrAppBarItemOnBackColor(),
                              onPressed: (){
                                controller.onAddClick();
                              }),
                        ],
                      ),

                      Wrap(
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        runAlignment: WrapAlignment.start,
                        direction: Axis.horizontal,
                        spacing: 2,
                        children: [
                          ...genAlternativesItems()
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  //style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 5)),
                  child: Text('${t('save')}'),
                  onPressed: (){
                    controller.uploadSameWords();
                  },
                ),
              ),
            ),

            const SizedBox(height: 30,),
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
  ///==============================================================================================
  List<Widget> genAlternativesItems(){
    List<Widget> res = [];

    for(var i in controller.alternatives){
      var w = Chip(
        backgroundColor: Colors.black54,
        label: Text(i),
        onDeleted: (){
          controller.alternatives.remove(i);
          update();
        },
      );

      res.add(w);
    }

    return res;
  }
}
