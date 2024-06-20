import 'package:ai_model_land/ai_model_land_lib.dart';

class AiModelProvider {
  AiModelLandLib _aiModelLand;

  AiModelProvider._internal() : _aiModelLand = AiModelLandLib.defaultInstance();

  static final AiModelProvider _instance = AiModelProvider._internal();

  factory AiModelProvider() {
    return _instance;
  }

  AiModelLandLib get aiModelLand => _aiModelLand;
}
