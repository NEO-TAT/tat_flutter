import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsUtil {
  /// Checks if the APP can access to the file sys on the current device.
  static Future<bool> checkHasAosStoragePermission() async {
    // On iOS, the permission is managed by xcode project config.
    if (Platform.isIOS) return true;
    assert(Platform.isAndroid, 'The platform most be either aos or ios.');

    final deviceInfoPlugin = DeviceInfoPlugin();
    final androidSdkVersion = (await deviceInfoPlugin.androidInfo).version.sdkInt;
    final requiredPermissions = <Permission>[];

    // About the new `Granular media permissions` policy:
    // Above Android API 33, the permission of storage is split into image/videos and music/audio.
    // Which means we can't request the `READ_EXTERNAL_STORAGE`.
    // And since the `permission_handler v10.2.0` still not support the new policy,
    // we have to request the separate permissions.
    // Please refer to https://developer.android.com/about/versions/13/behavior-changes-13#granular-media-permissions
    if (androidSdkVersion >= 33) {
      requiredPermissions.addAll([
        Permission.videos,
        Permission.audio,
      ]);
    } else {
      requiredPermissions.addAll([
        Permission.storage,
      ]);
    }

    await requiredPermissions.request();
    final determineResult = await Future.wait(requiredPermissions.map((permission) => permission.isGranted));

    // Since the requiredPermissions is a list, user can choose to grant or deny any of them.
    // So we have to check if any of them (instead of `every`) is granted.
    // This depends on all the permissions in the list are able to make the App
    // access the device's storage once they've been granted.
    return determineResult.any((permission) => permission);
  }
}
