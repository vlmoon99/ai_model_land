import 'dart:io';

import 'package:ai_model_land/models/core/base_model.dart';
import 'package:ai_model_land/models/core/task_request_model.dart';
import 'package:ai_model_land/models/providers/onnx/onnx_request_model.dart';
import 'package:ai_model_land/models/providers/onnx/onnx_respons_model.dart';
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

class GenderClassificationPage extends StatefulWidget {
  const GenderClassificationPage({super.key});

  @override
  State<GenderClassificationPage> createState() =>
      _GenderClassificationPageState();
}

class _GenderClassificationPageState extends State<GenderClassificationPage> {
  final GlobalVM _aiModelLand = Modular.get(key: 'GlobalVM');
  final UtilsClass preprocesingclass = Modular.get<UtilsClass>();

  Future<bool>? isLoad;
  bool? isModelLoaded;
  Float32List? inputBytes;
  Future<String>? predict;
  Future<bool>? restartStop;
  ONNXBackend? backendONNX;
  final ValueNotifier<double> percentNotifier = ValueNotifier<double>(0.0);

  BaseModel baseModel = BaseModel(
      source: "assets/onnx/gender_classification/gender_googlenet.onnx",
      nameFile: "gender-classification",
      format: ModelFormat.onnx,
      sourceType: ModelSourceType.local);

  Future<bool> loadModel({required ONNXBackend onnxBackendnx}) async {
    return await _aiModelLand.loadModel(
        request: OnnxRequestModel(
          loadModelWay: LoadModelWay.fromAssets,
          onnxBackend: onnxBackendnx,
          onProgressUpdate: (double newProgress) {
            setState(() {
              percentNotifier.value = newProgress;
            });
          },
        ),
        baseModel: baseModel);
  }

  Future<String> runModel({required Float32List inputBytes}) async {
    List<String> genderList = ['Male', 'Female'];
    OnnxResponsModel predict = await _aiModelLand.runTaskOnTheModel(
        request: OnnxRequestModel(dataMulti: [
          inputBytes
        ], shape: [
          [1, 3, 224, 224]
        ]),
        baseModel: baseModel) as OnnxResponsModel;
    String? maxKey;
    double maxValue = 0;
    predict.predict![0].forEach((key, value) {
      if (value > maxValue) {
        maxValue = value;
        maxKey = key;
      }
    });
    return genderList[int.parse(maxKey!)];
  }

  Future<String?> pickFileIMG() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      if (kIsWeb == true) {
        final bytes = result.files.first.bytes;
        if (bytes != null && bytes.isNotEmpty) {
          img.Image image = img.decodeImage(bytes)!;
          img.Image resizedImage =
              img.copyResize(image, width: 224, height: 224);
          final Float32List photoConvert = preprocesingclass.preprocesstest(
              resizedImage.getBytes(), 224, 224);
          setState(() {
            inputBytes = photoConvert;
          });
        } else {
          throw Exception("Bytes file not exist");
        }
      } else {
        final file = File(result.files.single.path!);
        if (await file.exists()) {
          final bytes = file.readAsBytesSync();
          img.Image image = img.decodeImage(bytes)!;
          img.Image resizedImage =
              img.copyResize(image, width: 224, height: 224);
          final Float32List photoConvert =
              preprocesingclass.preprocessGender(resizedImage);
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

  Future<bool> _showRunModelDialog({required BuildContext context}) async {
    ONNXBackend? selectedModelType = ONNXBackend.cpu;

    final supportBackend = await _aiModelLand.webBackendSupport();
    List<String> support = supportBackend.entries
        .where((entris) => entris.value == true)
        .map((entris) => entris.key)
        .toList();

    final filteredModelTypes = ONNXBackend.values
        .where((type) => support.contains(type.toString().split(".").last))
        .toList();

    filteredModelTypes.addAll([ONNXBackend.cpu, ONNXBackend.wasm]);

    final ONNXBackend? backendForONNX = await showDialog<ONNXBackend>(
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
                  DropdownButton<ONNXBackend>(
                    value: selectedModelType,
                    items: filteredModelTypes.map((ONNXBackend type) {
                      return DropdownMenuItem<ONNXBackend>(
                        value: type,
                        child: Text(type.name),
                      );
                    }).toList(),
                    onChanged: (ONNXBackend? newValue) {
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
        backendONNX = backendForONNX;
      });
      final load = await loadModel(onnxBackendnx: backendForONNX);
      return load;
    } else {
      throw Exception("What went wrong, try again.");
    }
  }

  Future<bool> restartModel({required ONNXBackend backendONNX}) async {
    return await _aiModelLand.restartModel(
        request: OnnxRequestModel(
            loadModelWay: LoadModelWay.fromAssets, onnxBackend: backendONNX),
        baseModel: baseModel);
  }

  Future<bool> stopModel() async {
    return await _aiModelLand.stopModel(baseModel: baseModel);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: "ONNX Gender Model"),
      backgroundColor: Thems.mainBackgroundColor,
      body: Container(
        padding: EdgeInsets.all(6),
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
                      "ONNX Model Gender Classification",
                      style: Thems.textStyle,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "This model can determine the gender of a person in a photo",
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
                                isLoad = _showRunModelDialog(context: context);
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
                                        ValueListenableBuilder<double>(
                                          valueListenable: percentNotifier,
                                          builder: (context, percent, _) {
                                            return Column(
                                              children: [
                                                Text(
                                                    'Progress: ${percent.toStringAsFixed(2)}%'),
                                              ],
                                            );
                                          },
                                        ),
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
                    "The second step is to load the image, choose image and run the model.",
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
                      : Align(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              CustomButton(
                                  onPressed: pickFileIMG,
                                  text: "Pick image File"),
                              inputBytes == null
                                  ? Text("Image not load")
                                  : Text("Image was load"),
                              SizedBox(height: 8),
                              CustomButton(
                                  onPressed: () {
                                    if (inputBytes != null) {
                                      setState(() {
                                        predict =
                                            runModel(inputBytes: inputBytes!);
                                      });
                                    }
                                  },
                                  text: "Run Model"),
                              predict == null
                                  ? Text("No interaction whit run method",
                                      style: Thems.textStyle
                                          .copyWith(fontSize: 15))
                                  : FutureBuilder(
                                      future: predict,
                                      builder: (BuildContext context,
                                          AsyncSnapshot<String> snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return SelectableText(
                                              'Error: ${snapshot.error}');
                                        } else {
                                          return Text(
                                            snapshot.data!,
                                            style: Thems.textStyle,
                                          );
                                        }
                                      },
                                    ),
                            ],
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
                                    backendONNX = null;
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
                                  if (backendONNX != null) {
                                    setState(() {
                                      restartStop = restartModel(
                                          backendONNX: backendONNX!);
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
                                    style:
                                        Thems.textStyle.copyWith(fontSize: 15));
                              } else {
                                return Text("Result: try again",
                                    style:
                                        Thems.textStyle.copyWith(fontSize: 15));
                              }
                            },
                          ),
                  ),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
