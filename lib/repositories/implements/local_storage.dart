import 'dart:convert';

import 'package:ai_model_land/constanta/storage_keys.dart';
import 'package:ai_model_land/modules/core/models/base_model.dart';
import 'package:ai_model_land/repositories/core_repository.dart';
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
    modals.removeWhere((modal) => modal.id == id);
    secureStorage.write(key: StorageKeys.local, value: jsonEncode(modals));
  }

  @override
  Future<void> deleteAll() async {
    secureStorage.delete(key: StorageKeys.local);
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
    final decodedData =
        (jsonDecode(await secureStorage.read(key: StorageKeys.local) ?? '[]')
            as List<dynamic>);
    return decodedData
        .map((e) => BaseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> save(BaseModel item) async {
    final modals =
        (jsonDecode(await secureStorage.read(key: StorageKeys.local) ?? '[]')
                as List<dynamic>)
            .map((e) => BaseModel.fromJson(e as Map<String, dynamic>))
            .toList();
    modals.add(item);
    secureStorage.write(key: StorageKeys.local, value: jsonEncode(item));
  }

  @override
  Future<void> saveAll(List<BaseModel> items) async {
    secureStorage.write(key: StorageKeys.local, value: jsonEncode(items));
  }

  @override
  Future<void> update(String key, BaseModel item) async {
    final modals =
        (jsonDecode(await secureStorage.read(key: StorageKeys.local) ?? '[]')
                as List<dynamic>)
            .map((e) => BaseModel.fromJson(e as Map<String, dynamic>))
            .toList();
    modals.removeWhere((modal) => modal.id == item.id);
    modals.add(item);
    secureStorage.write(key: StorageKeys.local, value: jsonEncode(item));
  }
}
