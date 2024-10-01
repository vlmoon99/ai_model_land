import "./tensor_flow_lite_export.dart"
    if (dart.library.js) "./tensor_flow_lite_web.dart"
    if (dart.library.io) "./tensor_flow_lite_io.dart";
import "package:ai_model_land/services/provider_ai_service.dart";

abstract class TensorFlowLite extends ProviderAiService {
  TensorFlowLite();
  factory TensorFlowLite.defaultInstance() {
    return instance;
  }
}
