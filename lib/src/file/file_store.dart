//  北科課程助手

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tat/src/R.dart';
import 'package:tat/src/util/permissions_utils.dart';
import 'package:tat/ui/other/my_toast.dart';

class FileStore {
  static String storeKey = "downloadPath";

  static Future<String> findLocalPath(BuildContext context) async {
    final checkPermission = await PermissionsUtils.check(context);

    if (!checkPermission) {
      MyToast.show(R.current.noPermission);
      return "";
    }

    Directory? directory = await _getFilePath();
    if (directory == null) {
      directory = Theme.of(context).platform == TargetPlatform.android
          ? await getExternalStorageDirectory()
          : await getApplicationSupportDirectory();
    }

    return directory!.path;
  }

  static Future<String> getDownloadDir(
    BuildContext context,
    String name,
  ) async {
    final _localPath = (await findLocalPath(context)) + '/$name';
    final savedDir = Directory(_localPath);
    final hasExisted = await savedDir.exists();

    if (!hasExisted) {
      savedDir.create();
    }

    return savedDir.path;
  }

  static Future<bool> setFilePath(String? directory) async {
    if (directory != null) {
      final pref = await SharedPreferences.getInstance();
      pref.setString(storeKey, directory);

      return true;
    } else {
      return false;
    }
  }

  static Future<Directory?> _getFilePath() async {
    final pref = await SharedPreferences.getInstance();
    final path = pref.getString(storeKey);

    if (path != null && path.isNotEmpty) {
      return Directory(path);
    } else {
      return null;
    }
  }
}
