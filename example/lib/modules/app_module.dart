import 'package:ai_model_land_example/modules/home/home_module.dart';
import 'package:ai_model_land_example/routes/routes.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AppModule extends Module {
  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.module(Routes.home.getModule(), module: HomeModule());
  }
}
