import 'dart:io';

class PermissionsUtil {
  /// Checks if the APP can access to the file sys on the current device.
  /// Since the app uses getExternalStorageDirectory() (app-scoped storage),
  /// no runtime permissions are required on any supported Android version.
  static Future<bool> checkHasAosStoragePermission() async {
    if (Platform.isIOS) return true;
    assert(Platform.isAndroid, 'The platform must be either Android or iOS.');
    return true;
  }
}
