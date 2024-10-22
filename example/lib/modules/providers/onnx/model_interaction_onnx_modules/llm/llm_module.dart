import 'package:ai_model_land_example/modules/providers/onnx/model_interaction_onnx_modules/llm/pages/llm_page.dart';
import 'package:ai_model_land_example/routes/routes.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ONNXLLMModule extends Module {
  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.child(Routes.providersInteractions.init, child: (context) => LLMPage());
  }
}
