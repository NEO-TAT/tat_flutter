import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/core/ConnectorParameter.dart';
import 'package:flutter_app/src/connector/core/DioConnector.dart';
import 'package:flutter_app/src/costants/AppLink.dart';
import 'package:flutter_app/src/json/GithubAPIJson.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:package_info/package_info.dart';
import 'package:sprintf/sprintf.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateDetail {
  String newVersion;
  String detail;
  String url;
}

class AppUpdate {
  static Future<UpdateDetail> checkUpdate() async {
    String androidCheckUrl = AppLink.appUpdateCheck;
    if (Platform.isAndroid) {
      try {
        ConnectorParameter parameter = ConnectorParameter(androidCheckUrl);
        String result = await DioConnector.instance.getDataByGet(parameter);
        GithubAPIJson githubAPIJson =
            GithubAPIJson.fromJson(json.decode(result));
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        List<int> nowVersion = List();
        List<int> newVersion = List();
        for (String i in packageInfo.version.split(".")) {
          nowVersion.add(int.parse(i));
        }
        for (String i in githubAPIJson.name.split(".")) {
          //利用name解析版本名稱，如解析失敗不會跳出
          newVersion.add(int.parse(i));
        }
        bool needUpdate = false;
        for (int i = 0; i < nowVersion.length; i++) {
          if (newVersion[i] > nowVersion[i]) {
            needUpdate = true;
            break;
          }
        }
        if (needUpdate) {
          UpdateDetail updateDetail = UpdateDetail();
          updateDetail.newVersion = githubAPIJson.tagName;
          try {
            updateDetail.url = githubAPIJson.assets[0].browserDownloadUrl;
          } catch (e) {
            updateDetail.url = "";
          }
          updateDetail.detail = githubAPIJson.body;
          return updateDetail;
        }
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<String> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  static void showUpdateDialog(BuildContext context, UpdateDetail value) {
    showDialog<void>(
      useRootNavigator: false,
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        String title =
            sprintf("%s %s", [R.current.findNewVersion, value.newVersion]);
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
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text("github"),
              onPressed: () {
                launch(AppLink.gitHubReleases);
              },
            ),
            FlatButton(
              child: Text(R.current.update),
              onPressed: () {
                Navigator.of(context).pop();
                /*
                FileStore.findLocalPath(context).then(
                  (filePath) {
                    FlutterDownloader.enqueue(
                            url: value.url, savedDir: filePath)
                        .then(
                      (id) {
                        MyDownloader.addCallBack(id, _downloadCompleteCallBack);
                        downloadTaskId = id;
                        //FlutterDownloader.open(taskId: id);
                      },
                    );
                  },
                );
                 */
                _openAppStore();
              },
            ),
          ],
        );
      },
    );
  }

  static void _openAppStore() async {
    String url = AppLink.storeLink;
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  static String downloadTaskId;

  static void _downloadCompleteCallBack() {
    FlutterDownloader.open(taskId: downloadTaskId);
  }
}
