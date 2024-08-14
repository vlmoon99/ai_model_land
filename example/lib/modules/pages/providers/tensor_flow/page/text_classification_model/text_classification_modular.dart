import 'package:ai_model_land_example/modules/pages/providers/tensor_flow/page/text_classification_model/tf_text_classification_page.dart';
import 'package:ai_model_land_example/routes/routes.dart';
import 'package:flutter_modular/flutter_modular.dart';

class TFTextClassificationModular extends Module {
  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.child(Routes.providersInteractions.module,
        child: (context) => TfTextClassificationPage());
  }
}
