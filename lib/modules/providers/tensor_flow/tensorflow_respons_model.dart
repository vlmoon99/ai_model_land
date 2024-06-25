import 'package:ai_model_land/modules/core/task_response_model.dart';

class TensorFlowResponsModel implements TaskResponseModel {
  Map<String, double>? predictWithLables;
  List<double>? predict;

  TensorFlowResponsModel({this.predict, this.predictWithLables});
}
