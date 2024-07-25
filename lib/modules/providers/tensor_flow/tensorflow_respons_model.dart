import 'package:ai_model_land/modules/core/task_response_model.dart';

class TensorFlowResponseModel implements TaskResponseModel {
  Map<String, dynamic>? predictSingleWithLabels;
  List<dynamic>? predictForSingle;
  Map<int, Object>? predictForMulti;

  TensorFlowResponseModel(
      {this.predictForSingle,
      this.predictSingleWithLabels,
      this.predictForMulti});
}
