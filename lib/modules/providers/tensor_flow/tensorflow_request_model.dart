import 'dart:io';
import 'dart:typed_data';

import 'package:ai_model_land/modules/core/task_request_model.dart';

class TensorFlowRequestModel implements TaskRequestModel {
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

  @override
  File? lablesFile;

  @override
  List? lablesList;

  TensorFlowRequestModel(
      {this.uint16list,
      this.float32list,
      this.uint32list,
      this.uint64list,
      this.imgHight,
      this.imgWidth,
      this.lablesFile,
      this.lablesList,
      this.uint8list,
      this.threshold,
      this.async});
}
