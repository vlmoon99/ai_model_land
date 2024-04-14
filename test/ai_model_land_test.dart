import 'package:flutter_test/flutter_test.dart';
import 'package:ai_model_land/ai_model_land.dart';
import 'package:ai_model_land/ai_model_land_platform_interface.dart';
import 'package:ai_model_land/ai_model_land_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAiModelLandPlatform
    with MockPlatformInterfaceMixin
    implements AiModelLandPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AiModelLandPlatform initialPlatform = AiModelLandPlatform.instance;

  test('$MethodChannelAiModelLand is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAiModelLand>());
  });

  test('getPlatformVersion', () async {
    AiModelLand aiModelLandPlugin = AiModelLand();
    MockAiModelLandPlatform fakePlatform = MockAiModelLandPlatform();
    AiModelLandPlatform.instance = fakePlatform;

    expect(await aiModelLandPlugin.getPlatformVersion(), '42');
  });
}
