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
  List<dynamic>? inputNames;
  List<dynamic>? outputNames;
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
                    modelBuffer: file.readAsBytesSync(),
                    numThreads: onnxRequest.numThreads);
              } else {
                throw Exception("File not exist");
              }
            }
          case LoadModelWay.fromAssets:
            {
              final byteData = await rootBundle.load(baseModel.source);
              Uint8List modelBuffer = byteData.buffer.asUint8List();
              return await loadModelCreateSession(
                  modelBuffer: modelBuffer, numThreads: onnxRequest.numThreads);
            }
          case LoadModelWay.fromBuffer:
            {
              if (onnxRequest.uint8list != null) {
                return await loadModelCreateSession(
                    modelBuffer: onnxRequest.uint8list,
                    numThreads: onnxRequest.numThreads);
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

  Future<bool> loadModelCreateSession(
      {required modelBuffer, int? numThreads}) async {
    //numThreads recommend 1(by default 1)
    final isLoad = await loadOnWeb(
        byts: modelBuffer, callFunction: "window.onnx.receiveChunk");
    if (isLoad == true) {
      final session = await jsVMService
          .callJSAsync("window.onnx.createSessionBuffer($numThreads)");
      Map<String, dynamic> res = await jsonDecode(session);
      if (res.containsKey("error")) {
        throw Exception("Error: ${res["error"]}");
      }
      inputNames = res["inputNames"];
      outputNames = res["outputNames"];
      return true;
    } else {
      throw Exception("Model not load on web");
    }
  }

  Future<bool> loadOnWeb(
      {required Uint8List byts, required String callFunction}) async {
    int chunkSize = byts.length ~/ 50; // 1MB chunks
    int offset = 0;

    while (offset < byts.length) {
      int end =
          (offset + chunkSize < byts.length) ? offset + chunkSize : byts.length;
      Uint8List chunk = byts.sublist(offset, end);
      final res =
          await jsVMService.callJS(callFunction + "(${chunk.toString()})");
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
  Future<bool> isModelLoaded() async {
    final isload = await jsVMService.callJS("window.onnx.isModelLoaded()");
    Map<String, dynamic> res = jsonDecode(isload);
    return res["res"];
  }

  @override
  Future restartModel(
      {required TaskRequestModel request, required BaseModel baseModel}) async {
    try {
      final restartResponse =
          await jsVMService.callJSAsync("window.onnx.restartModel()");
      Map<String, dynamic> res = jsonDecode(restartResponse);

      if (res.containsKey("error")) {
        throw Exception("${res["error"]}");
      }
      log('Model restart successful');
    } catch (e) {
      throw Exception("$e");
    }
  }

  @override
  Future<TaskResponseModel> runTaskOnTheModel(TaskRequestModel request) async {
    final onnxRequest = request as OnnxRequestModel;
    if (inputNames!.length == 0) {
      throw Exception("Input names data can`t be 0");
    }
    if (onnxRequest.dataMulti != null && onnxRequest.shape != null) {
      if (onnxRequest.dataMulti!.length != onnxRequest.shape!.length) {
        throw Exception('Length dataMulti and shape must be the same');
      }

      if (onnxRequest.dataMulti!.length != inputNames!.length) {
        throw Exception("Data length and input names length must be the same");
      }
      try {
        var inputData = [];
        var typeInputdata = [];
        if (onnxRequest.typeInputData == null) {
          for (var inputObject in onnxRequest.dataMulti!) {
            typeInputdata.add(inputObject.runtimeType.toString());
            inputData.add(inputObject);
          }
        } else {
          for (var inputObject in onnxRequest.dataMulti!) {
            inputData.add(inputObject);
          }
          typeInputdata = onnxRequest.typeInputData!;
        }
        final convertTypeInputData = jsonEncode(typeInputdata);
        final convertInputData = jsonEncode(inputData);
        final data = await jsVMService.callJSAsync(
            "window.onnx.runModel('$convertInputData', ${onnxRequest.shape}, '$convertTypeInputData',${onnxRequest.threshold})");
        final dataOutput = await jsonDecode(data);
        Map<String, dynamic> sortedData = {};
        for (var oneOutput in outputNames!) {
          var sortedEntries = dataOutput["output"][oneOutput].entries.toList()
            ..sort((a, b) => (b.value as double).compareTo(a.value as double));
          sortedData.addEntries(sortedEntries);
        }
        log("Model run successful: $sortedData");
      } catch (e) {
        throw Exception("Error: $e");
      }
    } else {
      throw Exception("Input data not load or shape not found");
    }
    throw UnimplementedError();
  }

  @override
  Future stopModel() async {
    try {
      final stopeSession =
          await jsVMService.callJSAsync("window.onnx.stopModel()");
      Map<String, dynamic> res = jsonDecode(stopeSession);
      if (res.containsKey("error")) {
        throw Exception("${res["error"]}");
      }
      log('Model was close successful');
    } catch (e) {
      throw Exception("Model wasn`t stop: $e");
    }
  }

  Future test() async {
    try {
      final res = await jsVMService.callJSAsync("window.onnx.test()");
      print(res);
      final data = jsonDecode(res);
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
