import 'package:ai_model_land/modules/core/base_model.dart';
import 'package:ai_model_land/modules/core/task_request_model.dart';
import 'package:ai_model_land/modules/core/task_response_model.dart';
import 'package:ai_model_land/services/ai_provaiders/tensor_flow/tensorFlowLite.dart';
import 'package:ai_model_land/services/file_interaction/local-network_service.dart';
import 'package:ai_model_land/services/provider_ai_service.dart';

class AiService {
  final NetworkService networkInteraction;

  final Map<ModelFormat, ProviderAiService> provaiderService = {};

  AiService(
      {required this.networkInteraction,
      required final TensorFlowLite tensorFlowProviderService}) {
    provaiderService.putIfAbsent(
        ModelFormat.tflite, () => tensorFlowProviderService);
  }

  factory AiService.defaultInstance() {
    return AiService(
      networkInteraction: NetworkService.defaultInstance(),
      tensorFlowProviderService: TensorFlowLite.defaultInstance(),
    );
  }
  //Base function from where you can run models in you project, you will need to pass the params
  //We will need to choose type of the source (which type of this model it is, tensorfolw js , pytorch, transofrmer js, tf lite , etc)
  //Also we need to choose the source (Network,Assets) and the path
  Future<TaskResponseModel> runTaskOnTheModel(
      {required TaskRequestModel request, required BaseModel baseModel}) async {
    if (provaiderService[baseModel.format] == null) {
      throw Exception('Incorrect Provider');
    }

    return await provaiderService[baseModel.format]!.runTaskOnTheModel(request);
  }

  //Check what platform we have, which optionals for AI models we have (GPU,TPU,CPU, etc)
  void checkPlatformGPUAcceleratorPossibilities(String params) {}

  Future<bool> loadModelToProvider(
      {required TaskRequestModel request, required BaseModel baseModel}) async {
    if (provaiderService[baseModel.format] == null) {
      throw Exception('Incorrect Provider');
    }

    return await provaiderService[baseModel.format]!
        .addModel(request: request, baseModel: baseModel);
  }

  Future<void> stopModel({required BaseModel baseModel}) async {
    if (provaiderService[baseModel.format] == null) {
      throw Exception('Incorrect Provider');
    }

    if (baseModel.format == null) {
      throw Exception('Incorrect Base Model');
    }
    await provaiderService[baseModel.format]!.stopModel();
  }

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

  Future<void> deleteModel({required BaseModel baseModel}) async {
    await networkInteraction.deleteModel(model: baseModel);
  }

  bool isModelLoaded({required BaseModel baseModel}) {
    return provaiderService[baseModel.format]!.isModelLoaded();
  }
}
