import 'dart:async';
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
  IsolateInterpreter? _isolateInterpreter;
  var _inputShapes = [];
  var _inputTypes = [];
  var _outputShapes = [];
  var _outputTypes = [];
  TensorFlowLite() {}

  factory TensorFlowLite.defaultInstance() {
    return TensorFlowLite();
  }

  @override
  Future<bool> addModel(
      {required TaskRequestModel request, required BaseModel baseModel}) async {
    try {
      final tensorRequest = request as TensorFlowRequestModel;
      if (tensorRequest.loadModelWay != null) {
        switch (tensorRequest.loadModelWay!) {
          case LoadModelWay.fromFile:
            {
              final file = File(baseModel.source);
              if (await file.exists()) {
                _interpreter = await Interpreter.fromFile(file);
                getInformationAndIsolate();
                print('interpreter by file was create successful');
                return true;
              } else {
                print('File not exist');
                return false;
              }
            }
          case LoadModelWay.fromAssets:
            {
              _interpreter = await Interpreter.fromAsset(baseModel.source);
              getInformationAndIsolate();
              print('interpreter by asset was create successful');
              return true;
            }
          case LoadModelWay.fromBuffer:
            {
              if (request.uint8list != null) {
                _interpreter = await Interpreter.fromBuffer(request.uint8list!);
                getInformationAndIsolate();
                return true;
              } else {
                print('Not add uint8list for buffer');
                return false;
              }
            }
          case LoadModelWay.fromAddress:
            {
              if (request.adressModel != null) {
                getInformationAndIsolate();
                print('interpreter by asset was create successful');
                return true;
              } else {
                print('Not add adress model for adress');
              }
            }
        }
      } else {
        throw Exception("Not choose way add model");
      }
    } catch (e) {
      print("Error while creating interpreter: $e");
    }
    return false;
  }

  Future<void> getInformationAndIsolate() async {
    getInformationModel();
    _isolateInterpreter =
        await IsolateInterpreter.create(address: _interpreter.address);
  }

  void getInformationModel() {
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

  @override
  void checkPlatformGPUAcceleratorPossibilities(String params) {
    // TODO: implement checkPlatformGPUAcceleratorPossibilities
  }

  @override
  Future deleteModel() {
    // TODO: implement deleteModal
    throw UnimplementedError();
  }

  @override
  Future<void> restartModel(
      {required TaskRequestModel request, required BaseModel baseModel}) async {
    try {
      _interpreter.close();
      await addModel(request: request, baseModel: baseModel);
    } catch (e) {
      throw Exception("Model no restart successful: $e");
    }
  }

  @override
  Future<TaskResponseModel> runTaskOnTheModel(TaskRequestModel request) async {
    try {
      if (_interpreter.isDeleted) {
        throw Exception('Interpreter not found');
      }

      final tensorRequest = request as TensorFlowRequestModel;

      if (_inputShapes.isEmpty &&
          _inputTypes.isEmpty &&
          _outputShapes.isEmpty &&
          _outputTypes.isEmpty) {
        throw Exception('No information about model');
      }

      if (tensorRequest.data == null && tensorRequest.dataMulti == null) {
        throw Exception('Data is absent');
      } else if (tensorRequest.data != null) {
        return await singlInputinteraction(tensorRequest: tensorRequest);
      } else {
        return await multiInputinteraction(tensorRequest: tensorRequest);
      }
    } catch (e) {
      throw Exception("Model no run successful: $e");
    }
  }

  Future<TensorFlowResponsModel> singlInputinteraction(
      {required TensorFlowRequestModel tensorRequest}) async {
    final List<dynamic> outputTensor = creatOutputTensorsSingl();

    if (tensorRequest.async == true && !_interpreter.isDeleted) {
      await _isolateInterpreter!.run(tensorRequest.data!, outputTensor);
    } else {
      _interpreter.run(tensorRequest.data!, outputTensor);
    }
    if (tensorRequest.lablesFile != null && tensorRequest.threshold != null) {
      File lebelsFile = File(tensorRequest.lablesFile!);
      if (await lebelsFile.exists()) {
        final List<String> lableList =
            await convertFileToList(lables: lebelsFile);
        final List<double> outputList = outputTensor[0];
        final List<String> pridict = getPredict(
            lableList: lableList,
            outputList: outputList,
            threshold: tensorRequest.threshold!);
        return TensorFlowResponsModel(predictForSingle: pridict);
      } else {
        throw Exception('Labels file not exist');
      }
    } else {
      return TensorFlowResponsModel(predictForSingle: outputTensor[0]);
    }
  }

  List<dynamic> creatOutputTensorsSingl() {
    late List<dynamic> outputTensor;
    if (_outputTypes.toString().contains("float")) {
      outputTensor = List.filled(
              calculateTotalNumbList(outputShapes: _outputShapes.last), 0.0)
          .reshape(_outputShapes.last);
    } else if (_outputTypes.toString().contains("int")) {
      outputTensor = List.filled(
              calculateTotalNumbList(outputShapes: _outputShapes.last), 0)
          .reshape(_outputShapes.last);
    }
    return outputTensor;
  }

  Future<TensorFlowResponsModel> multiInputinteraction(
      {required TensorFlowRequestModel tensorRequest}) async {
    final Map<int, List<dynamic>> outputTensors = creatOutputTensorsMulty();

    if (tensorRequest.async == true) {
      _isolateInterpreter =
          await IsolateInterpreter.create(address: _interpreter.address);

      await _isolateInterpreter!
          .runForMultipleInputs(tensorRequest.dataMulti!, outputTensors);
    } else {
      _interpreter.runForMultipleInputs(
          tensorRequest.dataMulti!, outputTensors);
    }
    return TensorFlowResponsModel(predictForMulti: outputTensors);
  }

  Map<int, List<dynamic>> creatOutputTensorsMulty() {
    Map<int, List<dynamic>> outputTensor = {};
    TensorType outputTensorType;
    for (int i = 0; i < _outputTypes.length; i++) {
      outputTensorType = _outputTypes[i];
      if (outputTensorType.toString().contains("float")) {
        outputTensor[i] = List.filled(
                calculateTotalNumbList(outputShapes: _outputShapes[i]), 0.0)
            .reshape(_outputShapes[i]);
      } else if (outputTensorType.toString().contains("int")) {
        outputTensor[i] = List.filled(
                calculateTotalNumbList(outputShapes: _outputShapes[i]), 0)
            .reshape(_outputShapes[i]);
      }
    }
    return outputTensor;
  }

  int calculateTotalNumbList({required List<int> outputShapes}) {
    return outputShapes.reduce((a, b) => a * b);
  }

  @override
  Future<void> stopModel() async {
    try {
      if (_isolateInterpreter != null) {
        await _isolateInterpreter!.close();
      }
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

  Future<List<String>> convertFileToList({required File lables}) async {
    String fileContent = await lables.readAsString();
    List<String> lines = fileContent
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    return lines;
  }

  List<String> getPredict(
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

    List<String> resultList = [
      for (var entry in filteredMap) "${entry.key}: ${entry.value}"
    ];
    return resultList;
  }
}
