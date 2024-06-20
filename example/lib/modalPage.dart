import 'package:ai_model_land/ai_model_land_lib.dart';
import 'package:ai_model_land/modules/core/models/base_model.dart';
import 'package:ai_model_land_example/singlton/ai_model_provider.dart';
import 'package:flutter/material.dart';

class ModelPage extends StatefulWidget {
  final BaseModel baseModel;
  const ModelPage({super.key, required this.baseModel});

  @override
  State<ModelPage> createState() => _ModelPageState();
}

class _ModelPageState extends State<ModelPage> {
  final AiModelLandLib _aiModelLand = AiModelProvider().aiModelLand;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interaction with ${widget.baseModel.nameFile}'),
      ),
      body: Center(
        child: Column(
          children: [
            SelectableText('${widget.baseModel.nameFile}'),
            SelectableText('${_aiModelLand.hashCode}'),
          ],
        ),
      ),
    );
  }
}
