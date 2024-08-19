import 'package:ai_model_land_example/modules/providers/tensor_flow/model_interaction_modules/video_object_detection/pages/object_detection_camera_page.dart';
import 'package:ai_model_land_example/modules/providers/tensor_flow/model_interaction_modules/video_object_detection/pages/video_object_detection_page.dart';
import 'package:ai_model_land_example/routes/routes.dart';
import 'package:flutter_modular/flutter_modular.dart';

class TFVideoObjectDetection extends Module {
  @override
  void binds(i) {}

  @override
  void routes(r) {
    r.child(Routes.providersInteractions.init,
        child: (context) => TFVideoObjectDetectionPage());
    r.child(Routes.providersInteractions.videoObjectDetection + "-page",
        child: (context) {
      final args = Modular.args.data as Map<String, dynamic>;
      final baseModel = args['baseModel'];
      final labels = args['labels'];
      return ObjectDetection(baseModel: baseModel, labels: labels);
    });
  }
}
