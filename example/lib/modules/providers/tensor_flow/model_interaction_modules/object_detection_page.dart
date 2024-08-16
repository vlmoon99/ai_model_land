import 'dart:io';
import 'package:ai_model_land/models/core/base_model.dart';
import 'package:ai_model_land/models/providers/tensor_flow/tensorflow_request_model.dart';
import 'package:ai_model_land/models/providers/tensor_flow/tensorflow_respons_model.dart';
import 'package:ai_model_land_example/modules/models/recognition.dart';
import 'package:ai_model_land_example/services/services.dart';
import 'package:ai_model_land_example/shared_widgets/box_widget.dart';
import 'package:ai_model_land_example/modules/models/screen_params.dart';
import 'package:ai_model_land_example/shared_widgets/stats.dart';
import 'package:ai_model_land_example/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:camera/camera.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:image/image.dart' as image_lib;

class ObjectDetection extends StatefulWidget {
  final BaseModel baseModel;
  final String labels;
  const ObjectDetection(
      {super.key, required this.baseModel, required this.labels});

  @override
  State<ObjectDetection> createState() => _ObjectDetectionState();
}

class _ObjectDetectionState extends State<ObjectDetection>
    with WidgetsBindingObserver {
  /// List of available cameras
  late List<CameraDescription> cameras;

  /// Controller
  CameraController? _cameraController;
  get _controller => _cameraController;

  List<String>? _labels;

  Map<String, String>? stats;

  final GlobalVM _aiModelLand = Modular.get(key: 'GlobalVM');

  List<Recognition>? results;

  bool _isAnalyzing = false;

  Future<List<dynamic>> runModel(
      {required BaseModel baseModel,
      required List<Object> inputObject,
      required bool async}) async {
    final TensorFlowResponseModel output = await _aiModelLand.runTaskOnTheModel(
        request: TensorFlowRequestModel(dataMulti: [inputObject], async: async),
        baseModel: baseModel);
    return output.predictForMulti!.values.toList();
  }

  void _convertCameraImage(CameraImage cameraImage) async {
    try {
      var preConversionTime = DateTime.now().millisecondsSinceEpoch;
      if (_isAnalyzing) return;
      _isAnalyzing = true;
      var image = UtilsClass.convertCameraImage(cameraImage);
      if (image != null) {
        if (Platform.isAndroid) {
          image = image_lib.copyRotate(image, angle: 90);
        }

        final output = await analysisImage(image, preConversionTime);
        if (mounted) {
          setState(() {
            stats = output['stats'];
            results = output['recognitions'];
          });
        }
      }
      _isAnalyzing = false;
    } catch (e) {
      throw Exception("$e");
    }
  }

  Future<Map<String, dynamic>> analysisImage(
      image_lib.Image image, int preConversionTime) async {
    final imageInput = image_lib.copyResize(
      image,
      width: 300,
      height: 300,
    );

    final imageMatrix = UtilsClass.imageToByteListUint8(imageInput, 300);

    final output = await runModel(
        baseModel: widget.baseModel, inputObject: imageMatrix, async: true);

    final locationsRaw = output.first.first as List<List<double>>;

    final List<Rect> locations = locationsRaw
        .map((list) => list.map((value) => (value * 300)).toList())
        .map((rect) => Rect.fromLTRB(rect[1], rect[0], rect[3], rect[2]))
        .toList();

    // Classes
    final classesRaw = output.elementAt(1).first as List<double>;
    final classes = classesRaw.map((value) => value.toInt()).toList();

    // Scores
    final scores = output.elementAt(2).first as List<double>;

    // Number of detections
    final numberOfDetectionsRaw = output.last.first as double;
    final numberOfDetections = numberOfDetectionsRaw.toInt();

    final List<String> classification = [];
    for (var i = 0; i < numberOfDetections; i++) {
      classification.add(_labels![classes[i]]);
    }

    /// Generate recognitions
    List<Recognition> recognitions = [];
    for (int i = 0; i < numberOfDetections; i++) {
      var score = scores[i];
      var label = classification[i];

      if (score > 0.5) {
        recognitions.add(
          Recognition(i, label, score, locations[i]),
        );
      }
    }

    var totalElapsedTime =
        DateTime.now().millisecondsSinceEpoch - preConversionTime;

    return {
      "recognitions": recognitions,
      "stats": <String, String>{
        'Frame': '${image.width} X ${image.height}',
        'Total prediction time:': '$totalElapsedTime',
      },
    };
  }

  void loadLabels() async {
    File labelsFile = File(widget.labels);
    if (await labelsFile.exists()) {
      final List<String> labelList =
          await convertFileToList(labels: labelsFile);
      setState(() {
        _labels = labelList;
      });
    }
  }

  Future<List<String>> convertFileToList({required File labels}) async {
    String fileContent = await labels.readAsString();
    List<String> lines = fileContent
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    return lines;
  }

  void _initializeCamera() async {
    try {
      cameras = await availableCameras();
      _cameraController = CameraController(
        cameras[0],
        ResolutionPreset.low,
        enableAudio: false,
      )..initialize().then((_) async {
          await _controller.startImageStream(onLatestImageAvailable);
          ScreenParams.previewSize = _controller!.value.previewSize!;

          setState(() {});
        });
    } catch (e) {
      throw Exception('Some gone wrong $e');
    }
  }

  void onLatestImageAvailable(CameraImage cameraImage) async {
    _convertCameraImage(cameraImage);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    List<String>? _labels;
    List<Recognition>? results;
    _initializeCamera();
    loadLabels();
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        _cameraController?.stopImageStream();
        break;
      case AppLifecycleState.resumed:
        _initializeCamera();
        break;
      default:
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenParams.screenSize = MediaQuery.sizeOf(context);
    if (_controller == null || !_controller!.value.isInitialized) {
      return const SizedBox.shrink();
    }
    var aspect = 1 / _controller!.value.aspectRatio;

    return Stack(
      children: [
        AspectRatio(
          aspectRatio: aspect,
          child: CameraPreview(_controller!),
        ),
        _statsWidget(),
        AspectRatio(
          aspectRatio: aspect,
          child: _boundingBoxes(),
        ),
      ],
    );
  }

  Widget _statsWidget() => (stats != null)
      ? Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.white.withAlpha(150),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: stats!.entries
                    .map((e) => StatsWidget(e.key, e.value))
                    .toList(),
              ),
            ),
          ),
        )
      : const SizedBox.shrink();

  Widget _boundingBoxes() {
    if (results == null) {
      return const SizedBox.shrink();
    }
    return Stack(
        children: results!.map((box) => BoxWidget(result: box)).toList());
  }
}
