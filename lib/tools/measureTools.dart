import '/models/dataModels/measureModel.dart';
import '/models/dataModels/usersModels/fitnessDataModel.dart';

class MeasureTools {
  MeasureTools._();

  static Map<NodeNames, MeasureModel> measures = {
    NodeNames.weight_node: MeasureModel.weight,
  NodeNames.height_node: MeasureModel.length,
  NodeNames.neck_node: MeasureModel.length,
  NodeNames.abdominal_node: MeasureModel.length,
  NodeNames.right_arm_node: MeasureModel.length,
  NodeNames.right_contracted_arm_node: MeasureModel.length,
  NodeNames.left_arm_node: MeasureModel.length,
  NodeNames.left_contracted_arm_node: MeasureModel.length,
  NodeNames.right_wrist_node: MeasureModel.length,
  NodeNames.left_wrist_node: MeasureModel.length,
  NodeNames.waist_node: MeasureModel.length,
  NodeNames.chest_node: MeasureModel.length,
  NodeNames.hip_node: MeasureModel.length,
  NodeNames.right_thigh_node: MeasureModel.length,
  NodeNames.left_thigh_node: MeasureModel.length,
  NodeNames.right_ankle_node: MeasureModel.length,
  NodeNames.left_ankle_node: MeasureModel.length
  };

  static MeasureModel getMeasureFor(NodeNames key){
    return measures[key]?? MeasureModel.unKnow;
  }

  static String getMeasureUnitFor(NodeNames key){
    return getMeasureFor(key).unit;
  }
}
