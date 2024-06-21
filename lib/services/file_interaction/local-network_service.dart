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
  Future<void> deleteModalFromAppDir({required BaseModel model}) async {
    final appDir = await getApplicationDocumentsDirectory();
    final appPath = appDir.path;
    final fileOnDevice = File('$appPath/${model.nameFile}');
    await fileOnDevice.delete();
  }

  Future<BaseModel> downloadModelToAppDir(
      {required BaseModel baseModel}) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final appPath = appDir.path;
      final isExistModel = File('$appPath/${baseModel.nameFile}');
      if (await isExistModel.exists()) {
        throw Exception('File ${baseModel.nameFile} already exist in App');
      }
      final fileOnDevice = await dio.download(
          baseModel.source, '$appPath/${baseModel.nameFile}');
      print('File download to $appPath/${baseModel.nameFile}');

      return BaseModel(
          id: baseModel.id,
          source: '$appPath/${baseModel.nameFile}',
          nameFile: baseModel.nameFile,
          format: baseModel.format,
          sourceType: baseModel.sourceType);
    } catch (e) {
      throw Exception('Error copying file: $e');
    }
  }
}
