import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:image/image.dart';

class UtilsClass {
  Future<List<List<double>>> tokenizeInputText(
      {required String text,
      required String vocab,
      required bool isFile}) async {
    final int _sentenceLen = 256;

    final String start = '<START>';
    final String pad = '<PAD>';
    final String unk = '<UNKNOWN>';
    final Map<String, int> _dict =
        await loadDictionary(vocabulary: vocab, isFile: isFile);

    final toks = text.split(' ');

    var vec = List<double>.filled(_sentenceLen, _dict[pad]!.toDouble());

    var index = 0;
    if (_dict.containsKey(start)) {
      vec[index++] = _dict[start]!.toDouble();
    }

    for (var tok in toks) {
      if (index > _sentenceLen) {
        break;
      }
      vec[index++] = _dict.containsKey(tok)
          ? _dict[tok]!.toDouble()
          : _dict[unk]!.toDouble();
    }

    return [vec];
  }

  Future<Map<String, int>> loadDictionary(
      {required String vocabulary, required bool isFile}) async {
    String vocab;
    if (isFile == true) {
      vocab = await File('$vocabulary').readAsString();
    } else {
      vocab = vocabulary;
    }
    var dict = <String, int>{};
    final vocabList = vocab.split('\n');
    for (var i = 0; i < vocabList.length; i++) {
      var entry = vocabList[i].trim().split(' ');
      dict[entry[0]] = int.parse(entry[1]);
    }
    return dict;
  }

  Uint8List imageToByteListFloat32(
      img.Image image, int inputSize, List<double> mean, List<double> std) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (pixel.r - mean[0]) / std[0];
        buffer[pixelIndex++] = (pixel.g - mean[1]) / std[1];
        buffer[pixelIndex++] = (pixel.b - mean[2]) / std[2];
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  Float32List preprocesstest(Uint8List imageData, int width, int height) {
    int channels = 3;
    int imageSize = width * height * channels;

    if (imageData.length < imageSize) {
      throw RangeError(
          "Image data size is too small for the provided dimensions.");
    }

    Float32List imgData = Float32List(imageSize);

    int index = 0;
    for (int c = 0; c < channels; c++) {
      for (int h = 0; h < height; h++) {
        for (int w = 0; w < width; w++) {
          imgData[index++] =
              imageData[(h * width + w) * channels + c].toDouble() / 255.0;
        }
      }
    }

    Float32List meanVec = Float32List.fromList([0.485, 0.456, 0.406]);
    Float32List stddevVec = Float32List.fromList([0.229, 0.224, 0.225]);

    Float32List normImgData = Float32List(imageSize);

    for (int c = 0; c < channels; c++) {
      for (int h = 0; h < height; h++) {
        for (int w = 0; w < width; w++) {
          int idx = c * width * height + h * width + w;
          normImgData[idx] = (imgData[idx] - meanVec[c]) / stddevVec[c];
        }
      }
    }

    return normImgData;
  }

  Float32List preprocessGender(img.Image image) {
    List<Float32List> transposeChannels =
        List.generate(3, (i) => Float32List(image.height * image.width));
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        transposeChannels[0][y * image.width + x] = pixel.b.toDouble();
        transposeChannels[1][y * image.width + x] = pixel.g.toDouble();
        transposeChannels[2][y * image.width + x] = pixel.r.toDouble();
      }
    }

    List<double> meanVec = [104, 117, 123];
    Float32List normImgData = Float32List(3 * image.height * image.width);

    for (int c = 0; c < 3; c++) {
      for (int i = 0; i < image.height * image.width; i++) {
        normImgData[c * image.height * image.width + i] =
            transposeChannels[c][i] - meanVec[c];
      }
    }

    return normImgData;
  }

  static Float64List imageToFloatBuffer(
      Image image, List<double> mean, List<double> std,
      {bool contiguous = true}) {
    var bytes = Float64List(1 * image.height * image.width * 3);
    var buffer = Float64List.view(bytes.buffer);

    if (contiguous) {
      int offsetG = image.height * image.width;
      int offsetB = 2 * image.height * image.width;
      int i = 0;
      for (var y = 0; y < image.height; y++) {
        for (var x = 0; x < image.width; x++) {
          Pixel pixel = image.getPixel(x, y);
          buffer[i] = ((pixel.r / 255) - mean[0]) / std[0];
          buffer[offsetG + i] = ((pixel.g / 255) - mean[1]) / std[1];
          buffer[offsetB + i] = ((pixel.b / 255) - mean[2]) / std[2];
          i++;
        }
      }
    } else {
      int i = 0;
      for (var y = 0; y < image.height; y++) {
        for (var x = 0; x < image.width; x++) {
          Pixel pixel = image.getPixel(x, y);
          buffer[i++] = ((pixel.r / 255) - mean[0]) / std[0];
          buffer[i++] = ((pixel.g / 255) - mean[1]) / std[1];
          buffer[i++] = ((pixel.b / 255) - mean[2]) / std[2];
        }
      }
    }

    return bytes;
  }

  Future<List<String>> convertFileToList({required String assetsPath}) async {
    final lablesData = await rootBundle.loadString(assetsPath);
    List<String> lines = lablesData
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    return lines;
  }

  /// Converts a [CameraImage] in YUV420 format to [Image] in RGB format
  static Image? convertCameraImage(CameraImage cameraImage) {
    if (cameraImage.format.group == ImageFormatGroup.yuv420) {
      return convertYUV420ToImage(cameraImage);
    } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
      return convertBGRA8888ToImage(cameraImage);
    } else {
      return null;
    }
  }

  static Image convertBGRA8888ToImage(CameraImage image) {
    return Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: image.planes[0].bytes.buffer,
      order: ChannelOrder.bgra,
    );
  }

  static Image convertNV21ToImage(CameraImage image) {
    return Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: image.planes.first.bytes.buffer,
      order: ChannelOrder.bgra,
    );
  }

  static Image convertYUV420ToImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;

    final uvRowStride = cameraImage.planes[1].bytesPerRow;
    final uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

    final yPlane = cameraImage.planes[0].bytes;
    final uPlane = cameraImage.planes[1].bytes;
    final vPlane = cameraImage.planes[2].bytes;

    final image = Image(width: width, height: height);

    var uvIndex = 0;

    for (var y = 0; y < height; y++) {
      var pY = y * width;
      var pUV = uvIndex;

      for (var x = 0; x < width; x++) {
        final yValue = yPlane[pY];
        final uValue = uPlane[pUV];
        final vValue = vPlane[pUV];

        final r = yValue + 1.402 * (vValue - 128);
        final g =
            yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128);
        final b = yValue + 1.772 * (uValue - 128);

        image.setPixelRgba(x, y, r.toInt(), g.toInt(), b.toInt(), 255);

        pY++;
        if (x % 2 == 1 && uvPixelStride == 2) {
          pUV += uvPixelStride;
        } else if (x % 2 == 1 && uvPixelStride == 1) {
          pUV++;
        }
      }

      if (y % 2 == 1) {
        uvIndex += uvRowStride;
      }
    }
    return image;
  }

  static Uint8List imageToByteListUint8(Image image, int inputSize) {
    var convertedBytes = Uint8List(1 * inputSize * inputSize * 3);
    var buffer = Uint8List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        var pixel = image.getPixel(x, y);
        buffer[pixelIndex++] = pixel.r as int;
        buffer[pixelIndex++] = pixel.g as int;
        buffer[pixelIndex++] = pixel.b as int;
      }
    }

    return convertedBytes;
  }
}
