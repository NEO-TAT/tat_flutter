//
//  FileStore.dart
//  北科課程助手
//  文件儲存位置
//  Created by morris13579 on 2020/02/12.
//  Copyright © 2020 morris13579 All rights reserved.
//

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/util/PermissionsUtil.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileStore {
  static const storeKey = "downloadPath";

  static Future<String> findLocalPath(BuildContext context) async {
    final hasStoragePermission = await PermissionsUtil.checkHasAosStoragePermission(context);
    if (!hasStoragePermission) {
      MyToast.show(R.current.noPermission);
      return '';
    }

    final directory = await _getFilePath() ?? Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationSupportDirectory();
    return directory.path;
  }

  static Future<String> getDownloadDir(BuildContext context, String name) async {
    final _localPath = (await findLocalPath(context)) + '/$name';
    final savedDir = Directory(_localPath);
    final hasExisted = await savedDir.exists();

    if (!hasExisted) {
      savedDir.create();
    }

    return savedDir.path;
  }

  static Future<bool> setFilePath(String directory) async {
    if (directory != null) {
      final pref = await SharedPreferences.getInstance();
      pref.setString(storeKey, base64Encode(directory.codeUnits));
      return true;
    }

    return false;
  }

  static Future<Directory> _getFilePath() async {
    final pref = await SharedPreferences.getInstance();
    final path = pref.getString(storeKey);
    if (path != null && path.isNotEmpty) {
      return Directory(base64Decode(path).toString());
    }

    return null;
  }
}
