import 'package:brandfit_manager/database/models/requestHybridModelDb.dart';
import 'package:brandfit_manager/screens/requestCoursePart/showPrograms/programViewCtr.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/stateX.dart';

import '/abstracts/stateBase.dart';
import '/system/extensions.dart';
import '/tools/dateTools.dart';

class ProgramViewScreen extends StatefulWidget {
  static const screenName = 'ProgramViewScreen';
  final RequestHybridModelDb requestHybridModel;

  const ProgramViewScreen({
    Key? key,
    required this.requestHybridModel,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ProgramViewScreenState();
}
///=====================================================================================
class ProgramViewScreenState extends StateBase<ProgramViewScreen> {
  StateXController stateController = StateXController();
  ProgramViewCtr controller = ProgramViewCtr();

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
        title: Text(widget.requestHybridModel.title),
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
    return ListView.builder(
      itemCount: controller.programList.length,
        itemBuilder: (ctx, idx){
          return genItem(idx);
        }
    );
  }

  Widget genItem(int idx){
    final program = controller.programList[idx];

    return Card(
      color: Colors.grey.shade200,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${program.title}'.localeNum())
                .boldFont().fsR(5),

            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Text('${tInMap('programsPage', 'incloude')}: ${program.foodDays.length} ${t('days')}'.localeNum())
                    .boldFont().alpha(),
              ],
            ),

            Text('${tInMap('programsPage', 'endOfSupport')}: ${DateTools.dateOnlyRelative(widget.requestHybridModel.supportExpireDate)}')
                .boldFont().alpha(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${t('sendDate')}: ${DateTools.dateOnlyRelative(program.sendDate)}')
                    .boldFont().alpha(),

                TextButton(
                    onPressed: (){
                      controller.gotoTreeView(program);
                    },
                    child: Text('${tInMap('coursePage', 'content')}')
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
