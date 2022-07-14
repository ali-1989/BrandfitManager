import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

import '/models/dataModels/chartModels/nodeDataModel.dart';
import '/models/dataModels/usersModels/fitnessDataModel.dart';
import '/tools/dateTools.dart';

class ChartDataModel {
  late final NodeNames _nodeName;
  late List<NodeDataModel> _nodeList;
  List<NodeDataModel> workNodeList = [];
  double? maxValue;
  double? minValue;
  double? lastLogDateValue;
  double _minYaxis = -1;
  double _maxYaxis = -1;
  double _intervalY = -1;
  int days = 0;
  int measure = 100;
  final int _d30 = 30;
  final int _c30 = 25;

  ChartDataModel(NodeNames nodeName): _nodeName = nodeName;

  ChartDataModel.of(NodeNames nodeName, List<NodeDataModel> list){
    _nodeName = nodeName;
    final dots = <NodeDataModel>[];

    var max = 0.0;
    var min = 0.0;

    if(list.isNotEmpty){
      max = list.first.value!;
      min = max;

      for(var k in list){
        if(max < k.value!) {
          max = k.value!;
        }

        if(min > k.value!) {
          min = k.value!;
        }

        dots.add(k);
      }

      NodeDataModel.sort(dots);

      maxValue = max;
      minValue = min;

      final first = dots.first.utcDate;
      var last = dots.last.utcDate;

      if(dots.length == 1) {
        last = DateTime.now();
      }

      days = DateHelper.daysDifference(first!, last!);
    }

    _nodeList = dots;
  }

  void reset(){
    measure = 100;
    lastLogDateValue = null;
    workNodeList = [];
    _minYaxis = -1;
    _maxYaxis = -1;
    _intervalY = -1;
  }

  NodeDataModel? findByX(double x){
    for(var d in workNodeList){
      if(d.x == x) {
        return d;
      }
    }

    return null;
  }

  NodeDataModel? findByXp(double x){
    for(var d in workNodeList){
      if((d.x - x).abs() <= (0.6 +((100-measure) /10) * .05) ) {
        return d;
      }
    }

    return null;
  }

  NodeDataModel? findByY(double val){
    for(var d in workNodeList){
      if(d.value == val) {
        return d;
      }
    }

    return null;
  }

  double getChartMinYAxisLines(){
    if(_minYaxis < 0) {
      if (minValue != null) {
        if (minValue! % 10 == 0) {
          _minYaxis = minValue! - 4;
        } else {
          _minYaxis = minValue! - (minValue! % 10);
        }
      }
      else {
        _minYaxis = FitnessDataModel.getMinValueForKey(_nodeName);
      }
    }

    return _minYaxis;
  }

  double getChartMaxYAxisLines(){
    if(_maxYaxis < 0) {
      if (maxValue != null) {
        if (maxValue == minValue) {
          _maxYaxis = getChartMinYAxisLines() + 40;
        } else {
          final dif = maxValue! - getChartMinYAxisLines();
          _maxYaxis = (dif < 30) ? maxValue! + (30 - dif) : maxValue! + 2;
        }
      }
      else {
        _maxYaxis = getChartMinYAxisLines() + 40;
      }
    }

    return _maxYaxis;
  }

  double getChartYInterval(){
    if(_intervalY < 0) {
      if (minValue == null) {
        _intervalY = 5;
      } else {
        final dif = maxValue! - minValue!;

        if (dif < 40) {
          _intervalY = 4;
        } else if (dif < 80) {
          _intervalY = 8;
        } else if (dif < 110) {
          _intervalY = 10;
        } else {
          _intervalY = 12;
        }
      }
    }

    return _intervalY;
  }

  double getChartMaxXAxisLines(){
    measureX();
    prepareWorkDots();

    if(workNodeList.isEmpty) {
      return 10;
    }

    if(days < 16) {
      return days + 8;
    } // 8> 4,4 ends

    return (days * measure/100) + 3;
  }

  void measureX(){
    if(days <= _d30) {
      return;
    }

    while(days*measure /100 > _d30){
      measure = measure - (measure ~/ 10);
    }
  }

  void prepareWorkDots() {
    if(workNodeList.isNotEmpty) {
      return;
    }

    workNodeList.addAll(_nodeList);

    if(workNodeList.length <= _c30) {
      return;
    }

    var check = 0;

    bool isSquare(NodeDataModel current, NodeDataModel before){//next: can add 3 dot and check direction ->  <- for check
      return (current.value! - before.value!).abs() < check;
    }

    final temp = <NodeDataModel>[];
    final removes = <int>[];

    while(workNodeList.length > _c30) {
      temp.clear();
      removes.clear();
      temp.addAll(workNodeList);

      workNodeList.clear();
      workNodeList.add(temp.first);

      for (var i = 1; i < temp.length - 1; i++) {
        final dot = temp.elementAt(i);

        if (!isSquare(dot, workNodeList.last)) {
          workNodeList.add(dot);
        } else {
          removes.add(i);
        }
      }

      if(removes.isNotEmpty) {

        if (temp.length - removes.length +2 >= _c30) {

        }
        else {
          final mustRemove = temp.length - _c30;
          final remain = removes.length % mustRemove;
          final removes2 = <int>[];

          if(remain == 0){
            final step = removes.length ~/ mustRemove;

            for (var i = 0; i < removes.length; i += step-1) {
              removes2.add(i);
            }
          }
          else {
            final step1 = (removes.length / mustRemove).ceil();
            final step2 = (removes.length / mustRemove).floor();
            var s1 = false;

            for (var i = 0; i < removes.length; ) {
              removes2.add(i);

              if(removes2.length == mustRemove) {
                break;
              }

              if(!s1){
                i += step1;
                s1 = true;
              }
              else{
                i += step2;
                s1 = false;
              }
            }
          }

          for (var i = 1; i < temp.length - 1; i++) {
            if (removes2.contains(i)) {
              continue;
            }

            workNodeList.add(temp.elementAt(i));
          }
        }

        removes.clear();
      }

      workNodeList.add(temp.last);
      check++;

      if(workNodeList.length > 100) {
        break;
      }
    }
  }

  void prepareX(){
    measureX();
    prepareWorkDots();

    final len = workNodeList.length;

    if(len < 1) {
      return;
    }

    var step = 4.0;

    if(days > 15) {
      step = 1;
    }

    for(var i=0; i<len; i++){
      final dot = workNodeList.elementAt(i);
      dot.x = step;

      if(i < len-1) {
        final next = workNodeList.elementAt(i+1);
        final dif = DateHelper.daysDifference(dot.utcDate!, next.utcDate!);
        step += MathHelper.fixPrecisionRound(dif * measure/100, 1);
        step = MathHelper.fixPrecision(step, 1);
      }
    }
  }

  String getDateTitle(double value){
    if(value < 1) {
      lastLogDateValue = null;
      return '';
    }

    final dot = findByXp(value);

    if(dot == null) {
      return '';
    }

    if(lastLogDateValue == null){
      lastLogDateValue = value;

      return DateTools.dateRelativeByAppFormat(dot.utcDate, format: 'MM/DD');
    }
    else {
      if(lastLogDateValue! + 1 < value){
        lastLogDateValue = value;
        return DateTools.dateRelativeByAppFormat(dot.utcDate, format: 'MM/DD');
      }
    }

    return '';
  }
}
