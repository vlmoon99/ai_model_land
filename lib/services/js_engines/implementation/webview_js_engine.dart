import 'dart:async';

import 'package:ai_model_land/consts/webview_constants.dart';
import 'package:ai_model_land/services/js_engines/interface/js_vm.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

JsVMService getJsVM() {
  return WebviewJsVMService();
}

class WebviewJsVMService implements JsVMService {
  late HeadlessInAppWebView _headlessWebView;
  late InAppWebViewController _webViewMobileController;
  final _readyCompleter = Completer<void>();

  WebviewJsVMService() {
    init();
  }

  @override
  Future<void> init() async {
    _headlessWebView = HeadlessInAppWebView(
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        domStorageEnabled: true,
        allowFileAccess: true,
        allowContentAccess: true,
        allowUniversalAccessFromFileURLs: true,
        cacheMode: CacheMode.LOAD_NO_CACHE,

        limitsNavigationsToAppBoundDomains: true,

        databaseEnabled: true,
        mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
      ),
      initialUrlRequest: URLRequest(
        url: WebUri(
          WebViewConstants.hiddenWebviewUrl,
        ),
      ),
      onWebViewCreated: (controller) async {
        await controller.setSettings(
          settings: InAppWebViewSettings(),
        );
        _webViewMobileController = controller;
      },
      onConsoleMessage: (controller, consoleMessage) {

        if (consoleMessage.message == 'ONNX initialized' ||
            consoleMessage.message == 'Transformers.js initialized') {

          _readyCompleter.complete();
        }
      },
      onLoadStart: (controller, url) async {},
      onLoadStop: (controller, url) async {},
    );
    await _headlessWebView.run();
  }

  @override
  Future<dynamic> callJS(String function) async {
    await _readyCompleter.future;
    return _webViewMobileController.evaluateJavascript(source: function);
  }

  @override
  Future<dynamic> callJSAsync(String function) async {
    await _readyCompleter.future;
    final String functionBody = """
     var output = $function;
      await output;
      return output;
    """;
    final res = await _webViewMobileController.callAsyncJavaScript(
      functionBody: functionBody,
      arguments: {},
    );
    print(res);
    return Future.value(res?.value);
  }
}
