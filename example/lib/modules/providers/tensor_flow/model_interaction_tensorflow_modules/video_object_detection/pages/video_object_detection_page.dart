import 'package:ai_model_land/models/core/base_model.dart';
import 'package:ai_model_land/models/core/task_request_model.dart';
import 'package:ai_model_land/models/providers/tensor_flow/tensorflow_request_model.dart';
import 'package:ai_model_land_example/services/services.dart';
import 'package:ai_model_land_example/shared_widgets/custom_app_bar.dart';
import 'package:ai_model_land_example/shared_widgets/custom_button.dart';
import 'package:ai_model_land_example/thems/thems.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class TFVideoObjectDetectionPage extends StatefulWidget {
  const TFVideoObjectDetectionPage({super.key});

  @override
  State<TFVideoObjectDetectionPage> createState() =>
      TF_VideoObjectDetectionPageState();
}

class TF_VideoObjectDetectionPageState
    extends State<TFVideoObjectDetectionPage> {
  final GlobalVM _aiModelLand = Modular.get(key: 'GlobalVM');
  Future<bool>? isLoad;
  bool? isModelLoaded;
  Future<bool>? restartStop;

  BaseModel baseModel = BaseModel(
      source:
          "assets/tensorflowlite/live_object_detection/ssd_mobilenet.tflite",
      nameFile: "photo-detection-classification",
      format: ModelFormat.tflite,
      sourceType: ModelSourceType.local);

  //assets/tensorflowlite/live_object_detection/labelmap.txt

  void checkModelLoadedStop({required BaseModel baseModel}) async {
    final modelUpload = await _aiModelLand.isModelLoaded(baseModel: baseModel);
    if (modelUpload) {
      stopModel(baseModel: baseModel);
    }
  }

  Future<bool> loadModel({required BaseModel baseModel}) async {
    return await _aiModelLand.loadModel(
        request: TensorFlowRequestModel(loadModelWay: LoadModelWay.fromAssets),
        baseModel: baseModel);
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

  @override
  void dispose() {
    checkModelLoadedStop(baseModel: baseModel);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        text: "TensorFlowLite Model Video",
      ),
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
                    "TensorFlowLite Model Video",
                    style: Thems.textStyle,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6),
                      Text(
                        "This model in live format can detect and classify objects.",
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "The next step is open live object detection camera and give permission for camera if that needs",
                        style: Thems.textStyle,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  isModelLoaded == true
                      ? CustomButton(
                          onPressed: () {
                            Modular.to.pushNamed(
                                '//home/tensorFlow/video-object-detection/video-page',
                                arguments: {
                                  "baseModel": baseModel,
                                  "labels":
                                      "assets/tensorflowlite/live_object_detection/labelmap.txt"
                                });
                          },
                          text: "Run Live Object Detection")
                      : Container(
                          child: Text(
                            "Load the model",
                            style: Thems.textStyle,
                          ),
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
