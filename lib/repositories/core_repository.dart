import 'package:ai_model_land/modules/core/models/base_model.dart';
import 'package:ai_model_land/repositories/i_repository.dart';
import 'package:ai_model_land/repositories/implements/local_storage.dart';
import 'package:ai_model_land/repositories/implements/network_storage.dart';
import 'package:flutter/foundation.dart';

class CoreRepository {
  final Map<ModelSourceType, Repository<BaseModel>> modalRepositories = {};

  CoreRepository(
      {required final LocalStorage localStorage,
      required final NetworkStorage networkStorage}) {
    modalRepositories.putIfAbsent(ModelSourceType.local, () => localStorage);
    modalRepositories.putIfAbsent(
        ModelSourceType.network, () => networkStorage);
  }

  factory CoreRepository.defaultInstance() {
    return CoreRepository(
      localStorage: LocalStorage.defaultInstance(),
      networkStorage: NetworkStorage.defaultInstance(),
    );
  }
}
