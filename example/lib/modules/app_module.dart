import 'package:ai_model_land/ai_model_land_lib.dart';
import 'package:ai_model_land_example/modules/pages/home_page.dart';
import 'package:ai_model_land_example/modules/pages/providers/onnx/onnx_modular.dart';
import 'package:ai_model_land_example/modules/pages/providers/tensor_flow/main_tensorflow_page.dart';
import 'package:ai_model_land_example/modules/pages/providers/tensor_flow/tensor_flow_modular.dart';
import 'package:ai_model_land_example/modules/services/services.dart';
import 'package:ai_model_land_example/routes/routes.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AppModule extends Module {
  @override
  void binds(i) {
    i.add(() => AiModelLandLib.defaultInstance(), key: 'AIModelLib');
    i.addSingleton(() => GlobalVM(), key: 'GlobalVM');
  }

  @override
  void routes(r) {
    r.child(Routes.home.module, child: (context) => HomePage());
    // r.child(Routes.home.getRoute(Routes.home.addModel),
    //     child: (context) => const AddModelPage());
    r.module(Routes.home.module + Routes.providers.tensorFlow,
        module: TensorFlowModular());
    r.module(Routes.home.module + Routes.providers.onnx, module: OnnxModular());
  }
}
