import 'package:ai_model_land/modules/core/models/base_model.dart';
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

  Future<BaseModel> addModel({required BaseModel baseModel}) async {
    final isAlreadyExist =
        (await coreRepository.readAll(sourceType: baseModel.sourceType))
                .firstWhereOrNull((element) => element.id == baseModel.id) !=
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

    coreRepository.save(item: finalModelForAdd);
    return finalModelForAdd;
  }

  Future deleteModel({required BaseModel baseModel}) async {
    await aiService.deleteFileFromAppDir(baseModel: baseModel);
  }

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
