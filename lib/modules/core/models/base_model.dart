class BaseModel {
  final String id;

  final ModelFormat format;

  final ModelSourceType sourceType;

  BaseModel({required this.id, required this.format, required this.sourceType});
}

enum ModelFormat { tflite, tfjs, pytorch, onnx, transformerjs }

enum ModelSourceType { local, network }
