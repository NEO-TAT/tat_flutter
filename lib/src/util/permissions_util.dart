import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsUtil {
  /// Checks if the APP can access to the file sys on the current device.
  static Future<bool> checkHasAosStoragePermission() async {
    if (Platform.isIOS) return true;
    assert(Platform.isAndroid, 'The platform most be either aos or ios.');

    final deviceInfoPlugin = DeviceInfoPlugin();
    final androidSdkVersion = (await deviceInfoPlugin.androidInfo).version.sdkInt;

    // On Android 10+ (API 29+), app-scoped storage (getExternalStorageDirectory)
    // does not require any runtime permissions.
    if (androidSdkVersion >= 29) {
      return true;
    }

    // On older Android versions, WRITE_EXTERNAL_STORAGE is needed.
    final status = await Permission.storage.request();
    return status.isGranted;
  }
}
