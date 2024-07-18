import 'package:ai_model_land/ai_model_land_lib.dart';
import 'package:ai_model_land/modules/core/base_model.dart';
import 'package:ai_model_land/modules/providers/tensor_flow/tensorflow_request_model.dart';
import 'package:flutter_modular/flutter_modular.dart';

class GlobalVM {
  GlobalVM();

  //factory
  factory GlobalVM.defaultInstance() {
    return GlobalVM();
  }

  final AiModelLandLib _aiModelLand = Modular.get(key: 'AIModelLib');

  Future<Map<String, dynamic>>
      checkPlatformGPUAcceleratorPossibilities() async {
    return await _aiModelLand.checkPlatformGPUAcceleratorPossibilities();
  }

  Future<List<BaseModel>> readAll() async {
    return await _aiModelLand.readAll();
  }

  Future<BaseModel> addModel({required BaseModel baseModel}) {
    return _aiModelLand.addModel(baseModel: baseModel);
  }

  Future<bool> loadModel(
      {required TensorFlowRequestModel request,
      required BaseModel baseModel}) async {
    return await _aiModelLand.loadModel(
        request: TensorFlowRequestModel(loadModelWay: LoadModelWay.fromFile),
        baseModel: baseModel);
  }

  Future<void> deleteModel(
      {required BaseModel baseModel, required bool fromDevice}) async {
    await _aiModelLand.deleteModel(
        baseModel: baseModel, fromDevice: fromDevice);
  }

  Future<void> stopModel({required BaseModel baseModel}) async {
    await _aiModelLand.stopModel(baseModel: baseModel);
  }

  Future<void> runTaskOnTheModel(
      {required TensorFlowRequestModel request,
      required BaseModel baseModel}) async {
    await _aiModelLand.runTaskOnTheModel(
        request: request, baseModel: baseModel);
  }

  Future<void> restartModel(
      {required TensorFlowRequestModel request,
      required BaseModel baseModel}) async {
    await _aiModelLand.restartModel(baseModel: baseModel, request: request);
  }
}
