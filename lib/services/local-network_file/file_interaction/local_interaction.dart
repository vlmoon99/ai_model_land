import 'dart:io';

import 'package:ai_model_land/modules/core/models/base_model.dart';
import 'package:ai_model_land/services/local-network_file/local-network_service.dart';
import 'package:path_provider/path_provider.dart';

class LocalInteraction extends LocalNetworkService {
  LocalInteraction();

  factory LocalInteraction.defaultInstance() {
    return LocalInteraction();
  }
  @override
  Future<bool> copyModelToAppDir({required BaseModel baseModel}) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final appPath = appDir.path;
      final fileOnDevice = File('$appPath/${baseModel.nameFile}');

      if (await fileOnDevice.exists()) {
        print('File already exists at $appPath/${baseModel.nameFile}');
        return false;
      }

      final sourceFile = File(baseModel.source);
      final rawBytes = await sourceFile.readAsBytes();

      await fileOnDevice.writeAsBytes(rawBytes, flush: true);
      print('File copied to $appPath/${baseModel.nameFile}');
      return true;
    } catch (e) {
      throw Exception('Error copying file: $e');
    }
  }
}
