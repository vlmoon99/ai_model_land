import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ai_model_land_method_channel.dart';

abstract class AiModelLandPlatform extends PlatformInterface {
  /// Constructs a AiModelLandPlatform.
  AiModelLandPlatform() : super(token: _token);

  static final Object _token = Object();

  static AiModelLandPlatform _instance = MethodChannelAiModelLand();

  /// The default instance of [AiModelLandPlatform] to use.
  ///
  /// Defaults to [MethodChannelAiModelLand].
  static AiModelLandPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AiModelLandPlatform] when
  /// they register themselves.
  static set instance(AiModelLandPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
