import 'package:ai_model_land/models/core/base_model.dart';
import 'package:ai_model_land/models/core/task_request_model.dart';
import 'package:ai_model_land/models/core/task_response_model.dart';
import 'package:ai_model_land/models/providers/transformers/transformers_request_model.dart';
import 'package:ai_model_land/models/providers/transformers/transformers_respons_model.dart';
import 'package:ai_model_land_example/services/services.dart';
import 'package:ai_model_land_example/shared_widgets/custom_app_bar.dart';
import 'package:ai_model_land_example/shared_widgets/custom_button.dart';
import 'package:ai_model_land_example/thems/thems.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class TRPhiPage extends StatefulWidget {
  const TRPhiPage({super.key});

  @override
  State<TRPhiPage> createState() => _TRPhiPageState();
}

class _TRPhiPageState extends State<TRPhiPage> {
  final GlobalVM _aiModelLand = Modular.get(key: 'GlobalVM');

  Future<bool>? isLoad;
  bool? isModelLoaded;
  bool? isRunModel;
  TransformersBackend? back;
  Future<bool>? restartStop;
  Future<String>? resp;

  final TextEditingController controller = TextEditingController();

  List<Map<String, String>> messages = [
    {'role': "\'system\'", 'content': "\'You are a helpful assistant.\'"},
  ];

  Future<String> sendMessage() async {
    if (controller.text.isNotEmpty) {
      setState(() {
        messages.add({'role': "\'user\'", 'content': "\'${controller.text}\'"});
        isRunModel = true;
      });
      controller.clear();
      final newMessage = await runModel() as TransformersResponsModel;
      final preLoad = newMessage.response as List<dynamic>;
      final resp = preLoad[0];
      final ret = resp.toString();
      return ret;
    } else {
      return "Enter value";
    }
  }

  BaseModel baseModel = BaseModel(
      source: 'onnx-community/Phi-3.5-mini-instruct-onnx-web',
      nameFile: "test",
      format: ModelFormat.transformers,
      sourceType: ModelSourceType.local);

  Future<bool> loadModel({required TransformersBackend beckend}) async {
    return await _aiModelLand.loadModel(
        request: TransformersRequestModel(
            use_external_data_format: true,
            dtype: "q4f16",
            loadModelWay: LoadModelWay.fromID,
            typeLoadModel: TypeLoadModel.text_generation,
            typeModel: 'text-generation',
            backendDevice: beckend),
        baseModel: baseModel);
  }

  Future<TaskResponseModel> runModel() async {
    return await _aiModelLand.runTaskOnTheModel(
        request: TransformersRequestModel(
            useChatTemplate: true,
            tokenizerChatOptions: {
              "add_generation_prompt": "true",
              "return_dict": "true"
            },
            data: messages,
            optionsForGnerator: {"max_new_tokens": 128}),
        baseModel: baseModel);
  }

  Future<bool> stopModel() async {
    return await _aiModelLand.stopModel(baseModel: baseModel);
  }

  Future<bool> restartModel({required TransformersBackend backend}) async {
    return await _aiModelLand.restartModel(
        request: TransformersRequestModel(
            loadModelWay: LoadModelWay.fromID,
            typeLoadModel: TypeLoadModel.standard,
            typeModel: 'text-generation',
            backendDevice: backend),
        baseModel: baseModel);
  }

  void checkModelLoadedStop({required BaseModel baseModel}) async {
    final modelUpload = await _aiModelLand.isModelLoaded(baseModel: baseModel);
    if (modelUpload) {
      stopModel();
    }
  }

  void dispose() {
    checkModelLoadedStop(baseModel: baseModel);
    super.dispose();
  }

