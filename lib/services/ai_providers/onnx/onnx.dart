import 'dart:convert';

import 'package:ai_model_land/models/core/base_model.dart';
import 'package:ai_model_land/models/core/task_request_model.dart';
import 'package:ai_model_land/models/core/task_response_model.dart';
import 'package:ai_model_land/services/js_engines/interface/js_vm.dart';
import 'package:ai_model_land/services/provider_ai_service.dart';
import 'package:ai_model_land/services/js_engines/interface/js_engine_stub.dart'
    if (dart.library.io) 'package:ai_model_land/services/js_engines/implementation/webview_js_engine.dart'
    if (dart.library.js) 'package:ai_model_land/services/js_engines/implementation/web_js_engine.dart';

class ONNX implements ProviderAiService {
  // OrtSessionOptions? sessionOptions;
  // OrtSession? session;
  JsVMService jsVMService;
  ONNX({required this.jsVMService}) {}

  factory ONNX.defaultInstance() {
    return ONNX(
      jsVMService: getJsVM(),
    );
  }

  @override
  Future<bool> addModel(
      {required TaskRequestModel request, required BaseModel baseModel}) {
    // final onnxRequest = request as OnnxRequestModel;
    // try {
    //   switch (onnxRequest.loadModelWay) {
    //     case LoadModelWay.fromFile:
    //       {
    //         if (onnxRequest.loadModelFilePath == null) {
    //           throw Exception(
    //               "For add model you need indicate full file path to model");
    //         }
    //         sessionOptions = OrtSessionOptions();
    //         File modelFile = File(onnxRequest.loadModelFilePath!);
    //         session = OrtSession.fromFile(modelFile, sessionOptions!);
    //       }
    //     case LoadModelWay.fromBuffer:
    //       {
    //         if (onnxRequest.uint8list == null) {
    //           throw Exception(
    //               "For add model you need indicate convert model in uint8list");
    //         }
    //         // OrtEnv.instance.availableProviders().forEach((element) {
    //         //   print('onnx provider=$element');
    //         // });
    //         // OrtEnv.instance.release();
    //         // OrtEnv.version;
    //         OrtEnv.instance.init();
    //         sessionOptions = OrtSessionOptions()
    //           ..setInterOpNumThreads(1)
    //           ..setIntraOpNumThreads(1)
    //           ..setSessionGraphOptimizationLevel(
    //               GraphOptimizationLevel.ortEnableAll);
    //         session =
    //             OrtSession.fromBuffer(onnxRequest.uint8list!, sessionOptions!);
    //         final runOptions = OrtRunOptions();
    //       }
    //     case LoadModelWay.fromAddress:
    //       {
    //         if (onnxRequest.pointerAddress == null) {
    //           throw Exception(
    //               "For add model you need indicate pointer address");
    //         }
    //         session = OrtSession.fromAddress(onnxRequest.pointerAddress!);
    //       }
    //     default:
    //       throw Exception("This load model way doesn`t exist");
    //   }
    // } catch (e) {
    //   throw Exception("Model not add: $e");
    // }
    // return Future.value(true);
    throw UnimplementedError("No finish");
  }

  @override
  void checkPlatformGPUAcceleratorPossibilities(String params) {
    // TODO: implement checkPlatformGPUAcceleratorPossibilities
  }

  @override
  Future deleteModel() {
    // TODO: implement deleteModel
    throw UnimplementedError();
  }

  @override
  bool isModelLoaded() {
    // TODO: implement isModelLoaded
    throw UnimplementedError();
  }

  @override
  Future restartModel(
      {required TaskRequestModel request, required BaseModel baseModel}) {
    // TODO: implement restartModel
    throw UnimplementedError();
  }

  @override
  Future<TaskResponseModel> runTaskOnTheModel(TaskRequestModel request) {
    // TODO: implement runTaskOnTheModel
    throw UnimplementedError();
  }

  @override
  Future stopModel() {
    // TODO: implement stopModel
    throw UnimplementedError();
  }

  Future test() async {
    final res = await jsVMService.callJS("""await window.onnx.test()""");
    final data = jsonDecode(res);
  }
}
