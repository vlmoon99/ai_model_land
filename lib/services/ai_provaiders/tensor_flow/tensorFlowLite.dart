import 'dart:io';
import 'dart:typed_data';

import 'package:ai_model_land/modules/core/base_model.dart';

import 'package:ai_model_land/modules/core/task_request_model.dart';
import 'package:ai_model_land/modules/core/task_response_model.dart';
import 'package:ai_model_land/modules/providers/tensor_flow/tensorflow_model.dart';
import 'package:ai_model_land/services/provider_ai_service.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class TensorFlowLite extends ProviderAiService {
  late Interpreter _interpreter;
  late IsolateInterpreter _isolateInterpreter;
  var _inputShapes = [];
  var _inputTypes = [];
  var _outputShapes = [];
  var _outputTypes = [];
  TensorFlowLite() {}

  factory TensorFlowLite.defaultInstance() {
    return TensorFlowLite();
  }

  @override
  Future<bool> addModalFromFile({required BaseModel baseModel}) async {
    try {
      final file = File('${baseModel.source}');
      if (await file.exists()) {
        _interpreter = await Interpreter.fromFile(file);
        // _isolateInterpreter =
        //     await IsolateInterpreter.create(address: _interpreter.address);
        print('interpreter was create successful');
        return true;
      } else {
        print("file not exist");
        return false;
      }
    } catch (e) {
      print("Error while creating interpreter: $e");
    }
    return false;
  }

  @override
  void checkPlatformGPUAcceleratorPossibilities(String params) {
    // TODO: implement checkPlatformGPUAcceleratorPossibilities
  }

  @override
  Future deleteModal() {
    // TODO: implement deleteModal
    throw UnimplementedError();
  }

  @override
  Future<void> restartModal({required BaseModel baseModel}) async {
    try {
      _interpreter.close();
      _interpreter = await Interpreter.fromFile(File(baseModel.source));
    } catch (e) {
      throw Exception("Model no restart successful: $e");
    }
  }

  @override
  Future<TaskResponseModel> runTaskOnTheModel(TaskRequestModel request) {
    try {
      if (_interpreter.isDeleted) {
        throw Exception('Interpreter not found');
      }
      final tensorRequest = request as TensorFlowRequestModel;
      getInformationModel();

      if (tensorRequest.uint8list == null) {
        throw Exception('uint8list is absent');
      }

      ByteConversionUtils.convertBytesToObject(
          tensorRequest.uint8list!, _inputTypes[0], _inputShapes[0]);
      var outputTensor = List.filled(1001, 0.0).reshape([1, 1001]);
      print('run successful');
    } catch (e) {
      throw Exception("Model no run successful: $e");
    }
    throw UnimplementedError();
  }

  void getInformationModel() {
    if (_inputShapes.isEmpty &&
        _inputTypes.isEmpty &&
        _outputShapes.isEmpty &&
        _outputTypes.isEmpty) {
      var inputTensors = _interpreter.getInputTensors();
      inputTensors.forEach((tensor) {
        _inputShapes.add(tensor.shape);
        _inputTypes.add(tensor.type);
      });
      var outputTensors = _interpreter.getOutputTensors();
      outputTensors.forEach((tensor) {
        _outputShapes.add(tensor.shape);
        _outputTypes.add(tensor.type);
      });
    }
  }

  @override
  Future<void> stopModal() async {
    try {
      _interpreter.close();
      _inputShapes.clear();
      _inputTypes.clear();
      _outputShapes.clear();
      _outputTypes.clear;
      // await _isolateInterpreter.close();
      print('Model was close successful');
    } catch (e) {
      throw Exception("Model no close successful: $e");
    }
  }

  @override
  bool isModelLoaded() {
    if (_interpreter.isDeleted) {
      return false;
    }
    return true;
  }
}
