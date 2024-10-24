import 'package:ai_model_land_example/shared_widgets/custom_app_bar.dart';
import 'package:ai_model_land_example/shared_widgets/custom_button.dart';
import 'package:ai_model_land_example/thems/thems.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';

class MainTransformersPage extends StatefulWidget {
  const MainTransformersPage({super.key});

  @override
  State<MainTransformersPage> createState() => _MainTransformersPageState();
}

class _MainTransformersPageState extends State<MainTransformersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: "Transformers"),
      backgroundColor: Thems.mainBackgroundColor,
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                'Walcome to Transformers provider!',
                style: Thems.textStyle,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "In this section you can see how different models work in practice.",
              style: Thems.textStyle,
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  CustomButton(
                      onPressed: () {
                        Modular.to.pushNamed('//home/transformers/llm');
                      },
                      text: "LLM"),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
