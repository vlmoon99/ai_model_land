import 'package:ai_model_land/ai_model_land_lib.dart';
import 'package:ai_model_land/modules/core/base_model.dart';
import 'package:ai_model_land_example/singlton/ai_model_provider.dart';
import 'package:ai_model_land_example/modalPage.dart';
import 'package:flutter/material.dart';
import 'addModelPage.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AiModelProvider>(
          create: (_) => AiModelProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AiModelLandLib _aiModelLand = AiModelProvider().aiModelLand;
  Future<List<BaseModel>>? _modelsLocal;
  Future<List<BaseModel>>? _modelsNetwork;
  Future<List<BaseModel>> seeLocal() async {
    return await _aiModelLand.readAllForType(sourceType: ModelSourceType.local);
  }

  Future<List<BaseModel>> seeNetwork() async {
    return await _aiModelLand.readAllForType(
        sourceType: ModelSourceType.network);
  }

  void _refreshData() {
    setState(() {
      _modelsLocal = seeLocal();
      _modelsNetwork = seeNetwork();
    });
  }

  @override
  void initState() {
    super.initState();
    _modelsLocal = seeLocal();
    _modelsNetwork = seeNetwork();
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
                                '${basemodel.nameFile}',
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
            _modelsNetwork == null
                ? Container()
                : FutureBuilder<List<BaseModel>>(
                    key: ValueKey(_modelsNetwork),
                    future: _modelsNetwork,
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
                              onPressed: () {
                                final isDeleteModel = Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ModelPage(baseModel: basemodel),
                                  ),
                                );
                                if (isDeleteModel == true) {
                                  setState(() {
                                    _modelsNetwork = seeNetwork();
                                  });
                                }
                              },
                              child: Text(
                                '${basemodel.nameFile}',
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
                        return Text('No network models found');
                      }
                    },
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final isAddModel = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddModelPage()),
                );
                if (isAddModel == true) {
                  _refreshData();
                }
              },
              child: Text('Add Model'),
            ),
          ],
        ),
      ),
    );
  }
}
