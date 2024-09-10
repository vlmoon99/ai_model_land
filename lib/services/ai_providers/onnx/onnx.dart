import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:ai_model_land/models/core/base_model.dart';
import 'package:ai_model_land/models/core/task_request_model.dart';
import 'package:ai_model_land/models/core/task_response_model.dart';
import 'package:ai_model_land/models/providers/onnx/onnx_request_model.dart';
import 'package:ai_model_land/services/js_engines/interface/js_vm.dart';
import 'package:ai_model_land/services/provider_ai_service.dart';
import 'package:ai_model_land/services/js_engines/interface/js_engine_stub.dart'
    if (dart.library.io) 'package:ai_model_land/services/js_engines/implementation/webview_js_engine.dart'
    if (dart.library.js) 'package:ai_model_land/services/js_engines/implementation/web_js_engine.dart';
import 'package:flutter/services.dart';

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
      {required TaskRequestModel request, required BaseModel baseModel}) async {
    try {
      final onnxRequest = request as OnnxRequestModel;
      if (onnxRequest.loadModelWay != null) {
        switch (onnxRequest.loadModelWay) {
          case LoadModelWay.fromFile:
            {
              final file = File(baseModel.source);
              if (await file.exists()) {
                return await loadModelCreateSession(
                    modelBuffer: file.readAsBytesSync());
              } else {
                throw Exception("File not exist");
              }
            }
          case LoadModelWay.fromAssets:
            {
              var byteData = await rootBundle.load(baseModel.source);
              Uint8List modelBuffer = byteData.buffer.asUint8List();
              return await loadModelCreateSession(modelBuffer: modelBuffer);
            }
          case LoadModelWay.fromBuffer:
            {
              if (onnxRequest.uint8list != null) {
                return await loadModelCreateSession(
                    modelBuffer: onnxRequest.uint8list);
              } else {
                throw Exception("Buffer not found");
              }
            }
          default:
            {
              throw Exception(
                  "${onnxRequest.loadModelWay!.name} not support for this provider");
            }
        }
      } else {
        throw Exception("Load model way absent");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  Future<bool> loadModelCreateSession({required modelBuffer}) async {
    final isLoad = await loadOnWeb(
        byts: modelBuffer, callfunction: "window.onnx.receiveChunk");
    if (isLoad == true) {
      final session =
          await jsVMService.callJSAsync("window.onnx.createSessionBuffer()");
      final res = await jsonDecode(session);
      return true;
    } else {
      throw Exception("Model not load on web");
    }
  }

  Future<bool> loadOnWeb(
      {required Uint8List byts, required String callfunction}) async {
    int chunkSize = byts.length ~/ 50; // 1MB chunks
    int offset = 0;

    while (offset < byts.length) {
      int end =
          (offset + chunkSize < byts.length) ? offset + chunkSize : byts.length;
      Uint8List chunk = byts.sublist(offset, end);
      final res =
          await jsVMService.callJS(callfunction + "(${chunk.toString()})");
      offset += chunkSize;
    }
    return true;
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
    try {
      final res = await jsVMService.callJS("window.onnx.test()");
      print(res);
      final data = jsonDecode(res);
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
