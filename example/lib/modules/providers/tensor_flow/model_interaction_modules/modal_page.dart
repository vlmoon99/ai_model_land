import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:ai_model_land/models/providers/tensor_flow/tensorflow_respons_model.dart';
import 'package:ai_model_land_example/modules/providers/tensor_flow/model_interaction_modules/object_detection_page.dart';
import 'package:ai_model_land_example/services/services.dart';
import 'package:ai_model_land_example/utils/utils.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:image/image.dart' as img;
import 'package:ai_model_land/models/core/base_model.dart';
import 'package:ai_model_land/models/providers/tensor_flow/tensorflow_request_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ModelPage extends StatefulWidget {
  final BaseModel baseModel;
  const ModelPage({super.key, required this.baseModel});

  @override
  State<ModelPage> createState() => _ModelPageState();
}

class _ModelPageState extends State<ModelPage> {
  final GlobalVM _aiModelLand = Modular.get(key: 'GlobalVM');
  final UtilsClass preprocesingclass = UtilsClass();

  Uint8List? imgByteList;

  List<dynamic>? outputPredict;
  Object? inputObject;
  String? lables;
  bool? isDictionaryTextAdd;
  bool? isNeedThreshold;

  final textController = TextEditingController();
  var thresholdController = TextEditingController();
  Future<bool>? isAdd;

  Future<bool> loadModel({required BaseModel baseModel}) async {
    return await _aiModelLand.loadModel(
        request: TensorFlowRequestModel(loadModelWay: LoadModelWay.fromFile),
        baseModel: baseModel);
  }

  Future<void> deleteModel(
      {required BaseModel baseModel, required bool fromDevice}) async {
    await _aiModelLand.deleteModel(
        baseModel: baseModel, fromDevice: fromDevice);
  }

  Future<void> stopModel({required BaseModel baseModel}) async {
    await _aiModelLand.stopModel(baseModel: baseModel);
  }

  Future<void> runModel(
      {required BaseModel baseModel,
      required Object inputObject,
      required bool async}) async {
    late TensorFlowResponseModel output;
    if (lables != null) {
      output = await _aiModelLand.runTaskOnTheModel(
          request: TensorFlowRequestModel(
              data: inputObject,
              async: async,
              labelsFile: lables,
              threshold: double.tryParse(thresholdController.text)),
          baseModel: baseModel) as TensorFlowResponseModel;
    } else {
      output = await _aiModelLand.runTaskOnTheModel(
          request: TensorFlowRequestModel(data: inputObject, async: async),
          baseModel: baseModel) as TensorFlowResponseModel;
    }

    setState(() {
      outputPredict = output.predictForSingle;
    });
  }

