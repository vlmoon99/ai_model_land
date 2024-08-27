import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class PlatformInfo {
  DeviceInfoPlugin deviceInfo;

  PlatformInfo({required this.deviceInfo});

  factory PlatformInfo.defaultInstance() {
    return PlatformInfo(deviceInfo: DeviceInfoPlugin());
  }

  Future<Map<String, dynamic>>
      checkPlatformGPUAcceleratorPossibilities() async {
    Map<String, dynamic> deviceData = {};
    if (kIsWeb) {
      WebBrowserInfo info = await deviceInfo.webBrowserInfo;
      deviceData['App Name'] = info.appName;
    } else {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          {
            AndroidDeviceInfo info = await deviceInfo.androidInfo;
            deviceData['MODEL'] = info.model;
          }
        case TargetPlatform.iOS:
          {
            IosDeviceInfo info = await deviceInfo.iosInfo;
            deviceData['MODEL'] = info.model;
          }
        default:
          throw Exception("Your platform is not supported by this library");
      }
    }

    return deviceData;
  }
}
