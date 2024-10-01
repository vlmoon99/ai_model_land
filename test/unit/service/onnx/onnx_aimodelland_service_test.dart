import 'dart:typed_data';

import 'package:ai_model_land/models/core/base_model.dart';
import 'package:ai_model_land/models/core/task_request_model.dart';
import 'package:ai_model_land/models/providers/onnx/onnx_request_model.dart';
import 'package:ai_model_land/models/providers/onnx/onnx_respons_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../aimodelland_service.mocks.dart';

void main() {
  group("Unit tests for ONNX AiModelLand Service", () {
    test("Load ONNX model to Ai Model Land(from file, from assets)", () async {
      final service = MockAiModelLandLib();
      BaseModel baseModel = BaseModel(
          source: "path to model file",
          nameFile:
              "name this file(will be use for create model if you choose ModelSourceType.network)",
          format: ModelFormat.onnx,
          sourceType: ModelSourceType.local);
      OnnxRequestModel onnxRequestModel = OnnxRequestModel(
          numThreads: 2,
          loadModelWay: LoadModelWay.fromAssets,
          onnxBackend: ONNXBackend.cpu);

      when(service.loadModel(request: onnxRequestModel, baseModel: baseModel))
          .thenAnswer((_) async => true);

      final res = await service.loadModel(
          request: onnxRequestModel, baseModel: baseModel);
      expect(res, true);
    });

    test("Load ONNX model to Ai Model Land(fromBuffer)", () async {
      final service = MockAiModelLandLib();
      BaseModel baseModel = BaseModel(
          source: "You can leave this parameter empty",
          nameFile: "You can leave this parameter empty",
          format: ModelFormat.onnx,
          sourceType: ModelSourceType.local);
      OnnxRequestModel onnxRequestModel = OnnxRequestModel(
          loadModelWay: LoadModelWay.fromBuffer,
          onnxBackend: ONNXBackend.cpu,
          uint8list: Uint8List(0));

      when(service.loadModel(request: onnxRequestModel, baseModel: baseModel))
          .thenAnswer((_) async => true);

      final res = await service.loadModel(
          request: onnxRequestModel, baseModel: baseModel);
      expect(res, true);
    });

    test("Run model. Data it`s example", () async {
      final service = MockAiModelLandLib();
      BaseModel baseModel = BaseModel(
          source: "path to model file",
          nameFile: "name this file",
          format: ModelFormat.onnx,
          sourceType: ModelSourceType.local);
      OnnxRequestModel onnxRequestModel = OnnxRequestModel(dataMulti: [
        Float32List(0)
      ], shape: [
        [1, 3, 224, 224]
      ], threshold: 3, topPredictEntries: 5);

      OnnxResponsModel response = OnnxResponsModel(predict: [
        {"Tensor input": "value"}
      ]);

      when(service.runTaskOnTheModel(
              request: onnxRequestModel, baseModel: baseModel))
          .thenAnswer((_) async => response);

      final res = await service.runTaskOnTheModel(
          request: onnxRequestModel, baseModel: baseModel) as OnnxResponsModel;
      expect(res, response);
    });

    test("Stop model", () async {
      final service = MockAiModelLandLib();
      BaseModel baseModel = BaseModel(
          source: "path to model file",
          nameFile: "name this file",
          format: ModelFormat.onnx,
          sourceType: ModelSourceType.local);

      when(service.stopModel(baseModel: baseModel))
          .thenAnswer((_) async => true);

      final res = await service.stopModel(baseModel: baseModel);
      expect(res, true);
    });

    test("Restart model", () async {
      final service = MockAiModelLandLib();
      BaseModel baseModel = BaseModel(
          source: "path to model file",
          nameFile: "name this file",
          format: ModelFormat.onnx,
          sourceType: ModelSourceType.local);

      OnnxRequestModel request = OnnxRequestModel(
          numThreads: 1,
          loadModelWay: LoadModelWay.fromAssets,
          onnxBackend: ONNXBackend.cpu);

      when(service.restartModel(baseModel: baseModel, request: request))
          .thenAnswer((_) async => true);

      final res =
          await service.restartModel(baseModel: baseModel, request: request);
      expect(res, true);
    });
  });
}
