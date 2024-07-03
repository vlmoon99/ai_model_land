import 'package:ai_model_land/modules/core/task_response_model.dart';

class TensorFlowResponsModel implements TaskResponseModel {
  Map<String, dynamic>? predictSinglWithLables;
  List<dynamic>? predictForSingle;
  Map<int, Object>? predictForMulti;
  TensorFlowResponsModel(
      {this.predictForSingle,
      this.predictSinglWithLables,
      this.predictForMulti});
}
