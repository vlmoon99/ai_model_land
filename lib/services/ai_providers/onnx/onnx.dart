import 'dart:convert';
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
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../models/providers/onnx/onnx_respons_model.dart';

class ONNX implements ProviderAiService {
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

      if (onnxRequest.onnxBackend == null) {
        throw Exception("ONNX backend not found");
      }

      if (onnxRequest.loadModelWay != null) {
        switch (onnxRequest.loadModelWay) {
          case LoadModelWay.fromFile:
            {
              final file = File(baseModel.source);
              if (await file.exists()) {
                Uint8List modelBuffer = file.readAsBytesSync();
                return await loadModelCreateSession(
                    modelBuffer: modelBuffer,
                    numThreads: onnxRequest.numThreads,
                    onProgressUpdate: onnxRequest.onProgressUpdate,
                    onnxBackend: onnxRequest.onnxBackend!);
              } else {
                throw Exception("File not exist");
              }
            }
          case LoadModelWay.fromAssets:
            {
              final byteData = await rootBundle.load(baseModel.source);
              Uint8List modelBuffer = byteData.buffer.asUint8List();
              return await loadModelCreateSession(
                  modelBuffer: modelBuffer,
                  numThreads: onnxRequest.numThreads,
                  onProgressUpdate: onnxRequest.onProgressUpdate,
                  onnxBackend: onnxRequest.onnxBackend!);
            }
          case LoadModelWay.fromBuffer:
            {
              if (onnxRequest.uint8list != null) {
                Uint8List modelBuffer = onnxRequest.uint8list!;
                return await loadModelCreateSession(
                    modelBuffer: modelBuffer,
                    numThreads: onnxRequest.numThreads,
                    onProgressUpdate: onnxRequest.onProgressUpdate,
                    onnxBackend: onnxRequest.onnxBackend!);
              } else {
                throw Exception("Buffer not found");
              }
            }
          case LoadModelWay.fromURL:
            {
              return await loadModelCreateSession(
                  urlPath: baseModel.source,
                  numThreads: onnxRequest.numThreads,
                  onProgressUpdate: onnxRequest.onProgressUpdate,
                  onnxBackend: onnxRequest.onnxBackend!);
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
      {dynamic? modelBuffer,
      String? urlPath,
      int? numThreads,
      Function(double)? onProgressUpdate,
      required ONNXBackend onnxBackend}) async {
    var session;
    //numThreads recommend 1(by default 1)
    if (urlPath != null) {
      if (!kIsWeb) {
        throw Exception(
            "The model can only be uploaded using the path on the web");
      } else {
        session = await jsVMService.callJSAsync(
            "window.onnx.createSessionBufferPath($numThreads, '${onnxBackend.toString().split(".").last}', '$urlPath')");
      }
    } else {
      final isLoad = await loadOnWeb(
          byts: modelBuffer,
          callFunction: "window.onnx.receiveChunk",
          onProgressUpdate: onProgressUpdate);
      if (isLoad == true) {
        session = await jsVMService.callJSAsync(
            "window.onnx.createSessionBufferPath($numThreads, '${onnxBackend.toString().split(".").last}')");
      } else {
        throw Exception("Model not load on web");
      }
    }
    Map<String, dynamic> res = await jsonDecode(session);
    if (res.containsKey("error")) {
      throw Exception("Error: ${res["error"]}");
    }
    inputNames = res["inputNames"];
    outputNames = res["outputNames"];
    return true;
  }

  Future<bool> loadOnWeb(
      {required Uint8List byts,
      required String callFunction,
      Function(double)? onProgressUpdate}) async {
    int chunkSize = byts.length ~/ 100;
    int offset = 0;

    while (offset < byts.length) {
      int end =
          (offset + chunkSize < byts.length) ? offset + chunkSize : byts.length;
      Uint8List chunk = byts.sublist(offset, end);
      print(chunkSize);
      final res =
          await jsVMService.callJS(callFunction + "(${chunk.toString()})");
      offset += chunkSize;
      if (onProgressUpdate != null) {
        double progress = (offset / byts.length) * 100;
        if (progress > 100) {
          progress = 100;
        }
        onProgressUpdate(progress);
      }
    }
    return true;
  }

  @override
  Future<bool> isModelLoaded() async {
    final isload = await jsVMService.callJS("window.onnx.isModelLoaded()");
    Map<String, dynamic> res = jsonDecode(isload);
    return res["res"];
  }

  @override
  Future<bool> restartModel(
      {required TaskRequestModel request, required BaseModel baseModel}) async {
    try {
      final isStop = await this.stopModel();
      if (isStop != true) {
        return false;
      } else {
        final isLoad =
            await this.addModel(request: request, baseModel: baseModel);
        if (isLoad != true) {
          return false;
        } else {
          return true;
        }
      }
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
        List<Map<String, dynamic>> predict = [];
        for (var oneOutput in outputNames!) {
          Map<String, dynamic> sortedData = {};
          var sortedEntries = dataOutput["output"][oneOutput].entries.toList()
            ..sort((a, b) => (b.value as double).compareTo(a.value as double));
          if (onnxRequest.topPredictEntries != null) {
            var topPredictValue =
                sortedEntries.take(onnxRequest.topPredictEntries).toList();
            sortedData.addEntries(topPredictValue);
          } else {
            sortedData.addEntries(sortedEntries);
          }
          predict.add(sortedData);
        }
        return OnnxResponsModel(predict: predict);
      } catch (e) {
        throw Exception("Error: $e");
      }
    } else {
      throw Exception("Input data not load or shape not found");
    }
  }

  @override
  Future<bool> stopModel() async {
    try {
      final stopeSession =
          await jsVMService.callJSAsync("window.onnx.stopModel()");
      Map<String, dynamic> res = jsonDecode(stopeSession);
      if (res.containsKey("error")) {
        throw Exception("${res["error"]}");
      }
      print('Model was close successful');
      return true;
    } catch (e) {
      throw Exception("Model wasn`t stop: $e");
    }
  }

  Future<Map<String, bool>> checkWebGLAndWebGPU() async {
    const String webGLCheck = """
      (function() {
        try {
          var canvas = document.createElement('canvas');
          return !!window.WebGLRenderingContext && !!canvas.getContext('webgl');
        } catch(e) {
          return false;
        }
      })();
    """;

    const String webGPUCheck = """
      (function() {
        return !!navigator.gpu;
      })();
    """;

    final webGLSupported = await jsVMService.callJS(webGLCheck) as bool;
    final webGPUSupported = await jsVMService.callJS(webGPUCheck) as bool;

    return {
      "webgl": webGLSupported,
      "webgpu": webGPUSupported,
    };
  }
}
