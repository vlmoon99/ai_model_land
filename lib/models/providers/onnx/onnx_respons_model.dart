import 'package:ai_model_land/models/core/task_response_model.dart';

class OnnxResponsModel implements TaskResponseModel {
  List<Map<String, dynamic>>? predict;
  OnnxResponsModel({this.predict});
}