  Future<String?> pickLables() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        lables = result.files.single.path!;
      });
    } else {
      return null;
    }
  }

  Future<String?> pickdictionary() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final List<List<double>> byteList =
          await preprocesingclass.tokenizeInputText(
              text: textController.text,
              vocab: result.files.single.path!,
              isFile: true);

      setState(() {
        inputObject = byteList;
        isDictionaryTextAdd = true;
      });
    } else {
      return null;
    }
  }

  Future<void> restartModel({required BaseModel baseModel}) async {
    await _aiModelLand.restartModel(
        baseModel: baseModel,
        request: TensorFlowRequestModel(loadModelWay: LoadModelWay.fromFile));
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content:
              const Text('Do you want to delete this model from the device?'),
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

    if (shouldDelete == true) {
      await deleteModel(baseModel: widget.baseModel, fromDevice: true);
    } else {
      await deleteModel(baseModel: widget.baseModel, fromDevice: false);
    }
  }

  Future<void> _showRunModelDialog(BuildContext context) async {
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

    if (async != null && inputObject != null) {
      await runModel(
          baseModel: widget.baseModel,
          inputObject: inputObject!,
          async: async!);
      ;
    }
  }

  Future<String?> pickFileIMG() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final listBity = await File(result.files.single.path!).readAsBytes();
      img.Image image = img.decodeImage(listBity)!;
      img.Image resizedImage = img.copyResize(image, width: 224, height: 224);
      final Uint8List last = preprocesingclass.imageToByteListFloat32(
          resizedImage, 224, 127.5, 127.5);
      setState(() {
        imgByteList = last;
        inputObject = last;
      });
    } else {
      return null;
    }
  }

  void resetAllInputs() {
    setState(() {
      imgByteList = null;
      inputObject = null;
      lables = null;
      textController.text = '';
      isDictionaryTextAdd = false;
      isNeedThreshold = false;
    });
  }

  @override
  void initState() {
    super.initState();
    thresholdController.text = '0.01';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interaction with ${widget.baseModel.nameFile}'),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isAdd = loadModel(baseModel: widget.baseModel);
                      });
                    },
                    child: Text('Load model to provider'),
                  ),
                  SizedBox(width: 10),
                  isAdd == null
                      ? Text("Result: model not load")
                      : FutureBuilder(
                          future: isAdd,
                          builder: (BuildContext context,
                              AsyncSnapshot<bool> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return SelectableText('Error: ${snapshot.error}');
                            } else if (snapshot.data == true) {
                              return Text("Result: model was loaded");
                            } else {
                              return Text("Result: try add again");
                            }
                          },
                        ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    stopModel(baseModel: widget.baseModel);
                    setState(() {
                      isAdd = Future.value(false);
                    });
                  },
                  child: Text('Stop model'),
                ),
                ElevatedButton(
                  onPressed: () {
                    stopModel(baseModel: widget.baseModel);
                  },
                  child: Text('Restart model '),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: pickFileIMG,
                  child: Text('Variably: Pick File (IMG)'),
                ),
                SizedBox(width: 10),
                imgByteList == null ? Text("IMG not add") : Text('IMG was add'),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    pickLables();
                    setState(() {
                      isNeedThreshold = true;
                    });
                  },
                  child: Text('Variably: Pick File (Lables)'),
                ),
                SizedBox(width: 10),
                lables == null
                    ? Text("Lables not add")
                    : Text('Lables was add'),
              ],
            ),
            isNeedThreshold == null || isNeedThreshold == false
                ? Container()
                : Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 50),
                    child: Center(
                      child: TextField(
                        controller: thresholdController,
                        decoration:
                            InputDecoration(labelText: 'Input for threshold'),
                      ),
                    ),
                  ),
            SizedBox(height: 9),
            Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color.fromARGB(255, 3, 69, 248),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Container(
                  child: Column(
                    children: [
                      TextField(
                        controller: textController,
                        decoration: InputDecoration(
                            labelText: 'Input for classifier text'),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: pickdictionary,
                        child: Text('Pick dictionary and save text'),
                      ),
                      isDictionaryTextAdd == true
                          ? Text('Dictionary and text save')
                          : Text('Dictionary and text not save'),
                    ],
                  ),
                )),
            SizedBox(height: 9),
            Text('Download lables befor start'),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => (ObjectDetection(
                      baseModel: widget.baseModel,
                      labels: lables!,
                    )),
                  ),
                );
              },
              child: Text('Run model object detection'),
            ),
            SizedBox(height: 9),
            ElevatedButton(
              onPressed: () async {
                await _showRunModelDialog(context);
                resetAllInputs();
              },
              child: Text('Run model'),
            ),
            inputObject == null
                ? Text("Object for add is empty")
                : Text('Object for add is not empty'),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () async {
                await _showDeleteConfirmationDialog(context);
                Navigator.pop(context, true);
              },
              child: Text('Delete model'),
            ),
            SizedBox(height: 8),
            Text('Predict:'),
            outputPredict == null
                ? Container()
                : Flexible(
                    child: ListView.builder(
                      itemCount: outputPredict!.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text('${outputPredict![index]}!'),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
