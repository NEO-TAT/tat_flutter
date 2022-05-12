import 'dart:convert';
import 'dart:io';

import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/util/permissions_util.dart';
import 'package:flutter_app/ui/other/my_toast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FileStore {
  static const storeKey = "downloadPath";

  static Future<String> findLocalPath() async {
    final hasStoragePermission = await PermissionsUtil.checkHasAosStoragePermission();
    if (!hasStoragePermission) {
      MyToast.show(R.current.noPermission);
      return '';
    }

    final directory = await _getFilePath() ?? Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationSupportDirectory();

    final targetDir = Directory('${directory.path}/TAT');
    final hasExisted = await targetDir.exists();
    if (!hasExisted) {
      targetDir.create();
    }

    return targetDir.path;
  }

  static Future<String> getDownloadDir(String name) async {
    final localPath = '${await findLocalPath()}/$name';
    final savedDir = Directory(localPath);
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
