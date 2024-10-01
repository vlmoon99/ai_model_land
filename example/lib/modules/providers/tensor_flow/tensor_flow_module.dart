import 'package:ai_model_land_example/modules/providers/tensor_flow/model_interaction_tensorflow_modules/photo_detection_classification/photo_detection_classification_module.dart';
import 'package:ai_model_land_example/modules/providers/tensor_flow/model_interaction_tensorflow_modules/video_object_detection/video_object_detection_module.dart';
import 'package:ai_model_land_example/modules/providers/tensor_flow/page/main_tensorflow_page.dart';
import 'package:ai_model_land_example/modules/providers/tensor_flow/model_interaction_tensorflow_modules/text_classification/text_classification_module.dart';
import 'package:ai_model_land_example/routes/routes.dart';
import 'package:flutter_modular/flutter_modular.dart';

class TensorFlowModule extends Module {
  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.child(Routes.providers.init, child: (context) => MainTensorflowPage());
    r.module(Routes.providersInteractions.textClassification,
        module: TFTextClassificationModule());
    r.module(Routes.providersInteractions.photoDetectionClassification,
        module: TFPhotoDetectionClassificationModule());
    r.module(Routes.providersInteractions.videoObjectDetection,
        module: TFVideoObjectDetection());
  }
}
