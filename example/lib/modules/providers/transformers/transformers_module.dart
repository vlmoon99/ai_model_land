import 'package:ai_model_land_example/modules/providers/transformers/model_interaction_transformers_modules/llm/llm_module.dart';
import 'package:ai_model_land_example/modules/providers/transformers/model_interaction_transformers_modules/phi/phi_module.dart';
import 'package:ai_model_land_example/modules/providers/transformers/model_interaction_transformers_modules/qwen/qwen_module.dart';
import 'package:ai_model_land_example/modules/providers/transformers/page/main_transformers_page.dart';
import 'package:ai_model_land_example/routes/routes.dart';
import 'package:flutter_modular/flutter_modular.dart';

class TransformersModule extends Module {
  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.child(Routes.providers.init, child: (context) => MainTransformersPage());
    r.module(Routes.providersInteractions.llm, module: TRLLMModule());
    r.module(Routes.providersInteractions.qwen, module: TRQwenModule());
    r.module(Routes.providersInteractions.phi, module: TRPhiModule());
  }
}
