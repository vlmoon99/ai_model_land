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
  Uint16List? uint16list;

  @override
  Uint32List? uint32list;

  @override
  Uint64List? uint64list;

  @override
  Uint8List? uint8list;

  @override
  LoadModelWay? loadModelWay;

  String? loadModelFilePath;

  String? pathToAsset;

  int? pointerAddress;

  double? threshold;

  List<List<int>>? shape;

  List<String>? typeInputData;

  int? numThreads;

  OnnxRequestModel(
      {this.data,
      this.dataMulti,
      this.labelsFile,
      this.loadModelWay,
      this.uint16list,
      this.uint32list,
      this.uint64list,
      this.uint8list,
      this.loadModelFilePath,
      this.pointerAddress,
      this.threshold,
      this.pathToAsset,
      this.shape,
      this.typeInputData,
      this.numThreads});
}
