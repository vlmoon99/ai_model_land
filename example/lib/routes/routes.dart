class Routes {
  static final _Home home = _Home();
  static final _Providers providers = _Providers();
  static final _ProvidersInteractions providersInteractions =
      _ProvidersInteractions();
}

class _Home extends RouteClass {
  String module = '/';
  String page = "/home";
  // String addModel = '/addModel';
}

class _Providers extends RouteClass {
  String init = '/';
  String tensorFlow = '/tensorFlow';
  String onnx = '/onnx';

  String transformers = '/transformers';

}

class _ProvidersInteractions extends RouteClass {
  String init = '/';
  String test = "/test";
  String textClassification = '/text-detection';
  String ageClassification = '/age-classification';

  String llm = '/llm';

  String photoDetectionClassification = "/photo-detection-classification";
  String genderClassification = "/gender-classification";
  String videoObjectDetection = "/video-object-detection";
}

abstract class RouteClass {
  String module = '/';

  String getRoute(String moduleRoute) => module + moduleRoute;

  String getModule() => '$module/';
}
