import 'dart:io';

import 'package:ai_model_land/modules/core/base_model.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class NetworkService {
  final Dio dio;

  NetworkService({required this.dio});

  factory NetworkService.defaultInstance() {
    return NetworkService(dio: Dio());
  }
  Future<void> deleteModel({required BaseModel model}) async {
    final fileOnDevice = File('${model.source}');
    await fileOnDevice.delete();
  }

  Future<BaseModel> downloadModelToAppDir(
      {required BaseModel baseModel}) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final appPath = appDir.path;
      final fullNameModel = '${baseModel.nameFile}.${baseModel.format}';
      final isExistModel = File('$appPath/$fullNameModel');
      if (await isExistModel.exists()) {
        throw Exception('File $fullNameModel already exist in App');
      }
      final fileOnDevice =
          await dio.download(baseModel.source, '$appPath/$fullNameModel');
      print('File download to $appPath/$fullNameModel');

      return BaseModel(
          id: baseModel.id,
          source: '$appPath/$fullNameModel',
          nameFile: baseModel.nameFile,
          format: baseModel.format,
          sourceType: baseModel.sourceType);
    } catch (e) {
      throw Exception('Error copying file: $e');
    }
  }
}
