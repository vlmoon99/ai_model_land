import 'package:ai_model_land_example/modules/providers/tensor_flow/model_interaction_modules/photo_detection_classification/page/tf_photo_detection_classification.dart';
import 'package:ai_model_land_example/routes/routes.dart';
import 'package:flutter_modular/flutter_modular.dart';

class PhotoDetectionClassificationModule extends Module {
  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.child(Routes.providersInteractions.init,
        child: (context) => TfPhotoDetectionClassification());
  }
}
