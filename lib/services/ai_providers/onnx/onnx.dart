import 'package:ai_model_land/models/core/base_model.dart';
import 'package:ai_model_land/models/core/task_request_model.dart';
import 'package:ai_model_land/models/core/task_response_model.dart';
import 'package:ai_model_land/models/providers/onnx/onnx_request_model.dart';
import 'package:ai_model_land/services/provider_ai_service.dart';

class ONNX extends ProviderAiService {
  // OrtSessionOptions? sessionOptions;
  // OrtSession? session;
  ONNX() {}

  factory ONNX.defaultInstance() {
    return ONNX();
  }

  @override
  Future<bool> addModel(
      {required TaskRequestModel request, required BaseModel baseModel}) {
    // final onnxRequest = request as OnnxRequestModel;
    // try {
    //   switch (onnxRequest.loadModelWay) {
    //     case LoadModelWay.fromFile:
    //       {
    //         if (onnxRequest.loadModelFilePath == null) {
    //           throw Exception(
    //               "For add model you need indicate full file path to model");
    //         }
    //         sessionOptions = OrtSessionOptions();
    //         File modelFile = File(onnxRequest.loadModelFilePath!);
    //         session = OrtSession.fromFile(modelFile, sessionOptions!);
    //       }
    //     case LoadModelWay.fromBuffer:
    //       {
    //         if (onnxRequest.uint8list == null) {
    //           throw Exception(
    //               "For add model you need indicate convert model in uint8list");
    //         }
    //         // OrtEnv.instance.availableProviders().forEach((element) {
    //         //   print('onnx provider=$element');
    //         // });
    //         // OrtEnv.instance.release();
    //         // OrtEnv.version;
    //         OrtEnv.instance.init();
    //         sessionOptions = OrtSessionOptions()
    //           ..setInterOpNumThreads(1)
    //           ..setIntraOpNumThreads(1)
    //           ..setSessionGraphOptimizationLevel(
    //               GraphOptimizationLevel.ortEnableAll);
    //         session =
    //             OrtSession.fromBuffer(onnxRequest.uint8list!, sessionOptions!);
    //         final runOptions = OrtRunOptions();
    //       }
    //     case LoadModelWay.fromAddress:
    //       {
    //         if (onnxRequest.pointerAddress == null) {
    //           throw Exception(
    //               "For add model you need indicate pointer address");
    //         }
    //         session = OrtSession.fromAddress(onnxRequest.pointerAddress!);
    //       }
    //     default:
    //       throw Exception("This load model way doesn`t exist");
    //   }
    // } catch (e) {
    //   throw Exception("Model not add: $e");
    // }
    // return Future.value(true);
    throw UnimplementedError("No finish");
  }

  @override
  void checkPlatformGPUAcceleratorPossibilities(String params) {
    // TODO: implement checkPlatformGPUAcceleratorPossibilities
  }

  @override
  Future deleteModel() {
    // TODO: implement deleteModel
    throw UnimplementedError();
  }

  @override
  bool isModelLoaded() {
    // TODO: implement isModelLoaded
    throw UnimplementedError();
  }

  @override
  Future restartModel(
      {required TaskRequestModel request, required BaseModel baseModel}) {
    // TODO: implement restartModel
    throw UnimplementedError();
  }

  @override
  Future<TaskResponseModel> runTaskOnTheModel(TaskRequestModel request) {
    // TODO: implement runTaskOnTheModel
    throw UnimplementedError();
  }

  @override
  Future stopModel() {
    // TODO: implement stopModel
    throw UnimplementedError();
  }
}
