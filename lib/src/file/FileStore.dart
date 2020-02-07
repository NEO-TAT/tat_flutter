import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/permission/Permission.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:path_provider/path_provider.dart';

class FileStore {
  static Future<String> findLocalPath(BuildContext context) async {
    bool checkPermission = await Permission.check(context);
    if (!checkPermission) {
      MyToast.show( "沒有權限" );
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
