import 'dart:typed_data';

abstract class TaskRequestModel {
  Uint8List? uint8list;
  Object? data;
  String? labelsFile;
  List<Object>? dataMulti;
  LoadModelWay? loadModelWay;
}

enum LoadModelWay {
  fromAssets,
  fromFile,
  fromAddress,
  fromBuffer,
  fromURL,
  fromID;
}
