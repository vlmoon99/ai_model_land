import 'package:ai_model_land/modules/core/models/base_model.dart';
import 'package:ai_model_land/modules/core/models/task_request_model.dart';
import 'package:ai_model_land/modules/core/models/task_response_model.dart';

abstract class ProviderAiService {
  Future<TaskResponseModel> runTaskOnTheModel(TaskRequestModel request);

  void checkPlatformGPUAcceleratorPossibilities(String params);

  Future deleteModal();

  Future stopModal();

  Future restartModal();

  Future addModalFromFile({required BaseModel baseModel});
}
