import 'package:ai_model_land_example/modules/providers/transformers/model_interaction_transformers_modules/qwen/page/tr_qwen_page.dart';
import 'package:ai_model_land_example/routes/routes.dart';
import 'package:flutter_modular/flutter_modular.dart';

class TRQwenModule extends Module {
  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.child(Routes.providersInteractions.init,
        child: (context) => TRQwenPage());
  }
}
