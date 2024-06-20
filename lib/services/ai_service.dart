import 'package:ai_model_land/modules/core/models/base_model.dart';
import 'package:ai_model_land/modules/core/models/task_response_model.dart';
import 'package:ai_model_land/modules/core/models/task_request_model.dart';
import 'package:ai_model_land/services/file_interaction/local-network_service.dart';

class AiService {
  final NetworkService networkInteraction;

  AiService({required this.networkInteraction}) {}

  factory AiService.defaultInstance() {
    return AiService(
      networkInteraction: NetworkService.defaultInstance(),
    );
  }
  //Base function from where you can run models in you project, you will need to pass the params
  //We will need to choose type of the source (which type of this model it is, tensorfolw js , pytorch, transofrmer js, tf lite , etc)
  //Also we need to choose the source (Network,Assets) and the path
  TaskResponseModel runTaskOnTheModel(TaskRequestModel request) {
    return TaskResponseModel();
  }

  //Check what platform we have, which optionals for AI models we have (GPU,TPU,CPU, etc)
  void checkPlatformGPUAcceleratorPossibilities(String params) {}

  Future<BaseModel> downloadFileToAppDir({required BaseModel baseModel}) async {
    return await networkInteraction.downloadModelToAppDir(baseModel: baseModel);
  }

  Future<BaseModel> fileInteraction({required BaseModel baseModel}) async {
    if (baseModel.sourceType == ModelSourceType.network) {
      final baseModelNetwork = await downloadFileToAppDir(baseModel: baseModel);
      return baseModelNetwork;
    } else {
      return baseModel;
    }
  }

  Future<void> deleteFileFromAppDir({required BaseModel baseModel}) async {
    await networkInteraction.deleteModalFromAppDir(model: baseModel);
  }
}
