import 'package:ai_model_land/ai_model_land_lib.dart';
import 'package:ai_model_land/models/core/base_model.dart';
import 'package:ai_model_land/models/core/task_request_model.dart';
import 'package:ai_model_land/models/core/task_response_model.dart';
import 'package:ai_model_land/services/ai_providers/onnx/onnx.dart';
import 'package:flutter_modular/flutter_modular.dart';

class GlobalVM {
  GlobalVM();

  //factory
  factory GlobalVM.defaultInstance() {
    return GlobalVM();
  }

  final AiModelLandLib _aiModelLand = Modular.get(key: 'AIModelLib');

  Future<Map<String, dynamic>> checkPlatformInfo() async {
    return await _aiModelLand.checkPlatformInfo();
  }

  Future<List<BaseModel>> readAll() async {
    return await _aiModelLand.readAll();
  }

  Future<BaseModel> addModel({required BaseModel baseModel}) {
    return _aiModelLand.addModel(baseModel: baseModel);
  }

  Future<bool> loadModel(
      {required TaskRequestModel request, required BaseModel baseModel}) async {
    return await _aiModelLand.loadModel(request: request, baseModel: baseModel);
  }

  Future<bool> deleteModelFromDevice(
      {required BaseModel baseModel, required bool fromDevice}) async {
    return await _aiModelLand.deleteModelFromDevice(baseModel: baseModel);
  }

  Future<bool> stopModel({required BaseModel baseModel}) async {
    return await _aiModelLand.stopModel(baseModel: baseModel);
  }

  Future<bool> isModelLoaded({required BaseModel baseModel}) async {
    return await _aiModelLand.isModelLoaded(baseModel: baseModel);
  }

  Future<TaskResponseModel> runTaskOnTheModel(
      {required TaskRequestModel request, required BaseModel baseModel}) async {
    return await _aiModelLand.runTaskOnTheModel(
        request: request, baseModel: baseModel);
  }

  Future<bool> restartModel(
      {required TaskRequestModel request, required BaseModel baseModel}) async {
    return await _aiModelLand.restartModel(
        baseModel: baseModel, request: request);
  }

  Future<Map<String, bool>> webBackendSupport() async {
    ONNX onnx =
        _aiModelLand.aiService.providerService[ModelFormat.onnx] as ONNX;
    final res = await onnx.checkWebGLAndWebGPU();
    return res;
  }
}
