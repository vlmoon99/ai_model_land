import 'dart:io';
import 'dart:typed_data';

import 'package:ai_model_land/models/core/base_model.dart';
import 'package:ai_model_land/models/core/task_request_model.dart';
import 'package:ai_model_land/models/providers/onnx/onnx_request_model.dart';
import 'package:ai_model_land_example/services/services.dart';
import 'package:ai_model_land_example/shared_widgets/custom_app_bar.dart';
import 'package:ai_model_land_example/shared_widgets/custom_button.dart';
import 'package:ai_model_land_example/thems/thems.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';

class OnnxImageClassification extends StatefulWidget {
  const OnnxImageClassification({super.key});

  @override
  State<OnnxImageClassification> createState() =>
      _OnnxImageClassificationState();
}

class _OnnxImageClassificationState extends State<OnnxImageClassification> {
  final GlobalVM _aiModelLand = Modular.get(key: 'GlobalVM');
  final sourceController = TextEditingController();
  Uint8List? bytes;

  // BaseModel baseModel = BaseModel(
  //     source: "assets/onnx/image_classification/mobilenetv2-7.onnx",
  //     nameFile: "photo-detection-classification",
  //     format: ModelFormat.onnx,
  //     sourceType: ModelSourceType.local);

  Future<bool> loadModel() async {
    // ByteData byteData = await rootBundle.load(baseModel.source);
    // Uint8List modelBuffer = byteData.buffer.asUint8List();
    // if (bytes != null) {
    return await _aiModelLand.loadModel(
        request: OnnxRequestModel(loadModelWay: LoadModelWay.fromAssets),
        baseModel: BaseModel(
            source: "assets/onnx/image_classification/mobilenetv2-7.onnx",
            nameFile: "photo-detection-classification",
            format: ModelFormat.onnx,
            sourceType: ModelSourceType.local));
    // } else {
    //   return false;
    // }
  }

  Future<String?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      if (kIsWeb == true) {
        setState(() {
          bytes = result.files.first.bytes;
        });
      } else {
        final file = File(result.files.single.path!);
        if (await file.exists()) {
          final byte = file.readAsBytesSync();
          setState(() {
            bytes = byte;
          });
        } else {
          throw Exception("File not exist");
        }
      }
    } else {
      return null;
    }
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
                            onPressed: pickFile,
                            child: Text('Pick model File'),
                          ),
                          CustomButton(
                              onPressed: () async {
                                await loadModel();
                              },
                              text: "Load Model"),
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
