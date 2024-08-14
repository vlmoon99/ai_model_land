import 'package:ai_model_land_example/modules/shared_widgets/custom_button.dart';
import 'package:ai_model_land_example/modules/thems/thems.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';

class MainTensorflowPage extends StatefulWidget {
  const MainTensorflowPage({super.key});

  @override
  State<MainTensorflowPage> createState() => _MainTensorflowPageState();
}

class _MainTensorflowPageState extends State<MainTensorflowPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'TensorFlow',
            style: TextStyle(color: Thems.mainBackgroundColor),
          ),
          backgroundColor: Thems.appBarBackgroundColor,
          centerTitle: true,
        ),
        backgroundColor: Thems.mainBackgroundColor,
        body: Container(
          padding: EdgeInsets.all(10),
          child: Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  'Walcome to TensorFlow provider!',
                  style: Thems.textStyle,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "In this section you can see how different models work in practice.",
                    style: Thems.textStyle,
                  ),
                ),
                SizedBox(height: 10),
                CustomButton(
                    onPressed: () {
                      Modular.to.pushNamed('/home/tensorFlow/text-detection');
                    },
                    text: "Text classification"),
                CustomButton(
                    onPressed: () {}, text: "Photo detection classification"),
                CustomButton(
                    onPressed: () {}, text: "Video object classification"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
