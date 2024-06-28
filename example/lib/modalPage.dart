import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:ai_model_land_example/main.dart';
import 'package:image/image.dart' as img;
import 'package:ai_model_land/ai_model_land_lib.dart';
import 'package:ai_model_land/modules/core/base_model.dart';
import 'package:ai_model_land/modules/providers/tensor_flow/tensorflow_request_model.dart';
import 'package:ai_model_land_example/singlton/ai_model_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ModelPage extends StatefulWidget {
  final BaseModel baseModel;
  const ModelPage({super.key, required this.baseModel});

  @override
  State<ModelPage> createState() => _ModelPageState();
}

class _ModelPageState extends State<ModelPage> {
  final AiModelLandLib _aiModelLand = AiModelProvider().aiModelLand;
  Uint8List imgByteList = Uint8List(0);

  String? lables;

  // late bool isModelLoaded;

  Future<bool>? isAdd;

  Future<bool> loadModel({required BaseModel baseModel}) async {
    return await _aiModelLand.loadModel(
        request: TensorFlowRequestModel(loadModelWay: LoadModelWay.fromFile),
        baseModel: baseModel);
  }

  // bool isModelLoadedF({required BaseModel baseModel}) {
  //   return _aiModelLand.isModelLoaded(baseModel: baseModel);
  // }

  Future<void> deleteMoodel({required BaseModel baseModel}) async {
    await _aiModelLand.deleteModel(baseModel: baseModel, fromDevice: false);
  }

  Future<void> stopModel({required BaseModel baseModel}) async {
    await _aiModelLand.stopModel(baseModel: baseModel);
  }

  Future<void> runModel({required BaseModel baseModel}) async {
    if (imgByteList.isEmpty) {
      throw Exception('Img not add');
    }
    if (lables == null) {
      print('Lables not add');
    }
    await _aiModelLand.runTaskOnTheModel(
        request: TensorFlowRequestModel(
            data: imgByteList, lablesFile: lables, threshold: 0.01),
        baseModel: baseModel);
  }

  Uint8List imageToByteListFloat32(
      img.Image image, int inputSize, double mean, double std) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (pixel.r - mean) / std;
        buffer[pixelIndex++] = (pixel.g - mean) / std;
        buffer[pixelIndex++] = (pixel.b - mean) / std;
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  Future<String?> pickLables() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        lables = result.files.single.path!;
      });
    } else {
      return null;
    }
  }

  Future<String?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final listBity = await File(result.files.single.path!).readAsBytes();
      img.Image image = img.decodeImage(listBity)!;
      img.Image resizedImage = img.copyResize(image, width: 224, height: 224);
      final Uint8List last =
          imageToByteListFloat32(resizedImage, 224, 127.5, 127.5);
      setState(() {
        imgByteList = last;
      });
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interaction with ${widget.baseModel.nameFile}'),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isAdd = loadModel(baseModel: widget.baseModel);
                      });
                    },
                    child: Text('Load model to provider'),
                  ),
                  SizedBox(width: 10),
                  isAdd == null
                      ? Text("Result: model not load")
                      : FutureBuilder(
                          future: isAdd,
                          builder: (BuildContext context,
                              AsyncSnapshot<bool> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return SelectableText('Error: ${snapshot.error}');
                            } else if (snapshot.data == true) {
                              return Text("Result: model was loaded");
                            } else {
                              return Text("Result: try add again");
                            }
                          },
                        ),
                ],
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                stopModel(baseModel: widget.baseModel);
                setState(() {
                  isAdd = Future.value(false);
                });
                // setState(() {
                //   isModelLoaded = false;
                // });
              },
              child: Text('Stop model'),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: pickFile,
              child: Text('Pick model File (IMG)'),
            ),
            imgByteList.length == 0 ? Text("img not add") : Text('img was add'),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: pickLables,
              child: Text('Pick model File (Lables)'),
            ),
            lables == null ? Text("img not add") : Text('img was add'),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                runModel(baseModel: widget.baseModel);
              },
              child: Text('Run model'),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                deleteMoodel(baseModel: widget.baseModel);
                Navigator.pop(context, true);
              },
              child: Text('Delete model'),
            ),
            // Text('${img.last}'),
          ],
        ),
      ),
    );
  }
}
