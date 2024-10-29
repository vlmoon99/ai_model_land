import 'package:json_annotation/json_annotation.dart';

part 'base_model.g.dart';

@JsonSerializable()
class BaseModel {
  final int? id;
  final String source;
  final String nameFile;
  final ModelFormat format;
  final ModelSourceType sourceType;

  BaseModel({
    this.id,
    required this.source,
    required this.nameFile,
    required this.format,
    required this.sourceType,
  });

  factory BaseModel.fromJson(Map<String, dynamic> json) =>
      _$BaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$BaseModelToJson(this);

  @override
  String toString() {
    return "{id $id , source $source, format $format, sourceType $sourceType }";
  }
}

enum ModelFormat {
  tflite,
  onnx,
  transformers;


  @override
  String toString() {
    return name;
  }
}

enum ModelSourceType { local, network }
