import 'package:ai_model_land/models/core/base_model.dart';
import 'package:ai_model_land/models/core/task_request_model.dart';
import 'package:ai_model_land/models/providers/transformers/transformers_request_model.dart';
import 'package:ai_model_land_example/services/services.dart';
import 'package:ai_model_land_example/shared_widgets/custom_app_bar.dart';
import 'package:ai_model_land_example/shared_widgets/custom_button.dart';
import 'package:ai_model_land_example/thems/thems.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class TRLLMPage extends StatefulWidget {
  const TRLLMPage({super.key});

  @override
  State<TRLLMPage> createState() => _TRLLMPageState();
}

class _TRLLMPageState extends State<TRLLMPage> {
  final GlobalVM _aiModelLand = Modular.get(key: 'GlobalVM');

  BaseModel baseModel = BaseModel(
      source: 'onnx-community/Llama-3.2-1B-Instruct-q4f16',
      nameFile: "test",
      format: ModelFormat.transformers,
      sourceType: ModelSourceType.local);

  Future<bool> loadModel() async {
    return await _aiModelLand.loadModel(
        request: TransformersRequestModel(
            loadModelWay: LoadModelWay.fromID,
            typeLoadModel: TypeLoadModel.standard,
            typeModel: 'text-generation',
            backendDevice: TransformersBackend.webgpu),
        baseModel: baseModel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: "Transformers LLM Model"),
      backgroundColor: Thems.mainBackgroundColor,
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Transformers LLM Model",
                        style: Thems.textStyle,
                      ),
                    ),
                    CustomButton(
                        onPressed: () async {
                          await loadModel();
                        },
                        text: "LLM"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
