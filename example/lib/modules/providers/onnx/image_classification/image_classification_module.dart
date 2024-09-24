import 'package:ai_model_land_example/modules/providers/onnx/image_classification/page/onnx_image_classification.dart';
import 'package:ai_model_land_example/routes/routes.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ONNXImageClassificationModule extends Module {
  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.child(Routes.providersInteractions.init,
        child: (context) => OnnxImageClassification());
  }
}
