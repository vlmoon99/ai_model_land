import 'dart:typed_data';

import 'package:ai_model_land/models/core/task_request_model.dart';

class OnnxRequestModel implements TaskRequestModel {
  @override
  Object? data;

  @override
  List<Object>? dataMulti;

  @override
  String? labelsFile;

  @override
  Uint8List? uint8list;

  @override
  LoadModelWay? loadModelWay;


  String? urlPath;


  String? pathToAsset;

  double? threshold;

  List<List<int>>? shape;

  List<String>? typeInputData;

  int? numThreads;

  int? topPredictEntries;

  Function(double)? onProgressUpdate;

  ONNXBackend? onnxBackend;

  OnnxRequestModel(
      {this.data,
      this.dataMulti,
      this.labelsFile,
      this.loadModelWay,
      this.uint8list,
      this.urlPath,
      this.threshold,
      this.pathToAsset,
      this.shape,
      this.typeInputData,
      this.numThreads,
      this.topPredictEntries,
      this.onProgressUpdate,
      this.onnxBackend});
}

enum ONNXBackend { webgl, webgpu, cpu, wasm }
