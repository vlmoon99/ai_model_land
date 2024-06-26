import 'package:ai_model_land/modules/core/base_model.dart';
import 'package:ai_model_land_example/singlton/ai_model_provider.dart';
import 'package:ai_model_land_example/main.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ai_model_land/ai_model_land_lib.dart';
import 'package:flutter/services.dart';
import 'package:ai_model_land/ai_model_land.dart';

class addModelPage extends StatefulWidget {
  const addModelPage({Key? key}) : super(key: key);

  @override
  State<addModelPage> createState() => _addModelPageState();
}

class _addModelPageState extends State<addModelPage> {
  final AiModelLandLib _aiModelLand = AiModelProvider().aiModelLand;
  String _platformVersion = 'Unknown';
  final _aiModelLandPlugin = AiModelLand();

  final sorceController = TextEditingController();
  final nameFileController = TextEditingController();

  var dropDawnFormat = ModelFormat.tflite;
  var dropDawnSourceType = ModelSourceType.local;

  Future<BaseModel>? _modelFuture;

  Future<List<BaseModel>>? _modelsLocal;
  Future<List<BaseModel>>? _modelsNetwork;
  Future<bool>? _isDelete;
  Future<bool>? _isDeleteNetwork;

  Future<String?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        sorceController.text = result.files.single.path!;
      });
    } else {
      return null;
    }
  }

  Future<BaseModel> addModel() async {
    final model = BaseModel(
        source: sorceController.text,
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
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              child: Text('Go to home page'),
            ),
            Text('Running on: $_platformVersion\n'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 150.0),
              child: Column(
                children: [
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
                  dropDawnSourceType == ModelSourceType.local
                      ? Column(
                          children: [
                            ElevatedButton(
                              onPressed: pickFile,
                              child: Text('Pick model File'),
                            ),
                            SizedBox(height: 20),
                            Text(
                              sorceController.text != null
                                  ? 'Selected File: ${sorceController.text}'
                                  : 'No file selected.',
                            ),
                          ],
                        )
                      : TextField(
                          controller: sorceController,
                          decoration: InputDecoration(labelText: 'Input URL'),
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
