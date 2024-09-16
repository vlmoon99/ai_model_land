import 'dart:io';
import 'dart:typed_data';

import 'package:ai_model_land/models/core/base_model.dart';
import 'package:ai_model_land/models/core/task_request_model.dart';
import 'package:ai_model_land/models/providers/onnx/onnx_request_model.dart';
import 'package:ai_model_land_example/services/services.dart';
import 'package:ai_model_land_example/shared_widgets/custom_app_bar.dart';
import 'package:ai_model_land_example/shared_widgets/custom_button.dart';
import 'package:ai_model_land_example/thems/thems.dart';
import 'package:ai_model_land_example/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:image/image.dart' as img;

class OnnxImageClassification extends StatefulWidget {
  const OnnxImageClassification({super.key});

  @override
  State<OnnxImageClassification> createState() =>
      _OnnxImageClassificationState();
}

class _OnnxImageClassificationState extends State<OnnxImageClassification> {
  final GlobalVM _aiModelLand = Modular.get(key: 'GlobalVM');
  final UtilsClass preprocesingclass = Modular.get<UtilsClass>();
  final sourceController = TextEditingController();
  Float32List? inputBytes;

  BaseModel baseModel = BaseModel(
      source: "assets/onnx/image_classification/mobilenetv2-7.onnx",
      nameFile: "photo-detection-classification",
      format: ModelFormat.onnx,
      sourceType: ModelSourceType.local);

  Future<bool> loadModel() async {
    return await _aiModelLand.loadModel(
        request: OnnxRequestModel(loadModelWay: LoadModelWay.fromAssets),
        baseModel: baseModel);
  }

  Future runModel({required Float32List inputBytes}) async {
    return await _aiModelLand.runTaskOnTheModel(
        request: OnnxRequestModel(dataMulti: [
          inputBytes
        ], shape: [
          [1, 3, 224, 224]
        ], threshold: 4),
        baseModel: baseModel);
  }

  Future<String?> pickFileIMG() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      if (kIsWeb == true) {
        // final bytes = result.files.first.bytes;
        // if (bytes != null && bytes.isNotEmpty) {
        //   img.Image image = img.decodeImage(bytes)!;
        //   img.Image resizedImage =
        //       img.copyResize(image, width: 224, height: 224);
        //   final Float32List photoConvert = preprocesingclass
        //       .imageDataToTensor(resizedImage.getBytes(), [1, 3, 224, 224]);
        //   setState(() {
        //     inputBytes = photoConvert;
        //   });
        // } else {
        //   throw Exception("Bytes file not exist");
        // }
      } else {
        final file = File(result.files.single.path!);
        if (await file.exists()) {
          final bytes = file.readAsBytesSync();
          img.Image image = img.decodeImage(bytes)!;
          img.Image resizedImage =
              img.copyResize(image, width: 224, height: 224);
          final Float32List photoConvert = preprocesingclass
              .imageDataToTensor(resizedImage, [1, 3, 224, 224]);
          //               final Float32List photoConvert = preprocesingclass.imageDataToTensor(
          // resizedImage.buffer.asUint8List(), [1, 3, 224, 224]);
          setState(() {
            inputBytes = photoConvert;
          });
        } else {
          throw Exception("File not exist");
        }
      }
    } else {
      return null;
    }
  }

  Future<bool> stopModel() async {
    await _aiModelLand.stopModel(baseModel: baseModel);
    return true;
  }

  Future<bool> restartModel() async {
    await _aiModelLand.restartModel(
        request: OnnxRequestModel(), baseModel: baseModel);
    return true;
  }

  void checkModelLoadedStop({required BaseModel baseModel}) async {
    final modelUpload = await _aiModelLand.isModelLoaded(baseModel: baseModel);
    if (modelUpload) {
      stopModel();
    }
  }

  @override
  void dispose() {
    checkModelLoadedStop(baseModel: baseModel);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: "ONNX Image Model"),
      backgroundColor: Thems.mainBackgroundColor,
      body: Container(
        padding: EdgeInsets.all(6),
        child: Column(
          children: [
            Flexible(
                child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "ONNX Model Image",
                    style: Thems.textStyle,
                  ),
                  Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: pickFileIMG,
                            child: Text('Pick image File'),
                          ),
                          CustomButton(
                              onPressed: () async {
                                await loadModel();
                              },
                              text: "Load Model"),
                          FilledButton(
                              onPressed: () {
                                if (inputBytes != null) {
                                  runModel(inputBytes: inputBytes!);
                                }
                              },
                              child: Text("Run model")),
                          ElevatedButton(
                            onPressed: stopModel,
                            child: Text('Stop Model'),
                          ),
                          ElevatedButton(
                            onPressed: restartModel,
                            child: Text('Restart Model'),
                          ),
                        ],
                      )),
                  SelectableText("${sourceController.text}"),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
