import 'dart:typed_data';

import 'package:ai_model_land/modules/core/task_request_model.dart';

class TensorFlowRequestModel implements TaskRequestModel {
  int? addressModel;

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

  int? imgHeight;

  int? imgWidth;

  double? threshold;

  LoadModelWay? loadModelWay;

  @override
  String? labelsFile;

  @override
  Object? data;

  @override
  List<Object>? dataMulti;

  TensorFlowRequestModel(
      {this.uint16list,
      this.float32list,
      this.uint32list,
      this.uint64list,
      this.imgHeight,
      this.imgWidth,
      this.labelsFile,
      this.uint8list,
      this.threshold,
      this.async,
      this.data,
      this.loadModelWay,
      this.addressModel,
      this.dataMulti});
}

enum LoadModelWay {
  fromAssets,
  fromFile,
  fromAddress,
  fromBuffer;
}
