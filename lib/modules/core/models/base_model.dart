class BaseModel {
  final int? id;

  final String source;

  final ModelFormat format;

  final ModelSourceType sourceType;

  BaseModel(
      {this.id,
      required this.source,
      required this.format,
      required this.sourceType});
}

enum ModelFormat { tflite, tfjs, pytorch, onnx, transformerjs }

enum ModelSourceType { local, network }