  Future<bool> _showRunModelDialog({required BuildContext context}) async {
    TransformersBackend? selectedModelType = TransformersBackend.wasm;

    final supportBackend = await _aiModelLand.webBackendSupport();
    List<String> support = supportBackend.entries
        .where((entris) => entris.value == true)
        .map((entris) => entris.key)
        .toList();

    final filteredModelTypes = TransformersBackend.values
        .where((type) => support.contains(type.toString().split(".").last))
        .toList();

    filteredModelTypes.addAll([TransformersBackend.wasm]);

    final TransformersBackend? backendForONNX =
        await showDialog<TransformersBackend>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Confirm load model'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select a backend for onnx:'),
                  DropdownButton<TransformersBackend>(
                    value: selectedModelType,
                    items: filteredModelTypes.map((TransformersBackend type) {
                      return DropdownMenuItem<TransformersBackend>(
                        value: type,
                        child: Text(type.name),
                      );
                    }).toList(),
                    onChanged: (TransformersBackend? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedModelType = newValue;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                CustomButton(
                    onPressed: () {
                      Navigator.of(context).pop(selectedModelType);
                    },
                    text: "Load model"),
              ],
            );
          },
        );
      },
    );

    if (backendForONNX != null) {
      setState(() {
        back = backendForONNX;
      });
      final load = await loadModel(beckend: backendForONNX);
      return load;
    } else {
      throw Exception("What went wrong, try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: "Transformers Phi Model"),
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
                        "Transformers Phi Model",
                        style: Thems.textStyle,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "This is text-generation model. It is support only wasm and webgpu",
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
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          CustomButton(
                              onPressed: () async {
                                setState(() {
                                  isLoad =
                                      _showRunModelDialog(context: context);
                                });
                                final res = await isLoad;
                                setState(() {
                                  isModelLoaded = res;
                                });
                              },
                              text: "Load Model"),
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
                                          Text(
                                              "Loading the model can take a long time")
                                        ],
                                      );
                                    } else if (snapshot.hasError) {
                                      return SelectableText(
                                          'Error: ${snapshot.error}');
                                    } else if (snapshot.data == true) {
                                      return Text("Result: model was loaded",
                                          style: Thems.textStyle
                                              .copyWith(fontSize: 15));
                                    } else {
                                      return Text("Result: try add again",
                                          style: Thems.textStyle
                                              .copyWith(fontSize: 15));
                                    }
                                  },
                                ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "After that you can use model",
                      style: Thems.textStyle,
                    ),
                    SizedBox(height: 8),
                    isModelLoaded != true
                        ? Container(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Load the model",
                                style: Thems.textStyle,
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 5),
                            child: Column(
                              children: [
                                TextField(
                                  controller: controller,
                                  decoration: const InputDecoration(
                                      labelText: 'Input text'),
                                ),
                                SizedBox(height: 10),
                                CustomButton(
                                    onPressed: () {
                                      setState(() {
                                        resp = sendMessage();
                                      });
                                    },
                                    text: "Run model"),
                                resp == null
                                    ? Container(
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            "No response",
                                            style: Thems.textStyle,
                                          ),
                                        ),
                                      )
                                    : FutureBuilder(
                                        future: resp,
                                        builder: (BuildContext context,
                                            AsyncSnapshot<String> snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Column(
                                              children: [
                                                CircularProgressIndicator(),
                                                Text(
                                                    "Runing the model can take a long time")
                                              ],
                                            );
                                          } else if (snapshot.hasError) {
                                            return SelectableText(
                                                'Error: ${snapshot.error}');
                                          } else if (snapshot
                                              .data!.isNotEmpty) {
                                            return Text(
                                                "Result:${snapshot.data}",
                                                style: Thems.textStyle
                                                    .copyWith(fontSize: 15));
                                          } else {
                                            return Text("Result: try run again",
                                                style: Thems.textStyle
                                                    .copyWith(fontSize: 15));
                                          }
                                        },
                                      ),
                              ],
                            ),
                          ),
                    SizedBox(height: 10),
                    Text(
                      "The second step is to load the image, choose image and run the model.",
                      style: Thems.textStyle,
                    ),
                    SizedBox(height: 10),
                    isModelLoaded != true
                        ? Container(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Load the model",
                                style: Thems.textStyle,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: FilledButton(
                                  onPressed: () {
                                    setState(() {
                                      back = null;
                                      restartStop = stopModel();
                                    });
                                    isModelLoaded = false;
                                  },
                                  style: Thems.buttonStyle,
                                  child: Text(
                                    'Stop Model',
                                    style: Thems.textStyle,
                                  ),
                                ),
                              ),
                              Spacer(),
                              Flexible(
                                child: FilledButton(
                                  onPressed: () {
                                    if (back != null) {
                                      setState(() {
                                        restartStop =
                                            restartModel(backend: back!);
                                      });
                                    }
                                  },
                                  style: Thems.buttonStyle,
                                  child: Text(
                                    'Restart Model',
                                    style: Thems.textStyle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                    Align(
                      alignment: Alignment.center,
                      child: restartStop == null
                          ? Container()
                          : FutureBuilder(
                              future: restartStop,
                              builder: (BuildContext context,
                                  AsyncSnapshot<bool> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return SelectableText(
                                      'Error: ${snapshot.error}');
                                } else if (snapshot.data == true) {
                                  return Text("Result: success",
                                      style: Thems.textStyle
                                          .copyWith(fontSize: 15));
                                } else {
                                  return Text("Result: try again",
                                      style: Thems.textStyle
                                          .copyWith(fontSize: 15));
                                }
                              },
                            ),
                    ),
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
