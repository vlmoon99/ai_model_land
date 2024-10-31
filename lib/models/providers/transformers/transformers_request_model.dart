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

  Object? tokenizerChatOptions;

  int? max_new_tokens;

  bool? do_sample;

  bool? use_external_data_format;

  bool? return_dict_in_generate;

  bool? skip_special_tokens;

  Object? optionsForGnerator;

  String? model_file_name;

  bool? useChatTemplate;

  TransformersRequestModel(
      {this.data,
      this.dataMulti,
      this.labelsFile,
      this.loadModelWay,
      this.uint8list,
      this.typeLoadModel,
      this.backendDevice,
      this.dtype,
      this.typeModel,
      this.tokenizerChatOptions,
      this.max_new_tokens,
      this.do_sample,
      this.return_dict_in_generate,
      this.skip_special_tokens,
      this.optionsForGnerator,
      this.use_external_data_format,
      this.model_file_name,
      this.useChatTemplate});
}

enum TransformersBackend { webgl, webgpu, cpu, wasm }

enum TypeLoadModel { standard, text_generation }
