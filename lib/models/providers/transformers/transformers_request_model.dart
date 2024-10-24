import 'dart:typed_data';

import 'package:ai_model_land/models/core/task_request_model.dart';

class TransformersRequestModel implements TaskRequestModel {
  @override
  Object? data;

  @override
  List<Object>? dataMulti;

  @override
  String? labelsFile;

  @override
  LoadModelWay? loadModelWay;

  @override
  Uint8List? uint8list;

  TypeLoadModel? typeLoadModel;

  String? typeModel;

  TransformersBackend? backendDevice;

  String? dtype;

  TransformersRequestModel(
      {this.data,
      this.dataMulti,
      this.labelsFile,
      this.loadModelWay,
      this.uint8list,
      this.typeLoadModel,
      this.backendDevice,
      this.dtype,
      this.typeModel});
}

enum TransformersBackend { webgl, webgpu, cpu, wasm }

enum TypeLoadModel { standard, text_generation }
