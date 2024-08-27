import 'package:ai_model_land_example/modules/providers/onnx/model_interaction_modules/image_classification/page/onnx_image_classification.dart';
import 'package:ai_model_land_example/routes/routes.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ONNXTestModule extends Module {
  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.child(Routes.providersInteractions.init,
        child: (context) => OnnxImageClassification());
  }
}
