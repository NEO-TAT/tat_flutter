import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/core/DioConnector.dart';
import 'package:flutter_app/src/costants/AppLink.dart';
import 'package:flutter_app/src/file/FileDownload.dart';
import 'package:flutter_app/src/file/MyDownloader.dart';
import 'package:flutter_app/src/json/GithubFileAPIJson.dart';
import 'package:flutter_app/src/update/AppUpdate.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprintf/sprintf.dart';

class PatchDetail {
  String newVersion;
  String detail;
  String url;
}

class AppHotFix {
  static final String githubLink = AppLink.appPatchCheck;

  static Future<String> _getUpdatePath() async {
    Directory dir = await getExternalStorageDirectory();
    return dir.path;
  }

  static Future<int> getPatchVersionNow() async {
    //實際版本
    var pref = await SharedPreferences.getInstance();
    int version = pref.getInt("patch_version_now");
    version = version ?? 0;
    return version;
  }

  static Future<int> getPatchVersion() async {
    //更新的版本
    var pref = await SharedPreferences.getInstance();
    int version = pref.getInt("patch_version");
    version = version ?? 0;
    return version;
  }

  static Future<void> setPatchVersion(int version) async {
    var pref = await SharedPreferences.getInstance();
    await pref.setInt("patch_version", version);
  }

  static Future<PatchDetail> checkPatchVersion() async {
    if (!Platform.isAndroid) {
      return null;
    }
    int version = await getPatchVersion();
    String appVersion = await AppUpdate.getAppVersion();
    String url = sprintf(githubLink , [appVersion]);
    Log.d(version.toString());
    Log.d(url);
    Response response = await DioConnector.instance.dio
        .get(url, options: Options(responseType: ResponseType.plain));
    String result = response.toString();
    if (response.statusCode == HttpStatus.ok) {
      //200
      List<GithubFileAPIJson> name =
          getGithubFileAPIJsonList(json.decode(result));
      int maxVersion = version;
      GithubFileAPIJson newVersion;
      for (GithubFileAPIJson i in name) {
        int v = int.parse(i.name.split(".")[0]);
        if (v > maxVersion) {
          maxVersion = v;
          newVersion = i;
        }
      }
      if (newVersion != null) {
        //Log.d(maxVersion.toString());
        //Log.d(newVersion.downloadUrl);
        PatchDetail detail = PatchDetail();
        detail.newVersion = maxVersion.toString();
        detail.url = newVersion.downloadUrl;
        detail.detail = "更新後重新開啟套用";
        return detail;
      }
    }
    return null;
  }

  static Future<bool> showUpdateDialog(
      BuildContext context, PatchDetail value) async {
    bool v = await showDialog<bool>(
      useRootNavigator: false,
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        String title = sprintf("%s %s", ["發現新補丁", value.newVersion]);
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(value.detail),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(R.current.cancel),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FlatButton(
              child: Text(R.current.update),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
    return v;
  }

  static void downloadPatch(BuildContext context, PatchDetail value) async {
    String filePath = await _getUpdatePath();
    await DioConnector.instance.dio
        .download(value.url, filePath + "/hotfixed.so");
    setPatchVersion(int.parse(value.newVersion));
    showDialog<void>(
      useRootNavigator: false,
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        String title = "下載完成，手動重啟完成更新";
        return AlertDialog(
          title: Text(title),
          actions: <Widget>[
            FlatButton(
              child: Text(R.current.sure),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
