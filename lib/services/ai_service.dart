import 'dart:async';

import 'package:ai_model_land/models/core/base_model.dart';
import 'package:ai_model_land/models/core/task_request_model.dart';
import 'package:ai_model_land/models/core/task_response_model.dart';
import 'package:ai_model_land/services/ai_providers/tensor_flow/tensorFlowLite.dart';
import 'package:ai_model_land/services/file_interaction/local-network_service.dart';
import 'package:ai_model_land/services/platform_info.dart';
import 'package:ai_model_land/services/provider_ai_service.dart';

class AiService {
  final NetworkService networkInteraction;

  final PlatformInfo platformInfo;

  final Map<ModelFormat, ProviderAiService> providerService = {};

  AiService(
      {required this.networkInteraction,
      required final TensorFlowLite tensorFlowProviderService,
      required this.platformInfo}) {
    providerService.putIfAbsent(
        ModelFormat.tflite, () => tensorFlowProviderService);
  }

  factory AiService.defaultInstance() {
    return AiService(
      platformInfo: PlatformInfo.defaultInstance(),
      networkInteraction: NetworkService.defaultInstance(),
      tensorFlowProviderService: TensorFlowLite.defaultInstance(),
    );
  }
  //Base function from where you can run models in you project, you will need to pass the params
  //We will need to choose type of the source (which type of this model it is, tensorfolw js , pytorch, transofrmer js, tf lite , etc)
  //Also we need to choose the source (Network,Assets) and the path
  Future<TaskResponseModel> runTaskOnTheModel(
      {required TaskRequestModel request, required BaseModel baseModel}) async {
    if (providerService[baseModel.format] == null) {
      throw Exception('Incorrect Provider');
    }

    return await providerService[baseModel.format]!.runTaskOnTheModel(request);
  }

  //Check what platform we have, which optionals for AI models we have (GPU,TPU,CPU, etc)
  Future<Map<String, dynamic>>
      checkPlatformGPUAcceleratorPossibilities() async {
    return await platformInfo.checkPlatformGPUAcceleratorPossibilities();
  }

  Future<bool> loadModelToProvider(
      {required TaskRequestModel request, required BaseModel baseModel}) async {
    if (providerService[baseModel.format] == null) {
      throw Exception('Incorrect Provider');
    }

    return await providerService[baseModel.format]!
        .addModel(request: request, baseModel: baseModel);
  }

  Future<void> stopModel({required BaseModel baseModel}) async {
    if (providerService[baseModel.format] == null) {
      throw Exception('Incorrect Provider');
    }

    if (baseModel.format == null) {
      throw Exception('Incorrect Base Model');
    }
    await providerService[baseModel.format]!.stopModel();
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

  Future<void> restartModel(
      {required BaseModel baseModel, required TaskRequestModel request}) async {
    if (providerService[baseModel.format] == null) {
      throw Exception('Incorrect Provider');
    }
    await providerService[baseModel.format]!
        .restartModel(request: request, baseModel: baseModel);
  }

  bool isModelLoaded({required BaseModel baseModel}) {
    return providerService[baseModel.format]!.isModelLoaded();
  }
}
