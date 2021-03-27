//
//  file_store.dart
//  北科課程助手
//  文件儲存位置
//  Created by morris13579 on 2020/02/12.
//  Copyright © 2020 morris13579 All rights reserved.
//

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/util/permissions_utils.dart';
import 'package:flutter_app/ui/other/my_toast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileStore {
  static String storeKey = "downloadPath";

  static Future<String> findLocalPath(BuildContext context) async {
    bool checkPermission = await PermissionsUtils.check(context);
    if (!checkPermission) {
      MyToast.show(R.current.noPermission);
      return "";
    }
    Directory directory = await _getFilePath();
    if (directory == null) {
      directory = Theme.of(context).platform == TargetPlatform.android
          ? await getExternalStorageDirectory()
          : await getApplicationSupportDirectory();
    }
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

  static Future<bool> setFilePath(String directory) async {
    if (directory != null) {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString(storeKey, directory);
      return true;
    } else {
      return false;
    }
  }

  static Future<Directory> _getFilePath() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String path = pref.getString(storeKey);
    if (path != null && path.isNotEmpty) {
      return Directory(path);
    } else {
      return null;
    }
  }
}
