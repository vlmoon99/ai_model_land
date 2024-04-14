#ifndef FLUTTER_PLUGIN_AI_MODEL_LAND_PLUGIN_H_
#define FLUTTER_PLUGIN_AI_MODEL_LAND_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace ai_model_land {

class AiModelLandPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  AiModelLandPlugin();

  virtual ~AiModelLandPlugin();

  // Disallow copy and assign.
  AiModelLandPlugin(const AiModelLandPlugin&) = delete;
  AiModelLandPlugin& operator=(const AiModelLandPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace ai_model_land

#endif  // FLUTTER_PLUGIN_AI_MODEL_LAND_PLUGIN_H_
