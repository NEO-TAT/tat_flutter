import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/config/app_config.dart';
import 'package:flutter_app/src/file/file_store.dart';
import 'package:flutter_app/ui/other/my_toast.dart';

class DocumentUtils {
  static const platform =
      const MethodChannel(AppConfig.method_channel_save_name);

  static Future<String> _getPath() => platform.invokeMethod<String>("get_path");

  static Future<bool> _choiceFolder() => platform.invokeMethod("choice_folder");

  static Future<dynamic> choiceFolder({int saveMode}) async {
    if (Platform.isAndroid) {
      String directory;
      if (await _isSupportSAF()) {
        MyToast.show("SAF");
        bool result = await _choiceFolder();
        if (result) {
          directory = await _getPath();
        } else {
          return null;
        }
      } else {
        directory = await FilePicker.platform.getDirectoryPath();
      }
      Log.d(directory);
      if (directory == "/" || directory == null) {
        MyToast.show(R.current.selectDirectoryFail);
        return null;
      } else {
        try {
          await Directory(directory + "/TATFileAccessTest").create();
          await Directory(directory + "/TATFileAccessTest").delete();
          await FileStore.setFilePath(directory);
          return directory;
        } catch (e) {
          MyToast.show(R.current.selectDirectoryFail);
          return null;
        }
      }
    }
    return null;
  }

  static Future<bool> _isSupportSAF() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt > 29;
    } else {
      return false;
    }
  }
}
