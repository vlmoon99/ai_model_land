class Routes {
  static final _Home home = _Home();
  static final _Providers providers = _Providers();
  static final _ProvidersInteractions providersInteractions =
      _ProvidersInteractions();
}

class _Home extends RouteClass {
  String module = '/home';
  String page = "/";
  // String addModel = '/addModel';
}

class _Providers extends RouteClass {
  String init = '/';
  String tensorFlow = '/tensorFlow';
  String onnx = '/onnx';
}

class _ProvidersInteractions extends RouteClass {
  String init = '/';
  String textClassification = '/text-detection';
  String photoDetectionClassification = "/photo-detection-classification";
  String videoObjectDetection = "/video-object-detection";
}

abstract class RouteClass {
  String module = '/home';

  String getRoute(String moduleRoute) => module + moduleRoute;

  String getModule() => '$module/';
}
