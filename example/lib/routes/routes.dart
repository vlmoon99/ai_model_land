class Routes {
  static final _Home home = _Home();
}

class _Home extends RouteClass {
  String module = '/home';
  String addModel = '/addModel';
}

abstract class RouteClass {
  String module = '/home';

  String getRoute(String moduleRoute) => module + moduleRoute;

  String getModule() => '$module/';
}
