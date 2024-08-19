import 'package:ai_model_land/models/core/task_response_model.dart';

class TensorFlowResponseModel implements TaskResponseModel {
  Map<String, dynamic>? predictSingleWithLabels;
  List<dynamic>? predictForSingle;
  Map<String, double>? predictForSingleLasbles;
  Map<int, Object>? predictForMulti;

  TensorFlowResponseModel(
      {this.predictForSingle,
      this.predictSingleWithLabels,
      this.predictForMulti,
      this.predictForSingleLasbles});
}
