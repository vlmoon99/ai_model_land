import 'package:ai_model_land_example/modules/pages/providers/tensor_flow/main_tensorflow_page.dart';
import 'package:ai_model_land_example/modules/pages/providers/tensor_flow/page/text_classification_model/text_classification_modular.dart';
import 'package:ai_model_land_example/routes/routes.dart';
import 'package:flutter_modular/flutter_modular.dart';

class TensorFlowModular extends Module {
  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.child(Routes.providers.module, child: (context) => MainTensorflowPage());
    r.module(Routes.providersInteractions.textDetection,
        module: TFTextClassificationModular());
  }
}
