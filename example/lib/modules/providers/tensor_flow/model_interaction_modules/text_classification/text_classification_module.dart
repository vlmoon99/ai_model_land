import 'package:ai_model_land_example/modules/providers/tensor_flow/model_interaction_modules/text_classification/page/tf_text_classification_page.dart';
import 'package:ai_model_land_example/routes/routes.dart';
import 'package:flutter_modular/flutter_modular.dart';

class TFTextClassificationModule extends Module {
  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.child(Routes.providersInteractions.init,
        child: (context) => TfTextClassificationPage());
  }
}
