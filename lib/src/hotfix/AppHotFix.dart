import 'dart:convert';
import 'dart:io';
import 'package:android_intent/android_intent.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/core/DioConnector.dart';
import 'package:flutter_app/src/costants/AppLink.dart';
import 'package:flutter_app/src/json/GithubFileAPIJson.dart';
import 'package:flutter_app/src/notifications/Notifications.dart';
import 'package:flutter_app/src/update/AppUpdate.dart';
import 'package:flutter_app/src/util/FileUtils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprintf/sprintf.dart';

class PatchDetail {
  String platform;
  String newVersion;
  String detail;
  String url;
}

class AppHotFix {
  static final String githubLink = AppLink.appPatchCheck;
  static final String flutterState = "flutter_state";
  static final String patchVersion = "patch_version"; //目前版本
  static final String patchNetWorkVersion = "patch_network"; //目前版本
  static final String bootloaderState = "bootloader_update_state";
  static final String hotfixFileName = "hotfix.so";

  static Future<void> hotFixSuccess(BuildContext context) async {
    if (Platform.isAndroid) {
      var pref = await SharedPreferences.getInstance();
      pref.setBool(flutterState, true); //告訴bootloader activity flutter正常啟動
      if (pref.containsKey(bootloaderState)) {
        bool state = pref.getBool(bootloaderState);
        String body;
        int version = await getPatchVersion();
        if (state) {
          body = "補丁成功升級為v$version";
        } else {
          body = "補丁升級失敗\n已自動降回原始版本:v$version";
        }
        if (context != null) {
          showDialog<void>(
            useRootNavigator: false,
            context: context,
            barrierDismissible: false,
            // user must tap button!
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(body),
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
    }
  }

  static Future<void> deleteHotFix() async {
    if (Platform.isAndroid) {
      var pref = await SharedPreferences.getInstance();
      pref.remove(flutterState); //告訴bootloader 需要刪除補丁
      await Future.delayed(Duration(seconds: 2));
      SystemNavigator.pop();
      //getToCloseApp();
    }
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

  static Future<void> _setNetWorkPatchVersion(int version) async {
    //更新的版本
    var pref = await SharedPreferences.getInstance();
    pref.setInt(patchNetWorkVersion, version);
  }

  static Future<String> getData(String url) async {
    try {
      Log.d(url);
      Response response = await DioConnector.instance.dio.get(
        url,
        options: Options(
          responseType: ResponseType.plain,
          validateStatus: (status) {
            // 關閉狀態檢測
            return status <= 500;
          },
        ),
      );
      String result = response.toString();
      return result;
    } catch (e) {
      throw e;
    }
  }

  static Future<PatchDetail> checkPatchVersion() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.supported32BitAbis}');
      print('Running on ${androidInfo.supported64BitAbis}');
      print('Running on ${androidInfo.supportedAbis}');
      int patchVersion = await getPatchVersion();
      String appVersion = await AppUpdate.getAppVersion();
      String url = sprintf(githubLink, [appVersion]);
      try {
        String result = await getData(url);
        List<GithubFileAPIJson> versionDir =
            getGithubFileAPIJsonList(json.decode(result));
        int maxVersion = patchVersion;
        GithubFileAPIJson newVersion;
        for (GithubFileAPIJson i in versionDir) {
          int v = int.parse(i.name);
          if (v > maxVersion) {
            maxVersion = v;
            newVersion = i;
          }
        }
        if (newVersion != null) {
          result = await getData(newVersion.url);
          PatchDetail patchDetail = PatchDetail();
          patchDetail.newVersion = maxVersion.toString();
          List<GithubFileAPIJson> platformDir =
              getGithubFileAPIJsonList(json.decode(result));
          for (GithubFileAPIJson i in platformDir) {
            if (i.name.contains("README.md")) {
              patchDetail.detail = await getData(i.downloadUrl);
              patchDetail.detail = patchDetail.detail ?? "";
              continue;
            } else if (androidInfo.supportedAbis.contains(i.name)) {
              result = await getData(i.url);
              patchDetail.url =
                  getGithubFileAPIJsonList(json.decode(result))[0].downloadUrl;
              patchDetail.platform = i.name;
              break;
            }
          }
          return patchDetail;
        }
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<bool> showUpdateDialog(
      BuildContext context, PatchDetail value) async {
    bool v = await showDialog<bool>(
      useRootNavigator: false,
      context: context, barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        String title = sprintf("%s v%s\n%s",
            [R.current.findPatchNewVersion, value.newVersion, value.platform]);
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

  /*
  static void getToCloseApp() async {
    if (Platform.isAndroid) {
      String packageName = AppLink.appPackageName;
      final AndroidIntent intent = AndroidIntent(
        action: 'action_application_details_settings',
        data:
            'package:$packageName', // replace com.example.app with your applicationId
      );
      await intent.launch();
    }
  }
   */

  static void downloadPatch(BuildContext context, PatchDetail value) async {
    String filePath = await _getUpdatePath();
    _setNetWorkPatchVersion(int.parse(value.newVersion));

    ReceivedNotification receivedNotification = ReceivedNotification(
        title: R.current.downloadingPatch,
        body: R.current.prepareDownload,
        payload: null); //通知窗訊息
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
          context: context, barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            String title = R.current.patchUpdateDown;
            return AlertDialog(
              title: Text(title),
              actions: <Widget>[
                FlatButton(
                  child: Text(R.current.sure),
                  onPressed: () {
                    Navigator.of(context).pop();
                    SystemNavigator.pop();
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
