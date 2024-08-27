import 'package:ai_model_land_example/shared_widgets/custom_app_bar.dart';
import 'package:ai_model_land_example/shared_widgets/custom_button.dart';
import 'package:ai_model_land_example/thems/thems.dart';
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
    return Scaffold(
      appBar: CustomAppBar(text: "TensorFlowLite"),
      backgroundColor: Thems.mainBackgroundColor,
      body: Container(
        padding: EdgeInsets.all(10),
        child: Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              Text(
                'Walcome to TensorFlowLite provider!',
                style: Thems.textStyle,
              ),
              SizedBox(height: 6),
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
                    Modular.to.pushNamed('//home/tensorFlow/text-detection');
                  },
                  text: "Text classification"),
              SizedBox(height: 10),
              CustomButton(
                  onPressed: () {
                    Modular.to.pushNamed(
                        '//home/tensorFlow/photo-detection-classification');
                  },
                  text: "Photo detection classification"),
              SizedBox(height: 10),
              CustomButton(
                  onPressed: () {
                    Modular.to
                        .pushNamed('//home/tensorFlow/video-object-detection');
                  },
                  text: "Video object detection classification"),
            ],
          ),
        ),
      ),
    );
  }
}
