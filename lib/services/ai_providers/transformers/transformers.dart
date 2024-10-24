import 'dart:convert';

import 'package:ai_model_land/models/core/base_model.dart';
import 'package:ai_model_land/models/core/task_request_model.dart';
import 'package:ai_model_land/models/core/task_response_model.dart';
import 'package:ai_model_land/models/providers/transformers/transformers_request_model.dart';
import 'package:ai_model_land/services/js_engines/interface/js_engine_stub.dart'
    if (dart.library.io) 'package:ai_model_land/services/js_engines/implementation/webview_js_engine.dart'
    if (dart.library.js) 'package:ai_model_land/services/js_engines/implementation/web_js_engine.dart';
import 'package:ai_model_land/services/js_engines/interface/js_vm.dart';
import 'package:ai_model_land/services/provider_ai_service.dart';

class Transformers implements ProviderAiService {
  JsVMService jsVMService;
  Transformers({required this.jsVMService}) {}

  factory Transformers.defaultInstance() {
    return Transformers(
      jsVMService: getJsVM(),
    );
  }

  @override
  Future<bool> addModel(
      {required TaskRequestModel request, required BaseModel baseModel}) async {
    final transformersRequest = request as TransformersRequestModel;
    if (request.loadModelWay == null ||
        request.loadModelWay != LoadModelWay.fromID) {
      throw Exception("Transformers support only fromID load model way");
    }
    if (transformersRequest.typeLoadModel == null) {
      throw Exception("typeLoadModel is required parameter");
    }

    final generator = await jsVMService.callJSAsync(
        '''window.transformers.loadModel('${transformersRequest.typeLoadModel!.name}',{model_id: '${baseModel.source}', device: '${transformersRequest.backendDevice?.name}', dtype: '${transformersRequest.dtype}', typeModel: '${transformersRequest.typeModel}'});''');
    Map<String, dynamic> res = jsonDecode(generator);
    if (res.containsKey("error")) {
      throw Exception("${res["error"]}");
    }
    return true;
  }

  @override
  Future<bool> isModelLoaded() {
    // TODO: implement isModelLoaded
    throw UnimplementedError();
  }

  @override
  Future<bool> restartModel(
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
  Future<bool> stopModel() {
    // TODO: implement stopModel
    throw UnimplementedError();
  }
}
