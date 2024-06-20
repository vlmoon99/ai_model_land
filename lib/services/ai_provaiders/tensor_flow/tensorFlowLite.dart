import 'dart:io';

import 'package:ai_model_land/modules/core/models/base_model.dart';
import 'package:ai_model_land/modules/core/models/task_request_model.dart';
import 'package:ai_model_land/modules/core/models/task_response_model.dart';
import 'package:ai_model_land/services/provider_ai_service.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class TensorFlowLite extends ProviderAiService {
  late Interpreter _interpreter;
  late IsolateInterpreter _isolateInterpreter;
  TensorFlowLite() {}

  factory TensorFlowLite.defaultInstance() {
    return TensorFlowLite();
  }

  @override
  Future<bool> addModalFromFile({required BaseModel baseModel}) async {
    try {
      _interpreter = await Interpreter.fromFile(File('${baseModel.source}'));
      // _isolateInterpreter =
      //     await IsolateInterpreter.create(address: _interpreter.address);

      // var outputTensors = _interpreter.getOutputTensors();
      // _outputShapes = [];
      // _outputTypes = [];
      // outputTensors.forEach((tensor) {
      //   _outputShapes.add(tensor.shape);
      //   _outputTypes.add(tensor.type);
      // });
      var outputTensors = _interpreter.getOutputTensors();
      print('interpreter was create successful');
      return true;
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
  Future restartModal() {
    // TODO: implement restartModal
    throw UnimplementedError();
  }

  @override
  Future<TaskResponseModel> runTaskOnTheModel(TaskRequestModel request) {
    // TODO: implement runTaskOnTheModel
    throw UnimplementedError();
  }

  @override
  Future<void> stopModal() async {
    _interpreter.close();
    await _isolateInterpreter.close();
  }
}
