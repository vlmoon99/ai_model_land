import 'package:json_annotation/json_annotation.dart';

part 'base_model.g.dart';

@JsonSerializable()
class BaseModel {
  final int? id;
  final String source;
  final ModelFormat format;
  final ModelSourceType sourceType;

  BaseModel({
    this.id,
    required this.source,
    required this.format,
    required this.sourceType,
  });

  factory BaseModel.fromJson(Map<String, dynamic> json) =>
      _$BaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$BaseModelToJson(this);
}

enum ModelFormat { tflite, tfjs, pytorch, onnx, transformerjs }

enum ModelSourceType { local, network }
