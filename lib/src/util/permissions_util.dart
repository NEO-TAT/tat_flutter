// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class PermissionsUtil {
  /// Checks if the APP can access to the file sys on the current device.
  ///
  /// If it can not access to, an External Storage (id = 15) warning will occurred.
  /// So please check if the androidManifest.xml has the following permission declarations:
  /// - uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
  /// - uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
  static Future<bool> checkHasAosStoragePermission() async {
    if (Platform.isIOS) return true;
    assert(Platform.isAndroid, 'The platform most be either aos or ios.');

    final storagePermissionStatus = await Permission.storage.status;
    if (storagePermissionStatus != PermissionStatus.granted) {
      final requestedPermissions = await [Permission.storage].request();
      return requestedPermissions[Permission.storage] == PermissionStatus.granted;
    }

    return true;
  }
}