import 'package:ai_model_land/modules/core/base_model.dart';
import 'package:ai_model_land/modules/core/task_request_model.dart';
import 'package:ai_model_land/modules/core/task_response_model.dart';

abstract class ProviderAiService {
  Future<TaskResponseModel> runTaskOnTheModel(TaskRequestModel request);

  void checkPlatformGPUAcceleratorPossibilities(String params);

  Future deleteModal();

  Future stopModal();

  Future restartModal({required BaseModel baseModel});

  Future addModalFromFile({required BaseModel baseModel});

  bool isModelLoaded();
}
