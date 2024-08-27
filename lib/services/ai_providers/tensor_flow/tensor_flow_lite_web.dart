import 'package:ai_model_land/models/core/base_model.dart';
import 'package:ai_model_land/models/core/task_request_model.dart';
import 'package:ai_model_land/models/core/task_response_model.dart';
import 'package:ai_model_land/services/ai_providers/tensor_flow/tensor_flow_lite_interface.dart'
    as _interface;
import 'package:ai_model_land/services/ai_providers/tensor_flow/tensor_flow_lite_interface.dart';

_interface.TensorFlowLite get instance => TensorFlowLiteWeb.defaultInstance();

class TensorFlowLiteWeb implements TensorFlowLite {
  TensorFlowLiteWeb();

  factory TensorFlowLiteWeb.defaultInstance() {
    return TensorFlowLiteWeb();
  }

  @override
  Future addModel(
      {required TaskRequestModel request, required BaseModel baseModel}) {
    throw UnsupportedError("No interaction for this os");
  }

  @override
  void checkPlatformGPUAcceleratorPossibilities(String params) {}

  @override
  Future deleteModel() {
    throw UnsupportedError("No interaction for this os");
  }

  @override
  bool isModelLoaded() {
    throw UnsupportedError("No interaction for this os");
  }

  @override
  Future restartModel(
      {required TaskRequestModel request, required BaseModel baseModel}) {
    throw UnsupportedError("No interaction for this os");
  }

  @override
  Future<TaskResponseModel> runTaskOnTheModel(TaskRequestModel request) {
    throw UnsupportedError("No interaction for this os");
  }

  @override
  Future stopModel() {
    throw UnsupportedError("No interaction for this os");
  }
}
