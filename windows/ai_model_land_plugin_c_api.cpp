#include "include/ai_model_land/ai_model_land_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "ai_model_land_plugin.h"

void AiModelLandPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  ai_model_land::AiModelLandPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
