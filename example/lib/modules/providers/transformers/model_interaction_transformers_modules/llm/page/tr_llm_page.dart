import 'package:ai_model_land/models/core/base_model.dart';
import 'package:ai_model_land/models/core/task_request_model.dart';
import 'package:ai_model_land/models/core/task_response_model.dart';
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

  Future<bool>? isLoad;
  bool? isModelLoaded;

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

  Future<TaskResponseModel> runModel() async {
    return await _aiModelLand.runTaskOnTheModel(
        request: TransformersRequestModel(data: [
          {'role': "\'system\'", 'content': "\'You are a helpful assistant.\'"},
          {'role': "\'user\'", 'content': "\'What is the capital of France?\'"},
        ], optionsForGnerator: {
          "max_new_tokens": 128
        }),
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
                    SizedBox(height: 10),
                    Text(
                      "This is text-generation model",
                      style: Thems.textStyle,
                    ),
                    Text(
                      "For interaction:",
                      style: Thems.textStyle,
                    ),
                    Text(
                      "The first step, is to upload the model to the provider.",
                      style: Thems.textStyle,
                    ),
                    SizedBox(height: 8),
                    CustomButton(
                        onPressed: () async {
                          setState(() {
                            isLoad = loadModel();
                          });
                          final res = await isLoad;
                          setState(() {
                            isModelLoaded = res;
                          });
                        },
                        text: "Load Model"),
                    SizedBox(
                      height: 10,
                    ),
                    CustomButton(
                        onPressed: () async {
                          await runModel();
                        },
                        text: "Run Model"),
                    isLoad == null
                        ? Text("Result: model not load",
                            style: Thems.textStyle.copyWith(fontSize: 15))
                        : FutureBuilder(
                            future: isLoad,
                            builder: (BuildContext context,
                                AsyncSnapshot<bool> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Column(
                                  children: [
                                    CircularProgressIndicator(),
                                    Text("Loading a model can take a long time")
                                  ],
                                );
                              } else if (snapshot.hasError) {
                                return SelectableText(
                                    'Error: ${snapshot.error}');
                              } else if (snapshot.data == true) {
                                return Text("Result: model was loaded",
                                    style:
                                        Thems.textStyle.copyWith(fontSize: 15));
                              } else {
                                return Text("Result: try add again",
                                    style:
                                        Thems.textStyle.copyWith(fontSize: 15));
                              }
                            },
                          ),
                    SizedBox(height: 8),
                    Text(
                      "After that you can use model",
                      style: Thems.textStyle,
                    ),
                    SizedBox(height: 8),
                    // isModelLoaded != true
                    //     ? Container(
                    //         child: Align(
                    //           alignment: Alignment.center,
                    //           child: Text(
                    //             "Load the model",
                    //             style: Thems.textStyle,
                    //           ),
                    //         ),
                    //       )
                    //     :
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
