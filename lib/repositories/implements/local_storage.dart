import 'dart:convert';

import 'package:ai_model_land/constanta/storage_keys.dart';
import 'package:ai_model_land/modules/core/base_model.dart';
import 'package:ai_model_land/repositories/i_repository.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorage extends Repository<BaseModel> {
  final FlutterSecureStorage secureStorage;

  LocalStorage({required this.secureStorage});

  factory LocalStorage.defaultInstance() {
    late final FlutterSecureStorage secureStorage;
    if (defaultTargetPlatform == TargetPlatform.android) {
      const androidOptions = AndroidOptions(
        encryptedSharedPreferences: true,
      );
      secureStorage = const FlutterSecureStorage(aOptions: androidOptions);
    } else {
      secureStorage = const FlutterSecureStorage();
    }
    return LocalStorage(
      secureStorage: secureStorage,
    );
  }

  @override
  Future<void> delete(String id) async {
    final modals =
        (jsonDecode(await secureStorage.read(key: StorageKeys.local) ?? '[]')
                as List<dynamic>)
            .map((e) => BaseModel.fromJson(e as Map<String, dynamic>))
            .toList();
    modals.removeWhere((modal) => modal.id.toString() == id);
    await secureStorage.write(
        key: StorageKeys.local, value: jsonEncode(modals));
  }

  @override
  Future<void> deleteAll() async {
    await secureStorage.delete(key: StorageKeys.local);
  }

  @override
  Future<BaseModel> read(String id) async {
    final modals =
        (jsonDecode(await secureStorage.read(key: StorageKeys.local) ?? '[]')
                as List<dynamic>)
            .map((e) => BaseModel.fromJson(e as Map<String, dynamic>))
            .toList()
            .firstWhereOrNull((element) => element.id == id);

    if (modals == null) {
      throw Exception("This Wallet doesn't exist");
    }

    return modals;
  }

  @override
  Future<List<BaseModel>> readAll() async {
    // Чтение данных из хранилища
    final modals =
        (jsonDecode(await secureStorage.read(key: StorageKeys.local) ?? '[]')
                as List<dynamic>)
            .map((e) => BaseModel.fromJson(e as Map<String, dynamic>))
            .toList();
    if (modals == null || modals.isEmpty) {
      return [];
    }
    return modals;
  }

  @override
  Future<void> save(BaseModel item) async {
    final modals =
        (jsonDecode(await secureStorage.read(key: StorageKeys.local) ?? '[]')
                as List<dynamic>)
            .map((e) => BaseModel.fromJson(e as Map<String, dynamic>))
            .toList();
    modals.add(item);
    await secureStorage.write(
        key: StorageKeys.local, value: jsonEncode(modals));
  }

  @override
  Future<void> saveAll(List<BaseModel> items) async {
    await secureStorage.write(key: StorageKeys.local, value: jsonEncode(items));
  }

  @override
  Future<void> update(BaseModel item) async {
    final modals =
        (jsonDecode(await secureStorage.read(key: StorageKeys.local) ?? '[]')
                as List<dynamic>)
            .map((e) => BaseModel.fromJson(e as Map<String, dynamic>))
            .toList();
    modals.removeWhere((modal) => modal.id == item.id);
    modals.add(item);
    await secureStorage.write(
        key: StorageKeys.local, value: jsonEncode(modals));
  }
}
