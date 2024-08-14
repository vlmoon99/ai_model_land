import 'package:ai_model_land_example/modules/thems/thems.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MainOnnxPage extends StatefulWidget {
  const MainOnnxPage({super.key});

  @override
  State<MainOnnxPage> createState() => _MainOnnxPageState();
}

class _MainOnnxPageState extends State<MainOnnxPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Onnx provider',
          style: TextStyle(color: Thems.mainBackgroundColor),
        ),
        backgroundColor: Thems.appBarBackgroundColor,
        centerTitle: true,
      ),
    );
  }
}
