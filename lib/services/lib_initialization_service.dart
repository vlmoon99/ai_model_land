import 'package:ai_model_land/consts/webview_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

final InAppLocalhostServer? localhostServer = kIsWeb
    ? null
    : InAppLocalhostServer(
        documentRoot: WebViewConstants.documentRoot, port: 8090);


Future<void> initAIModelLandLib() async {
  if (!kIsWeb) {
    await localhostServer?.start();
  }

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
}
