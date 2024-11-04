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

class TRLLMPage extends StatefulWidget {
  const TRLLMPage({super.key});

  @override
  State<TRLLMPage> createState() => _TRLLMPageState();
}

class _TRLLMPageState extends State<TRLLMPage> {
  final GlobalVM _aiModelLand = Modular.get(key: 'GlobalVM');

  Future<bool>? isLoad;
  bool? isModelLoaded;
  bool? isRunModel;
  TransformersBackend? back;
  Future<bool>? restartStop;

  final TextEditingController controller = TextEditingController();

  List<Map<String, String>> messages = [
    {'role': "\'system\'", 'content': "\'You are a helpful assistant.\'"},
  ];

  void sendMessage() async {
    if (controller.text.isNotEmpty) {
      setState(() {
        messages.add({'role': "\'user\'", 'content': "\'${controller.text}\'"});
        isRunModel = true;
      });
      controller.clear();
      final newMessage = await runModel() as TransformersResponsModel;
      final preLoad = newMessage.response as List<dynamic>;
      final resp = preLoad[0] as Map<String, dynamic>;
      final oneMore = resp["generated_text"] as List<dynamic>;
      final finalData = oneMore.last as Map<String, dynamic>;
      Map<String, String> stringMap =
          finalData.map((key, value) => MapEntry(key, value.toString()));
      final content = stringMap["content"];
      setState(() {
        messages.add({'role': "\'assistant\'", 'content': "\'${content}\'"});
        isRunModel = false;
      });
    }
  }

  BaseModel baseModel = BaseModel(
      source: 'onnx-community/Llama-3.2-1B-Instruct-q4f16',
      nameFile: "test",
      format: ModelFormat.transformers,
      sourceType: ModelSourceType.local);

  Future<bool> loadModel({required TransformersBackend beckend}) async {
    return await _aiModelLand.loadModel(
        request: TransformersRequestModel(
            loadModelWay: LoadModelWay.fromID,
            typeLoadModel: TypeLoadModel.standard,
            typeModel: 'text-generation',
            backendDevice: beckend),
        baseModel: baseModel);
  }

  Future<TaskResponseModel> runModel() async {
    return await _aiModelLand.runTaskOnTheModel(
        request: TransformersRequestModel(
            data: messages, optionsForGnerator: {"max_new_tokens": 128}),
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
                                              "Loading a model can take a long time")
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
                        : Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width < 1000
                                  ? MediaQuery.of(context).size.width * 0.8
                                  : MediaQuery.of(context).size.width * 0.6,
                              height: MediaQuery.of(context).size.height * 0.6,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(height: 10),
                                  Expanded(
                                    child: isRunModel != true
                                        ? ListView.builder(
                                            itemCount: messages.length,
                                            itemBuilder: (context, index) {
                                              final message = messages[index];
                                              final isUser =
                                                  message['role'] == "\'user\'";
                                              final isAssistant =
                                                  message['role'] ==
                                                      'assistant';

                                              if (message['role'] ==
                                                  "\'system\'") {
                                                return SizedBox.shrink();
                                              }

                                              return Align(
                                                alignment: isUser
                                                    ? Alignment.centerRight
                                                    : Alignment.centerLeft,
                                                child: Container(
                                                  margin: EdgeInsets.symmetric(
                                                      vertical: 5,
                                                      horizontal: 10),
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: isUser
                                                        ? Colors.blueAccent
                                                        : Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Text(
                                                    message['content'] ?? '',
                                                    style: TextStyle(
                                                      color: isUser
                                                          ? Colors.white
                                                          : Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        : Column(
                                            children: [
                                              CircularProgressIndicator(),
                                              Text("Model run")
                                            ],
                                          ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: controller,
                                            decoration: InputDecoration(
                                              hintText: 'Type a message...',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        IconButton(
                                          icon: Icon(Icons.send,
                                              color: Colors.blueAccent),
                                          onPressed: sendMessage,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    SizedBox(height: 10),
                    Text(
                      "Also we can stop or restart model if this needs",
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
