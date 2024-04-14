#ifndef FLUTTER_PLUGIN_AI_MODEL_LAND_PLUGIN_H_
#define FLUTTER_PLUGIN_AI_MODEL_LAND_PLUGIN_H_

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __attribute__((visibility("default")))
#else
#define FLUTTER_PLUGIN_EXPORT
#endif

typedef struct _AiModelLandPlugin AiModelLandPlugin;
typedef struct {
  GObjectClass parent_class;
} AiModelLandPluginClass;

FLUTTER_PLUGIN_EXPORT GType ai_model_land_plugin_get_type();

FLUTTER_PLUGIN_EXPORT void ai_model_land_plugin_register_with_registrar(
    FlPluginRegistrar* registrar);

G_END_DECLS

#endif  // FLUTTER_PLUGIN_AI_MODEL_LAND_PLUGIN_H_
