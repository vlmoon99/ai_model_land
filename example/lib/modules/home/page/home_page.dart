import 'package:ai_model_land/ai_model_land.dart';
import 'package:ai_model_land/models/core/base_model.dart';
import 'package:ai_model_land_example/modules/pages/add_model_page.dart';
import 'package:ai_model_land_example/modules/providers/tensor_flow/model_interaction_modules/modal_page.dart';
import 'package:ai_model_land_example/services/services.dart';
import 'package:ai_model_land_example/shared_widgets/custom_app_bar.dart';
import 'package:ai_model_land_example/shared_widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../thems/thems.dart';

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
      appBar: CustomAppBar(text: 'Ai Model Land'),
      backgroundColor: Thems.mainBackgroundColor,
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(children: [
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "Welcome to Ai Model Land!",
                    style: TextStyle(
                        fontFamily: Thems.textFontFamily,
                        fontSize: 24,
                        color: Color.fromARGB(255, 219, 85, 85)),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Here you can work with any models and any providers that our library supports.",
                        style: Thems.textStyle,
                      ),
                      Text(
                        "Now days we support: ${ModelFormat.values.toString()}.",
                        textAlign: TextAlign.start,
                        style: Thems.textStyle,
                      ),
                      Text(
                        "You can check our work right now, just choose the right provider!",
                        textAlign: TextAlign.start,
                        style: Thems.textStyle,
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Your device characteristic:',
                    style: Thems.textStyle,
                  ),
                  SizedBox(height: 5),
                  Text(
                    '$_platformVersion',
                    style: Thems.textStyle,
                  ),
                  posibilitis == null
                      ? Container()
                      : FutureBuilder<Map<String, dynamic>>(
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
                              return Column(
                                children: data.entries.map((entris) {
                                  return SelectableText(
                                      "${entris.key}: ${entris.value}",
                                      style: Thems.textStyle);
                                }).toList(),
                              );
                            } else {
                              return Center(
                                  child: Text(
                                'No data available',
                                style: Thems.textStyle,
                              ));
                            }
                          },
                        ),
                  SizedBox(height: 10),
                  CustomButton(
                    onPressed: () async {
                      Modular.to.pushNamed('/home/tensorFlow');
                    },
                    text: 'TensorFlowLite',
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
