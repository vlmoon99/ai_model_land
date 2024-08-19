import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:ai_model_land/models/core/base_model.dart';

import 'package:ai_model_land/models/core/task_request_model.dart';
import 'package:ai_model_land/models/core/task_response_model.dart';
import 'package:ai_model_land/models/providers/tensor_flow/tensorflow_request_model.dart';
import 'package:ai_model_land/models/providers/tensor_flow/tensorflow_respons_model.dart';
import 'package:ai_model_land/services/provider_ai_service.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class TensorFlowLite extends ProviderAiService {
  Interpreter? _interpreter;
  IsolateInterpreter? _isolateInterpreter;
  var _inputShapes = [];
  var _inputTypes = [];
  var _outputShapes = [];
  var _outputTypes = [];
  bool? isAddModel;
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
                _getInformationAndIsolate();
                print('Interpreter from file was created successfully');
                return true;
              } else {
                print('File not exist');
                return false;
              }
            }
          case LoadModelWay.fromAssets:
            {
              _interpreter = await Interpreter.fromAsset(baseModel.source);
              _getInformationAndIsolate();
              print('Interpreter from asset was created successfully');
              return true;
            }
          case LoadModelWay.fromBuffer:
            {
              if (request.uint8list != null) {
                _interpreter = await Interpreter.fromBuffer(request.uint8list!);
                _getInformationAndIsolate();
                return true;
              } else {
                print('Not add uint8list for buffer');
                return false;
              }
            }
          case LoadModelWay.fromAddress:
            {
              if (request.addressModel != null) {
                _getInformationAndIsolate();
                print('Interpreter from asset was created successfully');
                return true;
              } else {
                print('Not add address model for address');
              }
            }
        }
      } else {
        throw Exception("Model load way not specified");
      }
    } catch (e) {
      throw Exception("Error while creating interpreter: $e");
    }
    return false;
  }

  Future<void> _getInformationAndIsolate() async {
    getInformationModel();
    _isolateInterpreter =
        await IsolateInterpreter.create(address: _interpreter!.address);
    isAddModel = true;
  }

  void getInformationModel() {
    if (_interpreter != null && !_interpreter!.isDeleted) {
      var inputTensors = _interpreter!.getInputTensors();
      inputTensors.forEach((tensor) {
        _inputShapes.add(tensor.shape);
        _inputTypes.add(tensor.type);
      });
      var outputTensors = _interpreter!.getOutputTensors();
      outputTensors.forEach((tensor) {
        _outputShapes.add(tensor.shape);
        _outputTypes.add(tensor.type);
      });
    } else {
      throw Exception("Interpreter was not load");
    }
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
      await stopModel();
      await addModel(request: request, baseModel: baseModel);
    } catch (e) {
      throw Exception("Model no restart successful: $e");
    }
  }

  @override
  Future<TaskResponseModel> runTaskOnTheModel(TaskRequestModel request) async {
    try {
      if (_interpreter == null) {
        throw Exception("Interpreter not add");
      }
      if (_interpreter!.isDeleted) {
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
        return await _singleInputInteraction(tensorRequest: tensorRequest);
      } else {
        return await _multiInputInteraction(tensorRequest: tensorRequest);
      }
    } catch (e) {
      throw Exception("Model no run successful: $e");
    }
  }

  Future<TensorFlowResponseModel> _singleInputInteraction(
      {required TensorFlowRequestModel tensorRequest}) async {
    List<String> lableList;
    final List<dynamic> outputTensor = createOutputTensorsSingle();

    if (tensorRequest.async == true && !_interpreter!.isDeleted) {
      await _isolateInterpreter!.run(tensorRequest.data!, outputTensor);
    } else {
      _interpreter!.run(tensorRequest.data!, outputTensor);
    }
    if (tensorRequest.labelsFile != null && tensorRequest.threshold != null) {
      File labelsFile = File(tensorRequest.labelsFile!);
      if (await labelsFile.exists()) {
        lableList = await convertFileToList(lables: labelsFile);
      } else {
        throw Exception('Labels file not exist');
      }
    } else if (tensorRequest.labelsList != null &&
        tensorRequest.threshold != null) {
      lableList = tensorRequest.labelsList!;
    } else {
      return TensorFlowResponseModel(predictForSingle: outputTensor[0]);
    }

    final List<double> outputList = outputTensor[0];
    final Map<String, double> predict = getPredict(
        lableList: lableList,
        outputList: outputList,
        threshold: tensorRequest.threshold!);
    return TensorFlowResponseModel(predictForSingleLasbles: predict);
  }

  List<dynamic> createOutputTensorsSingle() {
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

  Future<TensorFlowResponseModel> _multiInputInteraction(
      {required TensorFlowRequestModel tensorRequest}) async {
    final Map<int, List<dynamic>> outputTensors = createOutputTensorsMulti();

    if (tensorRequest.async == true && !_interpreter!.isDeleted) {
      await _isolateInterpreter!
          .runForMultipleInputs(tensorRequest.dataMulti!, outputTensors);
    } else {
      _interpreter!
          .runForMultipleInputs(tensorRequest.dataMulti!, outputTensors);
    }
    return TensorFlowResponseModel(predictForMulti: outputTensors);
  }

  Map<int, List<dynamic>> createOutputTensorsMulti() {
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
      if (_interpreter != null) {
        _interpreter!.close();
      }
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
    if (_interpreter != null) {
      if (_interpreter!.isDeleted) {
        return false;
      }
      return true;
    } else {
      return false;
    }
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

    Map<String, double> map = Map.fromEntries(filteredMap);

    return map;
  }
}
