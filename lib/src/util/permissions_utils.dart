//
//  permissions_utils.dart
//  北科課程助手
//
//  Created by morris13579 on 2020/02/12.
//  Copyright © 2020 morris13579 All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsUtils {
  static Future<bool> check(BuildContext context) async {
    // 先對所在平台進行判斷
    if (Theme.of(context).platform == TargetPlatform.android) {
      PermissionStatus permission = await Permission.storage.status;
      if (permission != PermissionStatus.granted) {
        Map<Permission, PermissionStatus> permissions = await [
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
