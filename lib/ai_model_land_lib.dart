import 'package:ai_model_land/modules/core/models/base_model.dart';
import 'package:ai_model_land/repositories/core_repository.dart';
import 'package:ai_model_land/repositories/i_repository.dart';
import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';

class AiModelLandLib {
  final BehaviorSubject<List<BaseModel>> modelStream =
      BehaviorSubject<List<BaseModel>>();

  // final Repository<BaseModel> baseModelRepository;

  final CoreRepository coreRepository;

  AiModelLandLib(this.coreRepository) {
    // initAILib();
  }

  //factory
  factory AiModelLandLib.defaultInstance() {
    return AiModelLandLib(
      CoreRepository.defaultInstance(),
    );
  }
  // Future<bool> initAILib() async {
  //   await coreRepository.readAll().then((baseModels) {
  //     modelStream.add(baseModels);
  //   });
  //   return true;
  // }

  Future addModel({required BaseModel baseModel}) async {
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
    final baseModeld = BaseModel(
        id: id,
        source: baseModel.source,
        format: baseModel.format,
        sourceType: baseModel.sourceType);

    modelStream.value.add(baseModeld);
    modelStream.add(modelStream.value);
    coreRepository.saveAll(
        items: modelStream.value, sourceType: baseModel.sourceType);
    return baseModeld;
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
}
