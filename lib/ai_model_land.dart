
import 'ai_model_land_platform_interface.dart';

class AiModelLand {
  Future<String?> getPlatformVersion() {
    return AiModelLandPlatform.instance.getPlatformVersion();
  }
}
