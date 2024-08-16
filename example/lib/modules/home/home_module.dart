import 'package:ai_model_land/ai_model_land_lib.dart';
import 'package:ai_model_land_example/modules/home/page/home_page.dart';
import 'package:ai_model_land_example/modules/providers/onnx/onnx_module.dart';
import 'package:ai_model_land_example/modules/providers/tensor_flow/tensor_flow_module.dart';
import 'package:ai_model_land_example/routes/routes.dart';
import 'package:ai_model_land_example/services/services.dart';
import 'package:ai_model_land_example/utils/utils.dart';
import 'package:flutter_modular/flutter_modular.dart';

class HomeModule extends Module {
  @override
  void binds(i) {
    i.add(() => AiModelLandLib.defaultInstance(), key: 'AIModelLib');
    i.addSingleton(() => GlobalVM(), key: 'GlobalVM');
    i.addSingleton<UtilsClass>(() => UtilsClass());
  }

  @override
  void routes(r) {
    r.child(Routes.home.page, child: (context) => HomePage());
    // r.child(Routes.home.getRoute(Routes.home.addModel),
    //     child: (context) => const AddModelPage());
    r.module(Routes.providers.tensorFlow, module: TensorFlowModule());
    r.module(Routes.providers.onnx, module: OnnxModule());
  }
}
