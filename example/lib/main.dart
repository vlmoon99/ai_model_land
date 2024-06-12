import 'package:ai_model_land/ai_model_land_lib.dart';
import 'package:ai_model_land/modules/core/models/base_model.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:ai_model_land/ai_model_land.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _aiModelLandPlugin = AiModelLand();
  final _aiModelLand = AiModelLandLib.defaultInstance();

  // final sorceController = TextEditingController();
  final nameFileController = TextEditingController();

  var dropDawnFormat = ModelFormat.tfjs;
  var dropDawnSourceType = ModelSourceType.local;

  Future<BaseModel>? _modelFuture;

  Future<List<BaseModel>>? _modelsLocal;
  Future<List<BaseModel>>? _modelsNetwork;
  Future<bool>? _isDelete;
  Future<bool>? _isDeleteNetwork;

  String? selectedFilePath;

  Future<String?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        selectedFilePath = result.files.single.path;
      });
    } else {
      return null;
    }
  }

  Future<BaseModel> addModel() async {
    final model = BaseModel(
        source: selectedFilePath!,
        nameFile: nameFileController.text,
        format: dropDawnFormat,
        sourceType: dropDawnSourceType);
    return await _aiModelLand.addModel(baseModel: model);
  }

  Future<List<BaseModel>> seeLocal() async {
    return await _aiModelLand.readAllForType(sourceType: ModelSourceType.local);
  }

  Future<List<BaseModel>> seeNetwork() async {
    return await _aiModelLand.readAllForType(
        sourceType: ModelSourceType.network);
  }

  Future<bool> deleteAllModelsForTypeLocal() async {
    return await _aiModelLand.deleteAllModelsForType(
        sourceType: ModelSourceType.local);
  }

  Future<bool> deleteAllModelsForTypeNetwork() async {
    return await _aiModelLand.deleteAllModelsForType(
        sourceType: ModelSourceType.network);
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await _aiModelLandPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    var repoTest = Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Running on: $_platformVersion\n'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 150.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: pickFile,
                    child: Text('Pick and Copy File'),
                  ),
                  SizedBox(height: 20),
                  Text(
                    selectedFilePath != null
                        ? 'Selected File: $selectedFilePath'
                        : 'No file selected.',
                  ),
                  // TextField(
                  //   controller: sorceController,
                  //   decoration: InputDecoration(labelText: 'Source'),
                  // ),
                  // SizedBox(height: 20),
                  TextField(
                    controller: nameFileController,
                    decoration: InputDecoration(labelText: 'Name File'),
                  ),
                  SizedBox(height: 20),
                  Text('Format'),
                  DropdownButton<ModelFormat>(
                    value: dropDawnFormat,
                    onChanged: (ModelFormat? newValue) {
                      setState(() {
                        dropDawnFormat = newValue!;
                      });
                    },
                    items: ModelFormat.values
                        .map<DropdownMenuItem<ModelFormat>>(
                            (ModelFormat value) {
                      return DropdownMenuItem<ModelFormat>(
                        value: value,
                        child: Text(value.toString().split('.').last),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  Text('Sorce Type'),
                  DropdownButton<ModelSourceType>(
                    value: dropDawnSourceType,
                    onChanged: (ModelSourceType? newValue) {
                      setState(() {
                        dropDawnSourceType = newValue!;
                      });
                    },
                    items: ModelSourceType.values
                        .map<DropdownMenuItem<ModelSourceType>>(
                            (ModelSourceType value) {
                      return DropdownMenuItem<ModelSourceType>(
                        value: value,
                        child: Text(value.toString().split('.').last),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _modelFuture = addModel();
                });
              },
              child: Text('Add Model'),
            ),
            SizedBox(height: 20),
            _modelFuture == null
                ? Container()
                : FutureBuilder<BaseModel>(
                    future: _modelFuture,
                    builder: (BuildContext context,
                        AsyncSnapshot<BaseModel> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return SelectableText('Error: ${snapshot.error}');
                      } else {
                        return SelectableText(
                            'Model added: ${snapshot.data.toString() ?? ''}');
                      }
                    },
                  ),
            SizedBox(height: 20),
            Row(children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _modelsLocal = seeLocal();
                  });
                },
                child: Text('See local repo'),
              ),
              SizedBox(height: 20),
              _modelsLocal == null
                  ? Container()
                  : FutureBuilder<List<BaseModel>>(
                      future: _modelsLocal,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<BaseModel>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return SelectableText('Error: ${snapshot.error}');
                        } else {
                          return SelectableText(
                              'Model added: ${snapshot.toString() ?? ''}');
                        }
                      },
                    ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _modelsNetwork = seeNetwork();
                  });
                },
                child: Text('See network repo'),
              ),
              SizedBox(height: 20),
              _modelsNetwork == null
                  ? Container()
                  : FutureBuilder<List<BaseModel>>(
                      future: _modelsNetwork,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<BaseModel>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return SelectableText('Error: ${snapshot.error}');
                        } else {
                          return SelectableText(
                              'Model added: ${snapshot.data ?? ''}');
                        }
                      },
                    ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isDelete = deleteAllModelsForTypeLocal();
                  });
                },
                child: Text('Delete all Models Local'),
              ),
              SizedBox(height: 20),
              _isDelete == null
                  ? Container()
                  : FutureBuilder<bool>(
                      future: _isDelete,
                      builder:
                          (BuildContext context, AsyncSnapshot<bool> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return SelectableText('Error: ${snapshot.error}');
                        } else {
                          return SelectableText(
                              'Model delete: ${snapshot.data ?? ''}');
                        }
                      },
                    ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isDeleteNetwork = deleteAllModelsForTypeNetwork();
                  });
                },
                child: Text('Delete all Models Network'),
              ),
              SizedBox(height: 20),
              _isDeleteNetwork == null
                  ? Container()
                  : FutureBuilder<bool>(
                      future: _isDeleteNetwork,
                      builder:
                          (BuildContext context, AsyncSnapshot<bool> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return SelectableText('Error: ${snapshot.error}');
                        } else {
                          return SelectableText(
                              'Model delete: ${snapshot.data ?? ''}');
                        }
                      },
                    ),
            ]),
          ],
        ),
      ),
    );

    return MaterialApp(
      home: repoTest,
    );
  }
}
