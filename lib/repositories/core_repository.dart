import 'package:ai_model_land/modules/core/base_model.dart';
import 'package:ai_model_land/repositories/i_repository.dart';
import 'package:ai_model_land/repositories/implements/local_storage.dart';
import 'package:ai_model_land/repositories/implements/network_storage.dart';
// import 'package:flutter/foundation.dart';

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

  Future<void> save({required BaseModel item}) async {
    await modalRepositories[item.sourceType]?.save(item);
  }

  Future<void> saveAll(
      {required List<BaseModel> items,
      required ModelSourceType sourceType}) async {
    await modalRepositories[sourceType]?.saveAll(items);
  }

  Future<BaseModel> read(
      {required String id, required ModelSourceType sourceType}) async {
    final modal = await modalRepositories[sourceType]?.read(id);
    if (modal == null) {
      throw Exception("This modal not exist");
    }
    return modal;
  }

  Future<List<BaseModel>> readAll({required ModelSourceType sourceType}) async {
    final modals = await modalRepositories[sourceType]?.readAll();
    if (modals == null) {
      throw Exception("This modal not exist");
    }
    return modals;
  }

  Future<bool> update({required BaseModel item}) async {
    await modalRepositories[item.sourceType]?.update(item);
    return true;
  }

  Future<void> delete(
      {required String id, required ModelSourceType sourceType}) async {
    await modalRepositories[sourceType]?.delete(id);
  }

  Future<void> deleteAllModels() async {
    await modalRepositories.values.map((sourceType) => sourceType.deleteAll());
  }

  Future<void> deleteAllModelsForType(
      {required ModelSourceType sourceType}) async {
    await modalRepositories[sourceType]?.deleteAll();
  }
}
