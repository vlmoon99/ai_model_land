import 'package:ai_model_land_example/modules/providers/onnx/age_classification_modules/age_classification_modules.dart';
import 'package:ai_model_land_example/modules/providers/onnx/gender_classification_modules/gender_classification_modules.dart';
import 'package:ai_model_land_example/modules/providers/onnx/image_classification/image_classification_module.dart';
import 'package:ai_model_land_example/modules/providers/onnx/pages/main_onnx_page.dart';
import 'package:ai_model_land_example/routes/routes.dart';
import 'package:flutter_modular/flutter_modular.dart';

class OnnxModule extends Module {
  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.child(Routes.providers.init, child: (context) => MainOnnxPage());
    r.module(Routes.providersInteractions.photoDetectionClassification,
        module: ONNXImageClassificationModule());
    r.module(Routes.providersInteractions.genderClassification,
        module: ONNXGenderClassificationModule());
    r.module(Routes.providersInteractions.ageClassification,
        module: ONNXAgeClassificationModule());
  }
}
