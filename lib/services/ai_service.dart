import 'package:ai_model_land/modules/core/models/base_model.dart';
import 'package:ai_model_land/modules/core/models/task_response_model.dart';
import 'package:ai_model_land/modules/core/models/task_request_model.dart';
import 'package:ai_model_land/services/local-network_file/file_interaction/local_interaction.dart';
import 'package:ai_model_land/services/local-network_file/file_interaction/network_interaction.dart';
import 'package:ai_model_land/services/local-network_file/local-network_service.dart';

class AiService {
  final Map<ModelSourceType, LocalNetworkService> fileInteraction = {};
  AiService(
      {required final NetworkInteraction networkInteraction,
      required final LocalInteraction localInteraction}) {
    fileInteraction.putIfAbsent(ModelSourceType.local, () => localInteraction);
    fileInteraction.putIfAbsent(
        ModelSourceType.network, () => networkInteraction);
  }

  factory AiService.defaultInstance() {
    return AiService(
      networkInteraction: NetworkInteraction.defaultInstance(),
      localInteraction: LocalInteraction.defaultInstance(),
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

  Future<bool> addFileToAppDir({required BaseModel baseModel}) async {
    return await fileInteraction[baseModel.sourceType]!
        .copyModelToAppDir(baseModel: baseModel);
  }

  Future<void> deleteFileFromAppDir({required BaseModel baseModel}) async {
    await fileInteraction[baseModel.sourceType]!
        .deleteModalFromAppDir(model: baseModel);
  }
}
