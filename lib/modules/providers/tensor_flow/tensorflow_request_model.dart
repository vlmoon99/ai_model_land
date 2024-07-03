import 'dart:typed_data';

import 'package:ai_model_land/modules/core/task_request_model.dart';

class TensorFlowRequestModel implements TaskRequestModel {
  int? adressModel;

  bool? async;

  @override
  Uint16List? uint16list;

  Float32List? float32list;

  @override
  Uint32List? uint32list;

  @override
  Uint64List? uint64list;

  @override
  Uint8List? uint8list;

  int? imgHight;

  int? imgWidth;

  double? threshold;

  LoadModelWay? loadModelWay;

  @override
  String? lablesFile;

  @override
  Object? data;

  @override
  List<Object>? dataMulti;

  TensorFlowRequestModel(
      {this.uint16list,
      this.float32list,
      this.uint32list,
      this.uint64list,
      this.imgHight,
      this.imgWidth,
      this.lablesFile,
      this.uint8list,
      this.threshold,
      this.async,
      this.data,
      this.loadModelWay,
      this.adressModel,
      this.dataMulti});
}

enum LoadModelWay {
  fromAssets,
  fromFile,
  fromAddress,
  fromBuffer;
}
