import 'dart:io';

import 'package:ai_model_land/modules/core/models/base_model.dart';
import 'package:ai_model_land/services/local-network_file/local-network_service.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class NetworkInteraction extends LocalNetworkService {
  final Dio dio;

  NetworkInteraction({required this.dio});

  factory NetworkInteraction.defaultInstance() {
    return NetworkInteraction(dio: Dio());
  }
  @override
  Future<bool> copyModelToAppDir({required BaseModel baseModel}) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final appPath = appDir.path;
      final isExistModel = File('$appPath/${baseModel.nameFile}');
      if (await isExistModel.exists()) {
        throw Exception('File ${baseModel.nameFile} already exist in App');
      }
      final fileOnDevice =
          dio.download(baseModel.source, '$appPath/${baseModel.nameFile}');
      print('File download to $appPath/${baseModel.nameFile}');
      return true;
    } catch (e) {
      throw Exception('Error copying file: $e');
    }
  }
}
