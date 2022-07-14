part of 'supportScreen.dart';

class AllTicketsPage extends StatefulWidget {
  final SupportScreenState parentState;

  const AllTicketsPage({
    Key? key,
    required this.parentState,
  }) : super(key: key);

  @override
  State createState() => AllTicketsPageState();
}
///======================================================================================
class AllTicketsPageState extends State<AllTicketsPage> {
  var stateController = StateXController();
  var controller = AllTicketsPageCtr();

  @override
  void initState() {
    super.initState();

    controller.onInitState(this);
  }

  @override
  Widget build(BuildContext context) {
    controller.onBuild();

    return getMainBuilder();
  }

  @override
  void dispose() {
    stateController.dispose();
    controller.onDispose();

    super.dispose();
  }

  Widget getMainBuilder() {
    return StateX(
        controller: stateController,
        isMain: true,
        builder: (context, ctr, data) {
          if (controller.myTicketList.isEmpty) {
            if(controller.parentState.controller.waitingToPrepare){
              return PreWidgets.flutterLoadingWidget$Center();
            }
            else {
              return NotDataFoundView();
            }
          }

          return pull.RefreshConfiguration(
              headerBuilder: pullHeader,
              footerBuilder: () => pull.ClassicFooter(),
              headerTriggerDistance: 80.0,
              footerTriggerDistance: 200.0,
              maxOverScrollExtent: 100,
              maxUnderScrollExtent: 0,
              enableScrollWhenRefreshCompleted: true,
              // incompatible with PageView and TabBarView.
              enableLoadingWhenFailed: true,
              hideFooterWhenNotFull: true,
              enableBallisticLoad: false,
              enableBallisticRefresh: false,
              skipCanRefresh: true,
              child: pull.SmartRefresher(
                enablePullDown: true,
                enablePullUp: true,
                controller: controller.pullLoadCtr,
                onRefresh: () => controller.onRefresh(),
                onLoading: () => controller.onLoadMore(),
                footer: pullFooter(),
                child: ListView.builder(
                  itemCount: controller.myTicketList.length,
                  itemBuilder: (ctx, idx) {
                    final itm = controller.myTicketList[idx];
                    return ListChildTicket(ticketModel: itm, key: ValueKey(itm.id),);
                  },
                ),
              ));
        });
  }

  Widget pullHeader(){
    return pull.MaterialClassicHeader(
      color: AppThemes.checkPrimaryByWB(AppThemes.currentTheme.primaryColor, AppThemes.currentTheme.differentColor),
      //refreshStyle: pull.RefreshStyle.Follow,
    );
  }

  Widget pullFooter(){
    return pull.CustomFooter(
      loadStyle: pull.LoadStyle.ShowWhenLoading,
      builder: (BuildContext context, pull.LoadStatus? state) {
        if (state == pull.LoadStatus.loading) {
          return SizedBox(
            height: 80,
            child: PreWidgets.flutterLoadingWidget$Center(),
          );
        }

        if (state == pull.LoadStatus.noMore || state == pull.LoadStatus.idle) {
          return SizedBox();
        }

        return SizedBox();
      },
    );
  }
}
