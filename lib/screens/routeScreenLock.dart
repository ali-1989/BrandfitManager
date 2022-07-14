part of 'routeScreen.dart';

class LockScreenTools {
  LockScreenTools._();

  static var _stateStep = 1;
  static String? _newPattern;


  static Widget getLockScreen(BuildContext context) {

    return PatternLockScreen(
      controller: BroadcastCenter.lockController,
      description: getDescription(context),
      onBack: (ctx, result) {
        SystemNavigator.pop();
        return true;
      },
      onResult: _onResult,
    );
  }

  static bool _onResult(BuildContext context, List<int>? result) {
    if (result == null) {
      return false;
    }

    if (mustSetPattern()) {
      if (_stateStep == 1) {
        if (result.length < 3) {
          return false;
        }

        _stateStep++;
        _newPattern = result.join();
        BroadcastCenter.lockController.setDescription(context.tInMap('lock&pattern', 'drawPatternAgain')!);
        return false;
      }

      if (_newPattern != result.join()) {
        return false;
      }

      DbCenter.setKv(Keys.sk$patternKey, result.join());

      Future(() {
        RouteCenter.navigateRouteScreen(HomeScreen.screenName);
      });
    }
    else {
      final current = DbCenter.fetchKv(Keys.sk$patternKey);

      if (result.join() == current) {
        Future(() {
          RouteCenter.navigateRouteScreen(HomeScreen.screenName);
        });
      }
    }

    return false;
  }

  static String getDescription(BuildContext context) {
    if (mustSetPattern()) {
      return context.tInMap('lock&pattern', 'drawPatternForLock')!;
    }

    return context.tInMap('lock&pattern', 'drawPattern')!;
  }

  static bool mustSetPattern(){
    return false;//DbCenter.fetchKv(Keys.sk$patternKey) == null;
  }

  static bool mustLock() {
    final currentPattern = DbCenter.fetchKv(Keys.sk$patternKey);

    if (currentPattern == null) {
      return false;
    }

    final lastForegroundTs = SettingsManager.settingsModel.lastForegroundTs;

    if (lastForegroundTs == null) {
      return true;
    }

    var lastForeground = DateHelper.tsToSystemDate(lastForegroundTs)!;
    lastForeground = lastForeground.add(const Duration(seconds: 30));

    if (lastForeground.isBefore(DateTime.now())) {
      return true;
    }

    return false;
  }
}
