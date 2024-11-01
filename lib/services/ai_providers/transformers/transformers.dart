import 'dart:convert';

import 'package:ai_model_land/models/core/base_model.dart';
import 'package:ai_model_land/models/core/task_request_model.dart';
import 'package:ai_model_land/models/core/task_response_model.dart';
import 'package:ai_model_land/models/providers/transformers/transformers_request_model.dart';
import 'package:ai_model_land/models/providers/transformers/transformers_respons_model.dart';
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
        '''window.transformers.loadModel('${transformersRequest.typeLoadModel!.name}',{model_id: '${baseModel.source}', device: '${transformersRequest.backendDevice?.name}', typeModel: ${transformersRequest.typeModel != null ? "\'${transformersRequest.typeModel}\'" : null}, dtype: ${transformersRequest.dtype != null ? "\'${transformersRequest.dtype}\'" : null}, use_external_data_format: ${transformersRequest.use_external_data_format}, model_file_name: ${transformersRequest.model_file_name != null ? "\'${transformersRequest.model_file_name}\'" : null}, })''');
    Map<String, dynamic> res = jsonDecode(generator);
    if (res.containsKey("error")) {
      throw Exception("${res["error"]}");
    }

    return true;
  }

  @override
  Future<bool> isModelLoaded() async {
    final response =
        await jsVMService.callJS("window.transformers.isModelLoaded()");
    Map<String, dynamic> res = jsonDecode(response);
    switch (res["res"]) {
      case true:
        {
          return true;
        }
      case false:
        {
          return false;
        }
      default:
        {
          throw Exception("Unexpected response: ${res["res"]}");
        }
    }
  }

  @override
  Future<bool> restartModel(
      {required TaskRequestModel request, required BaseModel baseModel}) async {
    try {
      final isStop = await this.stopModel();
      if (isStop != true) {
        return false;
      } else {
        final isLoad =
            await this.addModel(request: request, baseModel: baseModel);
        if (isLoad != true) {
          return false;
        } else {
          return true;
        }
      }
    } catch (e) {
      throw Exception("$e");
    }
  }

  @override
  Future<TaskResponseModel> runTaskOnTheModel(TaskRequestModel request) async {
    final transformersRequest = request as TransformersRequestModel;
    final runModel = await jsVMService.callJSAsync(
        "window.transformers.runModel({ messages: ${transformersRequest.data}, tokenizerChatOptions: ${transformersRequest.tokenizerChatOptions}, max_new_tokens: ${transformersRequest.max_new_tokens}, do_sample: ${transformersRequest.do_sample}, return_dict_in_generate: ${transformersRequest.return_dict_in_generate}, skip_special_tokens: ${transformersRequest.skip_special_tokens}, optionsForGnerator: ${transformersRequest.optionsForGnerator}, useChatTemplate: ${transformersRequest.useChatTemplate}})");
    Map<String, dynamic> res = jsonDecode(runModel);
    if (res.containsKey("error")) {
      throw Exception("${res["error"]}");
    }
    return TransformersResponsModel(response: res["res"]["message"]);
  }

  @override
  Future<bool> stopModel() async {
    final stopeModel =
        await jsVMService.callJSAsync("window.transformers.stopModel()");
    Map<String, dynamic> res = jsonDecode(stopeModel);
    if (res.containsKey("error")) {
      throw Exception("Failed stop model: ${res["error"]}");
    }
    return true;
  }
}
