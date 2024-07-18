import 'package:ai_model_land/ai_model_land_lib.dart';
import 'package:ai_model_land_example/modules/pages/core/add_model_page.dart';
import 'package:ai_model_land_example/modules/pages/core/home_page.dart';
import 'package:ai_model_land_example/modules/services/services.dart';
import 'package:ai_model_land_example/routes/routes.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:dio/dio.dart';

class AppModule extends Module {
  @override
  void binds(i) {
    i.add(() => AiModelLandLib.defaultInstance(), key: 'AIModelLib');
    i.addSingleton(() => GlobalVM(), key: 'GlobalVM');
  }

  @override
  void routes(r) {
    r.child(Routes.home.module, child: (context) => HomePage());
    r.child(Routes.home.getRoute(Routes.home.addModel),
        child: (context) => const AddModelPage());
  }
}
