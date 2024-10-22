import 'package:ai_model_land/models/core/base_model.dart';
import 'package:ai_model_land/models/core/task_request_model.dart';
import 'package:ai_model_land/models/providers/onnx/onnx_request_model.dart';
import 'package:ai_model_land_example/services/services.dart';
import 'package:ai_model_land_example/shared_widgets/custom_app_bar.dart';
import 'package:ai_model_land_example/shared_widgets/custom_button.dart';
import 'package:ai_model_land_example/thems/thems.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class LLMPage extends StatefulWidget {
  const LLMPage({super.key});

  @override
  State<LLMPage> createState() => _LLMPageState();
}

class _LLMPageState extends State<LLMPage> {
  final GlobalVM _aiModelLand = Modular.get(key: 'GlobalVM');

  BaseModel baseModel = BaseModel(
      source:
          "https://huggingface.co/onnx-community/Llama-3.2-1B-Instruct-q4f16/resolve/main/onnx/model_q4f16.onnx",
      nameFile: "photo-detection-classification",
      format: ModelFormat.onnx,
      sourceType: ModelSourceType.local);

  Future<bool> loadModel() async {
    return await _aiModelLand.loadModel(
        request: OnnxRequestModel(
          loadModelWay: LoadModelWay.fromURL,
          onnxBackend: ONNXBackend.cpu,
        ),
        baseModel: baseModel);
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
                  CustomButton(
                      onPressed: () async {
                        await loadModel();
                      },
                      text: "Load model"),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
