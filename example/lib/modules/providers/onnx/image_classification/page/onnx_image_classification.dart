import 'dart:io';
import 'dart:typed_data';

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

class OnnxImageClassification extends StatefulWidget {
  const OnnxImageClassification({super.key});

  @override
  State<OnnxImageClassification> createState() =>
      _OnnxImageClassificationState();
}

class _OnnxImageClassificationState extends State<OnnxImageClassification> {
  final GlobalVM _aiModelLand = Modular.get(key: 'GlobalVM');
  final UtilsClass preprocesingclass = Modular.get<UtilsClass>();
  Float32List? inputBytes;
  Future<bool>? isLoad;
  bool? isModelLoaded;
  Future<bool>? restartStop;
  Future<List<String>>? predict;
  ONNXBackend? backendONNX;
  final ValueNotifier<double> percentNotifier = ValueNotifier<double>(0.0);

  BaseModel baseModel = BaseModel(
      source: "assets/onnx/image_classification/mobilenetv2-7.onnx",
      nameFile: "photo-detection-classification",
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

  Future<List<String>> runModel({required Float32List inputBytes}) async {
    List<String> lines = await preprocesingclass.convertFileToList(
        assetsPath: 'assets/onnx/image_classification/classes.txt');
    OnnxResponsModel predict = await _aiModelLand.runTaskOnTheModel(
        request: OnnxRequestModel(dataMulti: [
          inputBytes
        ], shape: [
          [1, 3, 224, 224]
        ], threshold: 3, topPredictEntries: 5),
        baseModel: baseModel) as OnnxResponsModel;
    final convertPredict = predict.predict!.first.entries
        .map((entry) =>
            "${lines[int.parse(entry.key)]} - ${(entry.value as double).toStringAsFixed(2)}")
        .toList();
    return convertPredict;
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
          final Float32List photoConvert = preprocesingclass.preprocesstest(
              resizedImage.getBytes(), 224, 224);
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
        .where((entris) => entris.value == false)
        .map((entris) => entris.key)
        .toList();

    final filteredModelTypes = ONNXBackend.values
        .where((type) => !support.contains(type.toString().split(".").last))
        .toList();

    final ONNXBackend? backendForONNX = await showDialog<ONNXBackend>(
      context: context,
      builder: (BuildContext context) {
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
                    selectedModelType = newValue;
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

  Future<bool> stopModel() async {
    await _aiModelLand.stopModel(baseModel: baseModel);
    return Future.value(true);
  }

  Future<bool> restartModel({required ONNXBackend backendONNX}) async {
    await _aiModelLand.restartModel(
        request: OnnxRequestModel(onnxBackend: backendONNX),
        baseModel: baseModel);
    return Future.value(true);
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "ONNX Model Image",
                      style: Thems.textStyle,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "This model can identify what is depicted in a picture.",
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
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        FilledButton(
                            onPressed: () async {
                              setState(() {
                                isLoad = _showRunModelDialog(context: context);
                              });
                              final res = await isLoad;
                              setState(() {
                                isModelLoaded = res;
                              });
                            },
                            style: Thems.buttonStyle,
                            child: Text(
                              "Load Model",
                              style: Thems.textStyle,
                            )),
                        SizedBox(width: 10),
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
                      : Align(
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              FilledButton(
                                onPressed: pickFileIMG,
                                style: Thems.buttonStyle,
                                child: Text(
                                  'Pick image File',
                                  style: Thems.textStyle,
                                ),
                              ),
                              inputBytes == null
                                  ? Text(
                                      "Image not add",
                                      style: Thems.textStyle
                                          .copyWith(fontSize: 15),
                                    )
                                  : Text("Image was add",
                                      style: Thems.textStyle
                                          .copyWith(fontSize: 15)),
                              SizedBox(height: 10),
                              FilledButton(
                                  onPressed: () {
                                    if (inputBytes != null) {
                                      setState(() {
                                        predict =
                                            runModel(inputBytes: inputBytes!);
                                      });
                                    }
                                  },
                                  style: Thems.buttonStyle,
                                  child: Text(
                                    "Run model",
                                    style: Thems.textStyle,
                                  )),
                              predict == null
                                  ? Align(
                                      alignment: Alignment.center,
                                      child: Text("No predictions"))
                                  : FutureBuilder(
                                      future: predict,
                                      builder: (BuildContext context,
                                          AsyncSnapshot<List<String>>
                                              snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return SelectableText(
                                              'Error: ${snapshot.error}');
                                        } else if (snapshot.data!.isNotEmpty) {
                                          List<Widget> listWidgetText =
                                              snapshot.data!.map((predict) {
                                            return Text(
                                              predict,
                                              style: Thems.textStyle,
                                            );
                                          }).toList();
                                          return Align(
                                            alignment: Alignment.center,
                                            child: Column(
                                              children: listWidgetText,
                                            ),
                                          );
                                        } else {
                                          return Text(
                                              "Predict is absent or some gone wrong");
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
