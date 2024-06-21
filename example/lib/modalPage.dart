import 'dart:async';
import 'dart:io';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:ai_model_land/ai_model_land_lib.dart';
import 'package:ai_model_land/modules/core/base_model.dart';
import 'package:ai_model_land/modules/core/task_request_model.dart';
import 'package:ai_model_land/modules/providers/tensor_flow/tensorflow_model.dart';
import 'package:ai_model_land_example/singlton/ai_model_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ModelPage extends StatefulWidget {
  final BaseModel baseModel;
  const ModelPage({super.key, required this.baseModel});

  @override
  State<ModelPage> createState() => _ModelPageState();
}

class _ModelPageState extends State<ModelPage> {
  final AiModelLandLib _aiModelLand = AiModelProvider().aiModelLand;
  Uint8List img = Uint8List(0);

  late bool isModelLoaded;

  Future<bool>? isAdd;

  Future<bool> loadModel({required BaseModel baseModel}) async {
    return await _aiModelLand.loadModel(baseModel: baseModel);
  }

  bool isModelLoadedF({required BaseModel baseModel}) {
    return _aiModelLand.isModelLoaded(baseModel: baseModel);
  }

  Future<void> stopModel({required BaseModel baseModel}) async {
    await _aiModelLand.stopModel(baseModel: baseModel);
  }

  Future<void> runModel({required BaseModel baseModel}) async {
    if (img.isEmpty) {
      throw Exception('Img not add');
    }
    await _aiModelLand.runTaskOnTheModel(
        request: TensorFlowRequestModel(uint8list: img), baseModel: baseModel);
  }

  Future<String?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final listBity = await File(result.files.single.path!).readAsBytes();
      setState(() {
        img = listBity;
      });
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    isModelLoaded = isModelLoadedF(baseModel: widget.baseModel);
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
                  isAdd == null && !isModelLoaded
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
                            } else if (snapshot.data == true || isModelLoaded) {
                              return Text("Result: model was loaded");
                            } else {
                              return Text(
                                  "Result: some gone wrong, try add one more time");
                            }
                          },
                        ),
                ],
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                stopModel(baseModel: widget.baseModel);
                setState(() {
                  isModelLoaded = false;
                });
              },
              child: Text('Stop model'),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: pickFile,
              child: Text('Pick model File (IMG)'),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                runModel(baseModel: widget.baseModel);
              },
              child: Text('Run model'),
            ),
            Text('${img.last}'),
            img.length == 0 ? Text("img not add") : Text('img was add'),
          ],
        ),
      ),
    );
  }
}
