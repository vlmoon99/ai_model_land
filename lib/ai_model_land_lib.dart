import 'dart:async';

import 'package:ai_model_land/modules/core/base_model.dart';
import 'package:ai_model_land/modules/core/task_request_model.dart';
import 'package:ai_model_land/modules/core/task_response_model.dart';
import 'package:ai_model_land/repositories/core_repository.dart';
import 'package:ai_model_land/services/ai_service.dart';
import 'package:collection/collection.dart';

class AiModelLandLib {
  // final Repository<BaseModel> baseModelRepository;

  final CoreRepository coreRepository;

  final AiService aiService;

  AiModelLandLib(this.coreRepository, this.aiService) {}

  //factory
  factory AiModelLandLib.defaultInstance() {
    return AiModelLandLib(
      CoreRepository.defaultInstance(),
      AiService.defaultInstance(),
    );
  }

// init future
  Future<BaseModel> addModel({required BaseModel baseModel}) async {
    final isAlreadyExist =
        (await coreRepository.readAll(sourceType: baseModel.sourceType))
                .firstWhereOrNull(
                    (element) => element.source == baseModel.source) !=
            null;
    if (isAlreadyExist) {
      throw Exception("This model is already exist");
    }
    final id = ((await coreRepository.readAll(sourceType: baseModel.sourceType))
                .lastOrNull
                ?.id ??
            -1) +
        1;
    final processedBaseModeld = BaseModel(
        id: id,
        source: baseModel.source,
        nameFile: baseModel.nameFile,
        format: baseModel.format,
        sourceType: baseModel.sourceType);

    final finalModelForAdd =
        await aiService.fileInteraction(baseModel: processedBaseModeld);

    await coreRepository.save(item: finalModelForAdd);
    return finalModelForAdd;
  }
  // service future

  Future<bool> loadModel(
      {required TaskRequestModel request, required BaseModel baseModel}) async {
    return await aiService.loadModelToProvider(
        request: request, baseModel: baseModel);
  }

  Future<void> stopModel({required BaseModel baseModel}) async {
    await aiService.stopModel(baseModel: baseModel);
  }

  Future<TaskResponseModel> runTaskOnTheModel(
      {required TaskRequestModel request, required BaseModel baseModel}) async {
    return await aiService.runTaskOnTheModel(
        request: request, baseModel: baseModel);
  }

  bool isModelLoaded({required BaseModel baseModel}) {
    return aiService.isModelLoaded(baseModel: baseModel);
  }

  Future<void> deleteModel(
      {required BaseModel baseModel, required bool fromDevice}) async {
    await coreRepository.delete(
        id: baseModel.id.toString(), sourceType: baseModel.sourceType);
    if (fromDevice == true) {
      await aiService.deleteModel(baseModel: baseModel);
    }
  }

  Future<Map<String, dynamic>>
      checkPlatformGPUAcceleratorPossibilities() async {
    return await aiService.checkPlatformGPUAcceleratorPossibilities();
  }

  Future<void> restartModel(
      {required BaseModel baseModel, required TaskRequestModel request}) async {
    await aiService.restartModel(baseModel: baseModel, request: request);
  }

  //Repo future

  Future<bool> deleteAllModelsForType(
      {required ModelSourceType sourceType}) async {
    coreRepository.deleteAllModelsForType(sourceType: sourceType);
    return true;
  }

  Future<bool> deleteAllModels() async {
    coreRepository.deleteAllModels();
    return true;
  }

  Future<List<BaseModel>> readAllForType(
      {required ModelSourceType sourceType}) async {
    return await coreRepository.readAll(sourceType: sourceType);
  }

  Future<bool> updateForType({required BaseModel baseModel}) async {
    return await coreRepository.update(item: baseModel);
  }
}
