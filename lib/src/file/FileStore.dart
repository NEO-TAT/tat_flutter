//
//  FileStore.dart
//  北科課程助手
//  文件儲存位置
//  Created by morris13579 on 2020/02/12.
//  Copyright © 2020 morris13579 All rights reserved.
//

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/util/PermissionsUtil.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:path_provider/path_provider.dart';

class FileStore {
  static Future<String> findLocalPath(BuildContext context) async {
    bool checkPermission = await PermissionsUtil.check(context);
    if (!checkPermission) {
      MyToast.show(R.current.noPermission);
      return "";
    }
    final directory = Theme.of(context).platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationSupportDirectory();
    return directory.path;
  }

  static Future<String> getDownloadDir(
      BuildContext context, String name) async {
    var _localPath = (await findLocalPath(context)) + '/$name';
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    return savedDir.path;
  }
}
