import 'dart:async';
import 'package:ai_model_land_example/modules/app_module.dart';
import 'package:ai_model_land_example/modules/pages/home_page.dart';
import 'package:ai_model_land_example/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_modular/flutter_modular.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    //Catch Errors caught by Flutter
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      //TODO add catcher
    };
    runApp(ModularApp(
      module: AppModule(),
      child: AppWidget(),
    ));
  }, (error, stack) {
    print(error.toString());
    //Catch Errors not caught by Flutter
    //TODO add catcher
  });
}

class AppWidget extends StatelessWidget {
  const AppWidget();

  @override
  Widget build(BuildContext context) {
    Modular.setInitialRoute(Routes.home.module);
    return MaterialApp.router(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      title: 'AI Model Land',
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
    );
  }
}
