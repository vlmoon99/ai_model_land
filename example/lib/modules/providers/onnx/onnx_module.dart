import 'package:ai_model_land_example/modules/providers/onnx/model_interaction_modules/image_classification/image_classification_module.dart';
import 'package:ai_model_land_example/modules/providers/onnx/pages/main_onnx_page.dart';
import 'package:ai_model_land_example/routes/routes.dart';
import 'package:flutter_modular/flutter_modular.dart';

class OnnxModule extends Module {
  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.child(Routes.providers.init, child: (context) => MainOnnxPage());
    r.module(Routes.providersInteractions.test, module: ONNXTestModule());
  }
}