import 'package:ai_model_land_example/modules/thems/thems.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TfTextClassificationPage extends StatefulWidget {
  const TfTextClassificationPage({super.key});

  @override
  State<TfTextClassificationPage> createState() =>
      _TfTextClassificationPageState();
}

class _TfTextClassificationPageState extends State<TfTextClassificationPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(
          'TensorFlow Model',
          style: TextStyle(color: Thems.mainBackgroundColor),
        ),
        backgroundColor: Thems.appBarBackgroundColor,
        centerTitle: true,
      ),
      backgroundColor: Thems.mainBackgroundColor,
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Flexible(
                child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Text classification",
                    style: Thems.textStyle,
                  ),
                  Text(
                    "This model can determine whether your passage is positive or negative.",
                    style: Thems.textStyle,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "For interaction:",
                        style: Thems.textStyle,
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        "First step it is upload model.",
                        style: Thems.textStyle,
                      ),
                    ],
                  ),
                ],
              ),
            ))
          ],
        ),
      ),
    ));
  }
}
