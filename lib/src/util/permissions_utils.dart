import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsUtils {
  static Future<bool> check(BuildContext context) async {

    if (Theme.of(context).platform == TargetPlatform.android) {
      final permission = await Permission.storage.status;

      if (permission != PermissionStatus.granted) {
        final permissions = await [
          Permission.storage,
        ].request();

        if (permissions[Permission.storage] == PermissionStatus.granted) {
          return true;
        }

      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }
}
