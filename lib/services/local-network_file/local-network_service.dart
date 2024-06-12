import 'dart:io';

import 'package:ai_model_land/modules/core/models/base_model.dart';
import 'package:path_provider/path_provider.dart';

abstract class LocalNetworkService {
  Future<void> deleteModalFromAppDir({required BaseModel model}) async {
    final appDir = await getApplicationDocumentsDirectory();
    final appPath = appDir.path;
    final fileOnDevice = File('$appPath/${model.nameFile}');
    await fileOnDevice.delete();
  }

  Future<bool> copyModelToAppDir({required BaseModel baseModel});
}
