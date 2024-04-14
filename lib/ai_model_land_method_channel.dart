import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ai_model_land_platform_interface.dart';

/// An implementation of [AiModelLandPlatform] that uses method channels.
class MethodChannelAiModelLand extends AiModelLandPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ai_model_land');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
