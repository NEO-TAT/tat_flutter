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
import 'package:flutter_app/src/costants/Constants.dart';
import 'package:flutter_app/src/json/GithubFileAPIJson.dart';
import 'package:flutter_app/src/notifications/Notifications.dart';
import 'package:flutter_app/src/util/FileUtils.dart';
import 'package:flutter_app/src/version/update/AppUpdate.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprintf/sprintf.dart';
import '../VersionConfig.dart';

class PatchDetail {
  String platform;
  String newVersion;
  String detail;
  String url;
}

class AppHotFix {
  static final String flutterStateKey =
      "flutter_state"; //需寫入東西，不然bootloaderActivity會刪除
  static final String patchVersionKey = "patch_version"; //目前版本
  static final String devPatchChannelKey = "dev_patch_channel";
  static final String hotfixFileName = "hotfix.so";
  static final String hotfixDownloadCacheName = "cache.so";
  static SharedPreferences pref;

  static Future<void> getInstance() async {
    pref = await SharedPreferences.getInstance();
  }

  static String get githubLink {
    return (inDevMode) ? AppLink.appPatchCheckDev : AppLink.appPatchCheckMaster;
  }

  static bool get inDevMode {
    bool v = pref.getBool(devPatchChannelKey);
    if (v == null) {
      setDevMode(false);
    }
    return pref.getBool(devPatchChannelKey);
  }

  static void setDevMode(bool mode) {
    pref.setBool(devPatchChannelKey, mode);
  }

  static Future<void> hotFixSuccess(BuildContext context) async {
    if (Platform.isAndroid) {
      int beforeVersion = await _getBeforePatchVersion();
      int nowVersion = await getPatchVersion();
      String body;
      if (nowVersion > beforeVersion) {
        body = sprintf("%s v%d", [R.current.patchUpdateComplete, nowVersion]);
      } else if (nowVersion < beforeVersion) {
        body = sprintf("%s v%d", [R.current.patchUpdateFail, nowVersion]);
      }
      _setPatchVersion(nowVersion);
      if (context != null && body != null) {
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
      pref.setBool(flutterStateKey, true); //告訴bootloader activity flutter正常啟動
    }
  }

  static Future<void> deleteHotFix() async {
    if (Platform.isAndroid) {
      pref.remove(flutterStateKey); //告訴bootloader 需要刪除補丁
      await Future.delayed(Duration(seconds: 2));
      closeApp();
      //getToCloseApp();
    }
  }

  static Future<String> _getUpdatePath() async {
    Directory dir = await getExternalStorageDirectory();
    return dir.path;
  }

  static Future<void> _setPatchVersion(int version) async {
    pref.setInt(patchVersionKey, version);
  }

  static Future<int> _getBeforePatchVersion() async {
    int version = pref.getInt(patchVersionKey);
    version = version ?? 0;
    return version;
  }

  static Future<int> getPatchVersion() async {
    //更新的版本
    return VersionConfig.patchVersion;
  }

  static Future<String> getData(String url) async {
    try {
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

  static Future<List<String>> getSupportABis() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      //IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      String log = "";
      log += "supported32BitAbis : ${androidInfo.supported32BitAbis} \n";
      log += "supported64BitAbis : ${androidInfo.supported64BitAbis} \n";
      log += "supportedAbis : ${androidInfo.supportedAbis}";
      Log.d(log);
      return androidInfo.supportedAbis;
    } else {
      return List();
    }
  }

  static Future<PatchDetail> checkPatchVersion() async {
    if (VersionConfig.enableHotfix) {
      return null;
    }
    if (Platform.isAndroid) {
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
        List<String> supportedABis = await getSupportABis();
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
            } else if (supportedABis.contains(i.name)) {
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

  static void closeApp() async {
    //goToCloseApp();
    //SystemNavigator.pop();
    const platform = const MethodChannel(Constants.methodChannelName);
    platform.invokeMethod('restart_app');
  }

  static void goToCloseApp() async {
    if (Platform.isAndroid) {
      String packageName = AppLink.androidAppPackageName;
      final AndroidIntent intent = AndroidIntent(
        action: 'action_application_details_settings',
        data:
            'package:$packageName', // replace com.example.app with your applicationId
      );
      await intent.launch();
    }
  }

  static void downloadPatch(BuildContext context, PatchDetail value) async {
    String filePath = await _getUpdatePath();
    ReceivedNotification receivedNotification = ReceivedNotification(
        title: R.current.downloadingPatch,
        body: R.current.prepareDownload,
        payload: null); //通知窗訊息
    CancelToken cancelToken; //取消下載用
    ProgressCallback onReceiveProgress; //下載進度回調
    await Notifications.instance.showIndeterminateProgressNotification(
        receivedNotification); //顯示下載進度通知窗
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
        return path.join(filePath, hotfixDownloadCacheName);
      },
      progressCallback: onReceiveProgress,
      cancelToken: cancelToken,
    ).whenComplete(
      () async {
        //顯示下載萬完成通知窗
        await Notifications.instance
            .cancelNotification(receivedNotification.id);
        File file = File(path.join(filePath, hotfixDownloadCacheName)); //確保下載完成
        await file.rename(path.join(filePath, hotfixFileName));
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
                    closeApp();
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
