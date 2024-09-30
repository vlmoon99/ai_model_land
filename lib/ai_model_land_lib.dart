import 'dart:async';

import 'package:ai_model_land/models/core/base_model.dart';
import 'package:ai_model_land/models/core/task_request_model.dart';
import 'package:ai_model_land/models/core/task_response_model.dart';
import 'package:ai_model_land/repositories/i_repository.dart';
import 'package:ai_model_land/repositories/implements/global_storage.dart';
import 'package:ai_model_land/services/ai_service.dart';
import 'package:collection/collection.dart';

class AiModelLandLib {
  // final Repository<BaseModel> baseModelRepository;

  final Repository<BaseModel> coreRepository;

  final AiService aiService;

  AiModelLandLib(this.coreRepository, this.aiService) {}

  //factory
  factory AiModelLandLib.defaultInstance() {
    return AiModelLandLib(
      GlobalStorage.defaultInstance(),
      AiService.defaultInstance(),
    );
  }

// init future
  Future<BaseModel> addModel({required BaseModel baseModel}) async {
    final isAlreadyExist = (await coreRepository.readAll()).firstWhereOrNull(
            (element) => element.source == baseModel.source) !=
        null;
    if (isAlreadyExist) {
      throw Exception("This model is already exist");
    }
    final id = ((await coreRepository.readAll()).lastOrNull?.id ?? -1) + 1;
    final processedBaseModeld = BaseModel(
        id: id,
        source: baseModel.source,
        nameFile: baseModel.nameFile,
        format: baseModel.format,
        sourceType: baseModel.sourceType);

    final finalModelForAdd =
        await aiService.fileInteraction(baseModel: processedBaseModeld);

    await coreRepository.save(finalModelForAdd);
    return finalModelForAdd;
  }
  // service future

  Future<bool> loadModel(
      {required TaskRequestModel request, required BaseModel baseModel}) async {
    return await aiService.loadModelToProvider(
        request: request, baseModel: baseModel);
  }

  Future<bool> stopModel({required BaseModel baseModel}) async {
    return await aiService.stopModel(baseModel: baseModel);
  }

  Future<TaskResponseModel> runTaskOnTheModel(
      {required TaskRequestModel request, required BaseModel baseModel}) async {
    return await aiService.runTaskOnTheModel(
        request: request, baseModel: baseModel);
  }

  Future<bool> isModelLoaded({required BaseModel baseModel}) async {
    return await aiService.isModelLoaded(baseModel: baseModel);
  }

  Future<bool> deleteModelFromDevice({required BaseModel baseModel}) async {
    if (baseModel.id != null) {
      await coreRepository.delete(baseModel.id.toString());
    }
    return await aiService.deleteModel(baseModel: baseModel);
  }

  Future<Map<String, dynamic>> checkPlatformInfo() async {
    return await aiService.checkPlatformInfo();
  }

  Future<bool> restartModel(
      {required BaseModel baseModel, required TaskRequestModel request}) async {
    return await aiService.restartModel(baseModel: baseModel, request: request);
  }

  //Repo future

  Future<bool> deleteAllModels({required ModelSourceType sourceType}) async {
    coreRepository.deleteAll();
    return true;
  }

  Future<List<BaseModel>> readAll() async {
    return await coreRepository.readAll();
  }

  Future<void> updateForType({required BaseModel baseModel}) async {
    return await coreRepository.update(baseModel);
  }
}
