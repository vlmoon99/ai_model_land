import 'dart:typed_data';

import 'package:ai_model_land/models/core/base_model.dart';
import 'package:ai_model_land/models/core/task_request_model.dart';
import 'package:ai_model_land/models/providers/tensor_flow/tensorflow_request_model.dart';
import 'package:ai_model_land/models/providers/tensor_flow/tensorflow_respons_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../aimodelland_service.mocks.dart';

void main() {
  group("Unit tests for TensorFlow Lite AiModelLand Service", () {
    test("Load TensorFlow Lite model to Ai Model Land(from file, from assets)",
        () async {
      final service = MockAiModelLandLib();
      BaseModel baseModel = BaseModel(
          source: "path to model file",
          nameFile:
              "name this file(will be use for create model if you choose ModelSourceType.network)",
          format: ModelFormat.tflite,
          sourceType: ModelSourceType.local);
      TensorFlowRequestModel tensorFlowRequestModel =
          TensorFlowRequestModel(loadModelWay: LoadModelWay.fromAssets);

      when(service.loadModel(
              request: tensorFlowRequestModel, baseModel: baseModel))
          .thenAnswer((_) async => true);

      final res = await service.loadModel(
          request: tensorFlowRequestModel, baseModel: baseModel);
      expect(res, true);
    });

    test("Load TensorFlow Lite model to Ai Model Land(fromBuffer)", () async {
      final service = MockAiModelLandLib();
      BaseModel baseModel = BaseModel(
          source: "You can leave this parameter empty",
          nameFile: "You can leave this parameter empty",
          format: ModelFormat.onnx,
          sourceType: ModelSourceType.local);
      TensorFlowRequestModel tensorFlowRequestModel = TensorFlowRequestModel(
          loadModelWay: LoadModelWay.fromBuffer, uint8list: Uint8List(0));

      when(service.loadModel(
              request: tensorFlowRequestModel, baseModel: baseModel))
          .thenAnswer((_) async => true);

      final res = await service.loadModel(
          request: tensorFlowRequestModel, baseModel: baseModel);
      expect(res, true);
    });

    test("Run model. Data it`s example", () async {
      final service = MockAiModelLandLib();
      BaseModel baseModel = BaseModel(
          source: "path to model file",
          nameFile: "name this file",
          format: ModelFormat.onnx,
          sourceType: ModelSourceType.local);
      TensorFlowRequestModel tensorFlowRequestModel = TensorFlowRequestModel(
          data: Object(),
          threshold: 3,
          async: true,
          labelsList: ["Your convert to list lables"]);

      TensorFlowResponseModel response = TensorFlowResponseModel(
          predictForSingleLasbles: {"prediction for single input": 2.3});

      when(service.runTaskOnTheModel(
              request: tensorFlowRequestModel, baseModel: baseModel))
          .thenAnswer((_) async => response);

      final res = await service.runTaskOnTheModel(
          request: tensorFlowRequestModel,
          baseModel: baseModel) as TensorFlowResponseModel;
      expect(res, response);
    });

    test("Stop model", () async {
      final service = MockAiModelLandLib();
      BaseModel baseModel = BaseModel(
          source: "path to model file",
          nameFile: "name this file",
          format: ModelFormat.tflite,
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

      TensorFlowRequestModel request =
          TensorFlowRequestModel(loadModelWay: LoadModelWay.fromAssets);

      when(service.restartModel(baseModel: baseModel, request: request))
          .thenAnswer((_) async => true);

      final res =
          await service.restartModel(baseModel: baseModel, request: request);
      expect(res, true);
    });
  });
}
