import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';

import 'package:image/image.dart';

class ImageUtils {
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
