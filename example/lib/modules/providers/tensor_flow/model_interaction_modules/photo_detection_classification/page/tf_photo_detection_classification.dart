import 'dart:async';
import 'dart:io';

import 'package:ai_model_land/models/core/base_model.dart';
import 'package:ai_model_land/models/core/task_request_model.dart';
import 'package:ai_model_land/models/providers/tensor_flow/tensorflow_request_model.dart';
import 'package:ai_model_land/models/providers/tensor_flow/tensorflow_respons_model.dart';
import 'package:ai_model_land_example/services/services.dart';
import 'package:ai_model_land_example/shared_widgets/custom_app_bar.dart';
import 'package:ai_model_land_example/shared_widgets/custom_button.dart';
import 'package:ai_model_land_example/thems/thems.dart';
import 'package:ai_model_land_example/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_modular/flutter_modular.dart';

class TfPhotoDetectionClassification extends StatefulWidget {
  const TfPhotoDetectionClassification({super.key});

  @override
  State<TfPhotoDetectionClassification> createState() =>
      _TfPhotoDetectionClassificationState();
}

class _TfPhotoDetectionClassificationState
    extends State<TfPhotoDetectionClassification> {
  final GlobalVM _aiModelLand = Modular.get(key: 'GlobalVM');
  final UtilsClass preprocesingclass = Modular.get<UtilsClass>();
  final thresholdController = TextEditingController();

  Future<bool>? isLoad;
  bool? isModelLoaded;
  Future<bool>? restartStop;
  Object? inputObject;
  Future<TensorFlowResponseModel>? predict;

  BaseModel baseModel = BaseModel(
      source:
          "assets/tensorflowlite/image_classification/mobilenet_v1_1.0_224.tflite",
      nameFile: "photo-detection-classification",
      format: ModelFormat.tflite,
      sourceType: ModelSourceType.local);

  Future<bool> loadModel({required BaseModel baseModel}) async {
    return await _aiModelLand.loadModel(
        request: TensorFlowRequestModel(loadModelWay: LoadModelWay.fromAssets),
        baseModel: baseModel);
  }

  bool checkModelLoaded({required BaseModel baseModel}) {
    return _aiModelLand.isModelLoaded(baseModel: baseModel);
  }

  Future<bool> restartModel({required BaseModel baseModel}) async {
    await _aiModelLand.restartModel(
        baseModel: baseModel,
        request: TensorFlowRequestModel(loadModelWay: LoadModelWay.fromAssets));
    return true;
  }

  Future<bool> stopModel({required BaseModel baseModel}) async {
    await _aiModelLand.stopModel(baseModel: baseModel);
    return true;
  }

  Future<TensorFlowResponseModel> runModel(
      {required BaseModel baseModel,
      required Object inputObject,
      required bool async,
      required String lables,
      required double threshold}) async {
    final lablesData = await rootBundle.loadString(lables);
    List<String> lines = lablesData
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final output = await _aiModelLand.runTaskOnTheModel(
        request: TensorFlowRequestModel(
            data: inputObject,
            async: async,
            labelsList: lines,
            threshold: threshold),
        baseModel: baseModel);

    return output as TensorFlowResponseModel;
  }

  Future<String?> pickFileIMG() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final listBity = await File(result.files.single.path!).readAsBytes();
      img.Image image = img.decodeImage(listBity)!;
      img.Image resizedImage = img.copyResize(image, width: 224, height: 224);
      final Uint8List photoConvert = preprocesingclass.imageToByteListFloat32(
          resizedImage, 224, [127.5, 127.5, 127.5], [127.5, 127.5, 127.5]);
      setState(() {
        inputObject = photoConvert;
      });
    } else {
      return null;
    }
  }

  Future<TensorFlowResponseModel> _showRunModelDialog(
      {required BuildContext context,
      required double threshold,
      required Object image,
      required BaseModel baseModel}) async {
    final bool? async = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm run model'),
          content: const Text('Do you want to run this model in async way?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (async != null) {
      return await runModel(
          baseModel: baseModel,
          inputObject: image,
          threshold: threshold,
          async: async,
          lables:
              "assets/tensorflowlite/image_classification/mobilenet_v1_1.0_224.txt");
    } else {
      throw Exception("What went wrong, try again.");
    }
  }

  @override
  void initState() {
    thresholdController.text = "0.01";
    super.initState();
  }

  @override
  void dispose() {
    final modelUpload = checkModelLoaded(baseModel: baseModel);
    if (modelUpload) {
      stopModel(baseModel: baseModel);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: "TensorFlowLite Model Photo"),
      backgroundColor: Thems.mainBackgroundColor,
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Flexible(
                child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "TensorFlowLite Model Photo",
                    style: Thems.textStyle,
                  ),
                  SizedBox(height: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "This model can identify what is depicted in a picture.",
                        style: Thems.textStyle,
                      ),
                      Text(
                        "For interaction:",
                        style: Thems.textStyle,
                      ),
                      Text(
                        "The first step, is to upload the model to the provider",
                        style: Thems.textStyle,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  CustomButton(
                      onPressed: () async {
                        setState(() {
                          isLoad = loadModel(baseModel: baseModel);
                        });
                        final res = await isLoad;
                        setState(() {
                          isModelLoaded = res;
                        });
                      },
                      text: "Load Model"),
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
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return SelectableText('Error: ${snapshot.error}');
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
                  SizedBox(height: 10),
                  Text(
                    "The second step is to load the image, choose how accurately the predictor will be displayed and run the model",
                    style: Thems.textStyle,
                  ),
                  SizedBox(height: 10),
                  isModelLoaded != true
                      ? Container(
                          child: Text(
                            "Load the model",
                            style: Thems.textStyle,
                          ),
                        )
                      : Column(
                          children: [
                            TextField(
                              controller: thresholdController,
                              decoration: const InputDecoration(
                                  labelText: 'Input threshold(default 0.01)'),
                            ),
                            SizedBox(height: 10),
                            CustomButton(
                                onPressed: () {
                                  pickFileIMG();
                                },
                                text: "Pick image"),
                            inputObject == null
                                ? Text(
                                    "Image not add",
                                    style:
                                        Thems.textStyle.copyWith(fontSize: 15),
                                  )
                                : Text("Image was add",
                                    style:
                                        Thems.textStyle.copyWith(fontSize: 15)),
                            SizedBox(height: 10),
                            inputObject == null
                                ? Container(
                                    child: Text(
                                      "Load the image",
                                      style: Thems.textStyle,
                                    ),
                                  )
                                : CustomButton(
                                    onPressed: () {
                                      if (thresholdController.text.isNotEmpty &&
                                          inputObject != null) {
                                        setState(() {
                                          predict = _showRunModelDialog(
                                              context: context,
                                              threshold: double.parse(
                                                  thresholdController.text),
                                              image: inputObject!,
                                              baseModel: baseModel);
                                        });
                                      }
                                    },
                                    text: "Run model"),
                            SizedBox(height: 10),
                            predict == null
                                ? Text("Result: the model has not been started",
                                    style:
                                        Thems.textStyle.copyWith(fontSize: 15))
                                : FutureBuilder(
                                    future: predict,
                                    builder: (BuildContext context,
                                        AsyncSnapshot<TensorFlowResponseModel>
                                            snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        return SelectableText(
                                            'Error: ${snapshot.error}',
                                            style: Thems.textStyle
                                                .copyWith(fontSize: 15));
                                      } else if (snapshot.data != null &&
                                          snapshot.data!
                                                  .predictForSingleLasbles !=
                                              null) {
                                        Map<String, double> predictions =
                                            snapshot
                                                .data!.predictForSingleLasbles!;

                                        List<Widget> predictsText =
                                            predictions.entries.map((entris) {
                                          return Text(
                                            "${entris.key}: ${entris.value.toStringAsFixed(4)}",
                                            style: Thems.textStyle,
                                            softWrap: true,
                                            maxLines: null,
                                          );
                                        }).toList();

                                        return Column(
                                          children: predictsText,
                                        );
                                      } else {
                                        return Text("Result: try run again",
                                            style: Thems.textStyle
                                                .copyWith(fontSize: 15));
                                      }
                                    },
                                  ),
                          ],
                        ),
                  SizedBox(height: 10),
                  Text(
                    "Also we can stop or restart model if this needs",
                    style: Thems.textStyle,
                  ),
                  isModelLoaded == true
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomButton(
                                onPressed: () {
                                  setState(() {
                                    restartStop =
                                        restartModel(baseModel: baseModel);
                                  });
                                },
                                text: "Restart model"),
                            SizedBox(width: 12),
                            CustomButton(
                                onPressed: () {
                                  setState(() {
                                    restartStop =
                                        stopModel(baseModel: baseModel);
                                    isModelLoaded = false;
                                  });
                                },
                                text: "Stop model"),
                          ],
                        )
                      : Container(
                          child: Text(
                            "Load the model",
                            style: Thems.textStyle,
                          ),
                        ),
                  restartStop == null
                      ? Container()
                      : FutureBuilder(
                          future: restartStop,
                          builder: (BuildContext context,
                              AsyncSnapshot<bool> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return SelectableText('Error: ${snapshot.error}');
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
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
