import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/core/DioConnector.dart';
import 'package:flutter_app/src/costants/AppLink.dart';
import 'package:flutter_app/src/file/FileDownload.dart';
import 'package:flutter_app/src/file/MyDownloader.dart';
import 'package:flutter_app/src/json/GithubFileAPIJson.dart';
import 'package:flutter_app/src/notifications/Notifications.dart';
import 'package:flutter_app/src/update/AppUpdate.dart';
import 'package:flutter_app/src/util/FileUtils.dart';
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
  static final String flutterState = "flutter_state";
  static final String patchVersion = "patch_version"; //目前版本
  static final String patchNetWorkVersion = "patch_network"; //目前版本
  static final String hotfixFileName = "hotfix.so";

  static Future<void> hotFixSuccess() async {
    var pref = await SharedPreferences.getInstance();
    pref.setBool(flutterState, true); //告訴bootloader activity flutter正常啟動
  }

  static Future<void> deleteHotFix() async {
    var pref = await SharedPreferences.getInstance();
    pref.remove(flutterState); //告訴bootloader 需要刪除補丁
  }

  static Future<String> _getUpdatePath() async {
    Directory dir = await getExternalStorageDirectory();
    return dir.path;
  }

  static Future<int> getPatchVersion() async {
    //更新的版本
    var pref = await SharedPreferences.getInstance();
    int version = pref.getInt(patchVersion);
    version = version ?? 0;
    return version;
  }

  static Future<void> getNetWorkPatchVersion(int version) async {
    //更新的版本
    var pref = await SharedPreferences.getInstance();
    pref.setInt(patchNetWorkVersion, version);
  }

  static Future<PatchDetail> checkPatchVersion() async {
    if (!Platform.isAndroid) {
      return null;
    }
    int version = await getPatchVersion();
    String appVersion = await AppUpdate.getAppVersion();
    String url = sprintf(githubLink, [appVersion]);
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
    getNetWorkPatchVersion(int.parse(value.newVersion));
    ReceivedNotification receivedNotification = ReceivedNotification(
        title: "下載補丁中", body: R.current.prepareDownload, payload: null); //通知窗訊息
    CancelToken cancelToken; //取消下載用
    ProgressCallback onReceiveProgress; //下載進度回調
    await Notifications.instance
        .showIndeterminateProgressNotification(receivedNotification);
    //顯示下載進度通知窗

    int nowSize = 0;
    onReceiveProgress = (int count, int total) async {
      receivedNotification.body = FileUtils.formatBytes(count, 2);
      if ((nowSize + 1024 * 128) > count && nowSize != 0) {
        //128KB顯示一次
        return;
      }
      nowSize = count;
      if (count < total) {
        Notifications.instance.showProgressNotification(
            receivedNotification, 100, (count * 100 / total).round()); //顯示下載進度
      } else {
        Notifications.instance.showIndeterminateProgressNotification(
            receivedNotification); //顯示下載進度
      }
    };
    DioConnector.instance.download(
      value.url,
      (Headers responseHeaders) {
        return filePath + "/$hotfixFileName";
      },
      progressCallback: onReceiveProgress,
      cancelToken: cancelToken,
    ).whenComplete(
      () async {
        //顯示下載萬完成通知窗
        await Notifications.instance
            .cancelNotification(receivedNotification.id);
        showDialog<void>(
          useRootNavigator: false,
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            String title = "下載完成，將重啟完成更新";
            return AlertDialog(
              title: Text(title),
              actions: <Widget>[
                FlatButton(
                  child: Text(R.current.sure),
                  onPressed: () {
                    Navigator.of(context).pop();
                    SystemNavigator.pop();  //關閉app
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
