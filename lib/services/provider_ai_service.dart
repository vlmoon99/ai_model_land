import 'package:ai_model_land/models/core/base_model.dart';
import 'package:ai_model_land/models/core/task_request_model.dart';
import 'package:ai_model_land/models/core/task_response_model.dart';

abstract class ProviderAiService {
  Future<TaskResponseModel> runTaskOnTheModel(TaskRequestModel request) =>
      throw UnsupportedError("No implementation");

  void checkPlatformGPUAcceleratorPossibilities(String params) =>
      throw UnsupportedError("No implementation");

  Future deleteModel() => throw UnsupportedError("No implementation");

  Future stopModel() => throw UnsupportedError("No implementation");

  Future restartModel(
          {required TaskRequestModel request, required BaseModel baseModel}) =>
      throw UnsupportedError("No implementation");

  Future addModel(
          {required TaskRequestModel request, required BaseModel baseModel}) =>
      throw UnsupportedError("No implementation");

  Future<bool> isModelLoaded() => throw UnsupportedError("No implementation");
}
