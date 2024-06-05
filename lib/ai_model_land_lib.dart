import 'package:ai_model_land/modules/core/models/base_model.dart';
import 'package:ai_model_land/repositories/i_repository.dart';
import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';

class AiModelLandLib {
  final BehaviorSubject<List<BaseModel>> modelStream =
      BehaviorSubject<List<BaseModel>>();

  final Repository<BaseModel> baseModelRepository;

  AiModelLandLib(this.baseModelRepository) {
    initAILib();
  }

  //factory

  Future<bool> initAILib() async {
    await baseModelRepository.readAll().then((baseModels) {
      modelStream.add(baseModels);
    });
    return true;
  }

  Future addModel({required BaseModel baseModel}) async {
    final isAlreadyExist = (await baseModelRepository.readAll())
            .firstWhereOrNull((element) => element.id == baseModel.id) !=
        null;
    if (isAlreadyExist) {
      throw Exception("This model is already exist");
    }
    final id = ((await baseModelRepository.readAll()).lastOrNull?.id ?? -1) + 1;
    final baseModeld = BaseModel(
        id: id,
        source: baseModel.source,
        format: baseModel.format,
        sourceType: baseModel.sourceType);

    modelStream.value.add(baseModeld);
    modelStream.add(modelStream.value);
    baseModelRepository.saveAll(modelStream.value);
    return baseModeld;
  }
}
