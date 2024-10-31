import 'package:ai_model_land/services/ai_providers/onnx/onnx.dart';
import 'package:ai_model_land_example/modules/providers/onnx/model_interaction_tensorflow_modules/age_classification/page/age_classification_page.dart';
import 'package:ai_model_land_example/routes/routes.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ONNXAgeClassificationModule extends Module {
  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.child(Routes.providersInteractions.init,
        child: (context) => AgeClassificationPage());
  }
}
