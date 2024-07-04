import 'dart:io';

import 'package:ai_model_land/ai_model_land_lib.dart';
import 'package:ai_model_land/modules/core/base_model.dart';
import 'package:ai_model_land/modules/providers/tensor_flow/tensorflow_request_model.dart';
import 'package:ai_model_land/modules/providers/tensor_flow/tensorflow_respons_model.dart';
import 'package:ai_model_land_example/objectDetectionPage/box_widget.dart';
import 'package:ai_model_land_example/objectDetectionPage/convert.dart';
import 'package:ai_model_land_example/objectDetectionPage/recognition.dart';
import 'package:ai_model_land_example/objectDetectionPage/screen_params.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as image_lib;

import '../singlton/ai_model_provider.dart';

class ObjectDetection extends StatefulWidget {
  final BaseModel baseModel;
  const ObjectDetection({super.key, required this.baseModel});

  @override
  State<ObjectDetection> createState() => _ObjectDetectionState();
}

class _ObjectDetectionState extends State<ObjectDetection>
    with WidgetsBindingObserver {
  /// List of available cameras
  late List<CameraDescription> cameras;

  /// Controller
  CameraController? _cameraController;

  final AiModelLandLib _aiModelLand = AiModelProvider().aiModelLand;

  List<Recognition>? results;

  Future<List<List<Object>>> runModel(
      {required BaseModel baseModel,
      required List<Object> inputObject,
      required bool async}) async {
    late TensorFlowResponsModel output;
    output = await _aiModelLand.runTaskOnTheModel(
        request: TensorFlowRequestModel(dataMulti: inputObject, async: async),
        baseModel: baseModel) as TensorFlowResponsModel;
    return output.predictForMulti!.values.toList() as List<List<Object>>;
  }

  void _convertCameraImage(CameraImage cameraImage) {
    convertCameraImageToImage(cameraImage).then((image) {
      if (image != null) {
        if (Platform.isAndroid) {
          image = image_lib.copyRotate(image, angle: 90);
        }

        final results = analyseImage(image);
      }
    });
  }

  Future<Map<String, dynamic>> analyseImage(image_lib.Image? image) async {
    var preProcessStart = DateTime.now().millisecondsSinceEpoch;

    /// Pre-process the image
    /// Resizing image for model [300, 300]
    final imageInput = image_lib.copyResize(
      image!,
      width: 300,
      height: 300,
    );

    // Creating matrix representation, [300, 300, 3]
    final imageMatrix = List.generate(
      imageInput.height,
      (y) => List.generate(
        imageInput.width,
        (x) {
          final pixel = imageInput.getPixel(x, y);
          return [pixel.r, pixel.g, pixel.b];
        },
      ),
    );

    final output = await runModel(
        baseModel: widget.baseModel, inputObject: imageMatrix, async: false);

    // Location
    final locationsRaw = output.first as List<double>;

    // final List<Rect> locations = locationsRaw
    //     .map((value) => (value * 300)).toList()
    //     .map((rect) => Rect.fromLTRB(rect[1], rect[0], rect[3], rect[2]))
    //     .toList();

    // Classes
    final classesRaw = output.elementAt(1).first as List<double>;
    final classes = classesRaw.map((value) => value.toInt()).toList();

    // Scores
    final scores = output.elementAt(2).first as List<double>;

    // Number of detections
    final numberOfDetectionsRaw = output.last.first as double;
    final numberOfDetections = numberOfDetectionsRaw.toInt();

    // final List<String> classification = [];
    // for (var i = 0; i < numberOfDetections; i++) {
    //   classification.add(_labels![classes[i]]);
    // }

    // /// Generate recognitions
    // List<Recognition> recognitions = [];
    // for (int i = 0; i < numberOfDetections; i++) {
    //   // Prediction score
    //   var score = scores[i];
    //   // Label string
    //   var label = classification[i];

    //   if (score > 0.5) {
    //     recognitions.add(
    //       Recognition(i, label, score, locations[i]),
    //     );
    //   }
    // }

    return {
      // "recognitions": recognitions,
      "stats": <String, String>{
        'Frame': '${image.width} X ${image.height}',
      },
    };
  }

  void _initializeCamera() async {
    try {
      cameras = await availableCameras();
      // cameras[0] for back-camera
      _cameraController = CameraController(
        cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
      )..initialize().then((_) async {
          await _cameraController!.startImageStream(onLatestImageAvailable);
          setState(() {});

          /// previewSize is size of each image frame captured by controller
          ///
          /// 352x288 on iOS, 240p (320x240) on Android with ResolutionPreset.low
          ScreenParams.previewSize = _cameraController!.value.previewSize!;
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
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
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
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const SizedBox.shrink();
    }

    var aspect = 1 / _cameraController!.value.aspectRatio;

    return Stack(
      children: [
        AspectRatio(
          aspectRatio: aspect,
          child: CameraPreview(_cameraController!),
        ),
        // Bounding boxes
        AspectRatio(
          aspectRatio: aspect,
          child: _boundingBoxes(),
        ),
      ],
    );
  }

  Widget _boundingBoxes() {
    if (results == null) {
      return const SizedBox.shrink();
    }
    return Stack(
        children: results!.map((box) => BoxWidget(result: box)).toList());
  }
}
