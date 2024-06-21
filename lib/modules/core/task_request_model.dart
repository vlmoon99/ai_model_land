import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

abstract class TaskRequestModel {
  Uint8List? uint8list;
  Uint16List? uint16list;
  Uint32List? uint32list;
  Uint64List? uint64list;
  File? lablesFile;
  List? lablesList;
}
