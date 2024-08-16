import 'package:ai_model_land_example/modules/providers/onnx/pages/main_onnx_page.dart';
import 'package:ai_model_land_example/routes/routes.dart';
import 'package:flutter_modular/flutter_modular.dart';

class OnnxModule extends Module {
  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.child(Routes.providers.module, child: (context) => MainOnnxPage());
    // r.child(Routes.home.getRoute(Routes.home.addModel),
    //     child: (context) => const AddModelPage());
  }
}
