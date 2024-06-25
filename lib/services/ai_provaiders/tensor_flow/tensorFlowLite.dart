import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:ai_model_land/modules/core/base_model.dart';

import 'package:ai_model_land/modules/core/task_request_model.dart';
import 'package:ai_model_land/modules/core/task_response_model.dart';
import 'package:ai_model_land/modules/providers/tensor_flow/tensorflow_request_model.dart';
import 'package:ai_model_land/modules/providers/tensor_flow/tensorflow_respons_model.dart';
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
        _interpreter = Interpreter.fromFile(file);
        _isolateInterpreter =
            await IsolateInterpreter.create(address: _interpreter.address);
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
  Future<TaskResponseModel> runTaskOnTheModel(TaskRequestModel request) async {
    try {
      var outputTensor;
      if (_interpreter.isDeleted) {
        throw Exception('Interpreter not found');
      }
      final tensorRequest = request as TensorFlowRequestModel;
      getInformationModel();

      if (tensorRequest.uint8list == null) {
        throw Exception('uint8list is absent');
      }

      // final romalUint8List =
      //     normalizudFutureForUint8Lit(uint8List: tensorRequest.uint8list!);
      // var list = [];
      // print("${tensorRequest.uint8list!.lengthInBytes}");
      // Float32List.fromList(tensorRequest.uint8list!.toList());

      // final input = ByteConversionUtils.convertBytesToObject(
      //     tensorRequest.uint8list!, _inputTypes[0], _inputShapes[0]);
      // final input = ByteConversionUtils.convertObjectToBytes(
      //         tensorRequest.uint8list!, _inputTypes[0])
      //     .buffer;
      if (_outputTypes[0]._name.contains("float32")) {
        outputTensor =
            List.filled(_outputShapes[0][1], 0.0).reshape(_outputShapes[0]);
      } else if (_outputTypes[0]._name.contains("int")) {
        outputTensor =
            List.filled(_outputShapes[0][1], 0).reshape(_outputShapes[0]);
      }
      await _isolateInterpreter.run(
          tensorRequest.uint8list!.buffer, outputTensor);
      if (tensorRequest.lablesFile != null &&
          await tensorRequest.lablesFile!.exists() &&
          tensorRequest.threshold != null) {
        final List<String> lableList =
            await convertFileToList(lables: tensorRequest.lablesFile!);
        final List<double> outputList = outputTensor[0];
        final Map<String, double> pridict = getPredict(
            lableList: lableList,
            outputList: outputList,
            threshold: tensorRequest.threshold!);
        return TensorFlowResponsModel(predictWithLables: pridict);
      } else {
        return TensorFlowResponsModel(predict: outputTensor[0]);
      }
    } catch (e) {
      throw Exception("Model no run successful: $e");
    }
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
      await _isolateInterpreter.close();
      _interpreter.close();
      _inputShapes.clear();
      _inputTypes.clear();
      _outputShapes.clear();
      _outputTypes.clear();
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

  Uint8List normalizudFutureForUint8Lit({required Uint8List uint8List}) {
    for (int i = 0; i < uint8List.length; i++) {
      uint8List[i] = (uint8List[i] / 255.0).toInt();
    }
    return uint8List;
  }

  Future<List<String>> convertFileToList({required File lables}) async {
    String fileContent = await lables.readAsString();
    List<String> lines = fileContent
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    return lines;
  }

  Map<String, double> getPredict(
      {required List<String> lableList,
      required List<double> outputList,
      required double threshold}) {
    Map<String, double> predictMap = {};
    if (lableList.length != outputList.length) {
      throw Exception('Lables list and output list not match');
    }
    for (int i = 0; i < lableList.length; i++) {
      predictMap[lableList[i]] = outputList[i];
    }

    var filteredMap = predictMap.entries
        .where((entry) => entry.value > threshold)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    Map<String, double> resultMap = {
      for (var entry in filteredMap) entry.key: entry.value
    };
    return resultMap;
  }
}
