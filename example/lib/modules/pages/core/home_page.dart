import 'package:ai_model_land/ai_model_land.dart';
import 'package:ai_model_land/modules/core/base_model.dart';
import 'package:ai_model_land_example/modules/pages/core/add_model_page.dart';
import 'package:ai_model_land_example/modules/pages/providers/tensor_flow/modal_page.dart';
import 'package:ai_model_land_example/modules/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalVM _aiModelLand = Modular.get(key: 'GlobalVM');
  final _aiModelLandPlugin = AiModelLand();
  String _platformVersion = 'Unknown';
  Future<List<BaseModel>>? _modelsLocal;
  Future<List<BaseModel>>? _modelsNetwork;
  Future<Map<String, dynamic>>? posibilitis;
  Future<List<BaseModel>> seeLocal() async {
    return await _aiModelLand.readAll();
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

  Future<Map<String, dynamic>>
      checkPlatformGPUAcceleratorPossibilities() async {
    return await _aiModelLand.checkPlatformGPUAcceleratorPossibilities();
  }

  @override
  void initState() {
    super.initState();
    _modelsLocal = seeLocal();
    initPlatformState();
    posibilitis = checkPlatformGPUAcceleratorPossibilities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ai Model Land'),
      ),
      body: Center(
        child: Column(
          children: [
            Text("Local models:"),
            _modelsLocal == null
                ? Container()
                : FutureBuilder<List<BaseModel>>(
                    key: ValueKey(_modelsLocal),
                    future: _modelsLocal,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<BaseModel>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return SelectableText('Error: ${snapshot.error}');
                      } else if (snapshot.hasData &&
                          snapshot.data!.isNotEmpty) {
                        return Column(
                          children: snapshot.data!.map((basemodel) {
                            return ElevatedButton(
                              onPressed: () async {
                                final isDeleteModel = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ModelPage(baseModel: basemodel),
                                  ),
                                );
                                if (isDeleteModel == true) {
                                  setState(() {
                                    _modelsLocal = seeLocal();
                                  });
                                }
                              },
                              child: Text(
                                '${basemodel.nameFile}.${basemodel.format.name}',
                                style: const TextStyle(
                                    color: const Color.fromARGB(255, 0, 0, 0)),
                              ),
                              style: ElevatedButton.styleFrom(
                                side:
                                    BorderSide(color: Colors.black, width: 0.5),
                                backgroundColor:
                                    Color.fromARGB(255, 255, 255, 255),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.zero, // No border radius
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      } else {
                        return Text('No local models found');
                      }
                    },
                  ),
            SizedBox(height: 20),
            Text("Network models:"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                Modular.to.navigate('/home/addModel');
                // if (isAddModel == true) {
                //   setState(() {
                //     _modelsLocal = seeLocal();
                //   });
                // }
              },
              child: Text('Add Model'),
            ),
            SizedBox(height: 5),
            Text('Device characteristic:'),
            SizedBox(height: 5),
            Text('$_platformVersion'),
            posibilitis == null
                ? Container()
                : Flexible(
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: posibilitis,
                      builder: (BuildContext context,
                          AsyncSnapshot<Map<String, dynamic>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return SelectableText('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          final data = snapshot.data!;
                          return ListView(
                            children: data.entries.map((entry) {
                              String key = entry.key;
                              dynamic value = entry.value;
                              return ListTile(
                                title: SelectableText('$key: $value'),
                              );
                            }).toList(),
                          );
                        } else {
                          return Center(child: Text('No data available'));
                        }
                      },
                    ),
                  ),
            SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
