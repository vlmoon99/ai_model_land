import 'dart:async';

import 'package:ai_model_land/models/core/base_model.dart';
import 'package:ai_model_land/models/core/task_request_model.dart';
import 'package:ai_model_land/models/core/task_response_model.dart';
import 'package:ai_model_land/services/ai_providers/onnx/onnx.dart';
import 'package:ai_model_land/services/ai_providers/tensor_flow/tensor_flow_lite_interface.dart';
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
      required final ONNX ONNXProviderService,
      required this.platformInfo}) {
    providerService.putIfAbsent(
        ModelFormat.tflite, () => tensorFlowProviderService);
    providerService.putIfAbsent(ModelFormat.onnx, () => ONNXProviderService);
  }

  factory AiService.defaultInstance() {
    return AiService(
      platformInfo: PlatformInfo.defaultInstance(),
      networkInteraction: NetworkService.defaultInstance(),
      tensorFlowProviderService: TensorFlowLite.defaultInstance(),
      ONNXProviderService: ONNX.defaultInstance(),
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
  Future<Map<String, dynamic>> checkPlatformInfo() async {
    return await platformInfo.checkPlatformInfo();
  }

  Future<bool> loadModelToProvider(
      {required TaskRequestModel request, required BaseModel baseModel}) async {
    if (providerService[baseModel.format] == null) {
      throw Exception('Incorrect Provider');
    }

    return await providerService[baseModel.format]!
        .addModel(request: request, baseModel: baseModel);
  }

  Future<bool> stopModel({required BaseModel baseModel}) async {
    if (providerService[baseModel.format] == null) {
      throw Exception('Incorrect Provider');
    }

    if (baseModel.format == null) {
      throw Exception('Incorrect Base Model');
    }
    return await providerService[baseModel.format]!.stopModel();
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

  Future<bool> deleteModel({required BaseModel baseModel}) async {
    final isdelete = await networkInteraction.deleteModel(model: baseModel);
    return isdelete;
  }

  Future<bool> restartModel(
      {required BaseModel baseModel, required TaskRequestModel request}) async {
    if (providerService[baseModel.format] == null) {
      throw Exception('Incorrect Provider');
    }
    return await providerService[baseModel.format]!
        .restartModel(request: request, baseModel: baseModel);
  }

  Future<bool> isModelLoaded({required BaseModel baseModel}) async {
    return await providerService[baseModel.format]!.isModelLoaded();
  }
}
