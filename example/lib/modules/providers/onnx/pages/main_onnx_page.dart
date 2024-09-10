import 'package:ai_model_land_example/shared_widgets/custom_app_bar.dart';
import 'package:ai_model_land_example/shared_widgets/custom_button.dart';
import 'package:ai_model_land_example/thems/thems.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';

class MainOnnxPage extends StatefulWidget {
  const MainOnnxPage({super.key});

  @override
  State<MainOnnxPage> createState() => _MainOnnxPageState();
}

class _MainOnnxPageState extends State<MainOnnxPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: "ONNX"),
      backgroundColor: Thems.mainBackgroundColor,
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Flexible(
                child: SingleChildScrollView(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Walcome to ONNX provider!",
                      style: Thems.textStyle,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "In this section you can see how different models work in practice.",
                    style: Thems.textStyle,
                  ),
                  CustomButton(
                      onPressed: () {
                        Modular.to.pushNamed("//home/onnx/test");
                      },
                      text: "Image Classification Model")
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
