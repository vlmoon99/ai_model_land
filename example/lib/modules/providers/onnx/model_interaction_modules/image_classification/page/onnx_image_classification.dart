import 'dart:typed_data';

import 'package:ai_model_land/models/core/base_model.dart';
import 'package:ai_model_land/models/core/task_request_model.dart';
import 'package:ai_model_land/models/providers/onnx/onnx_request_model.dart';
import 'package:ai_model_land_example/services/services.dart';
import 'package:ai_model_land_example/shared_widgets/custom_app_bar.dart';
import 'package:ai_model_land_example/shared_widgets/custom_button.dart';
import 'package:ai_model_land_example/thems/thems.dart';
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

  BaseModel baseModel = BaseModel(
      source: "assets/onnx/image_classification/mobilenetv2-7.onnx",
      nameFile: "photo-detection-classification",
      format: ModelFormat.onnx,
      sourceType: ModelSourceType.local);

  Future<bool> loadModel({required BaseModel baseModel}) async {
    ByteData byteData = await rootBundle.load(baseModel.source);
    Uint8List modelBuffer = byteData.buffer.asUint8List();

    return await _aiModelLand.loadModel(
        request: OnnxRequestModel(
          loadModelWay: LoadModelWay.fromBuffer,
          uint8list: modelBuffer,
        ),
        baseModel: baseModel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: "ONNX TEST"),
      backgroundColor: Thems.mainBackgroundColor,
      body: Container(
        padding: EdgeInsets.all(6),
        child: Column(
          children: [
            Flexible(
                child: SingleChildScrollView(
              child: Column(
                children: [
                  Align(
                      alignment: Alignment.center,
                      child: CustomButton(
                          onPressed: () {
                            loadModel(baseModel: baseModel);
                          },
                          text: "Load Model")),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
