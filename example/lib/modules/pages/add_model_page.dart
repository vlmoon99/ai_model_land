import 'package:ai_model_land/models/core/base_model.dart';
import 'package:ai_model_land_example/services/services.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AddModelPage extends StatefulWidget {
  const AddModelPage({Key? key}) : super(key: key);

  @override
  State<AddModelPage> createState() => _AddModelPageState();
}

class _AddModelPageState extends State<AddModelPage> {
  final GlobalVM _aiModelLand = Modular.get(key: 'GlobalVM');

  final sourceController = TextEditingController();
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
        sourceController.text = result.files.single.path!;
      });
    } else {
      return null;
    }
  }

  Future<BaseModel> addModel() {
    final model = BaseModel(
        source: sourceController.text,
        nameFile: nameFileController.text,
        format: dropDawnFormat,
        sourceType: dropDawnSourceType);
    return _aiModelLand.addModel(baseModel: model);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add model page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
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
                              sourceController.text != null
                                  ? 'Selected File: ${sourceController.text}'
                                  : 'No file selected.',
                            ),
                          ],
                        )
                      : TextField(
                          controller: sourceController,
                          decoration: InputDecoration(labelText: 'Input URL'),
                        ),
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
              onPressed: () async {
                setState(() {
                  _modelFuture = addModel();
                });
                final result = await _modelFuture;
                if (result != null) {
                  Modular.to.navigate('/home');
                }
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
          ],
        ),
      ),
    );
  }
}
