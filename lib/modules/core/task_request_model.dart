import 'dart:typed_data';

abstract class TaskRequestModel {
  Uint8List? uint8list;
  Uint16List? uint16list;
  Uint32List? uint32list;
  Uint64List? uint64list;
  Object? data;
  String? lablesFile;
}
