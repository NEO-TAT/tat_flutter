import 'dart:convert';
import 'dart:io';

import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/connector/core/ConnectorParameter.dart';
import 'package:flutter_app/src/connector/core/DioConnector.dart';
import 'package:flutter_app/src/update/GithubAPIJson.dart';
import 'package:package_info/package_info.dart';

class UpdateDetail {
  String newVersion;
  String detail;
  String url;
}

class AppUpdate {
  static Future<UpdateDetail> checkUpdate() async {
    String androidCheckUrl =
        "https://api.github.com/repos/morris13579/NTUTCourseHelper-Flutter/releases/latest";
    if (Platform.isAndroid) {
      ConnectorParameter parameter = ConnectorParameter(androidCheckUrl);
      String result = await DioConnector.instance.getDataByGet(parameter);
      GithubAPIJson githubAPIJson = GithubAPIJson.fromJson(json.decode(result));
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      List<int> nowVersion = List();
      List<int> newVersion = List();
      for (String i in packageInfo.version.split(".")) {
        nowVersion.add(int.parse(i));
      }
      for (String i in githubAPIJson.tagName.split(".")) {
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
        updateDetail.url =  githubAPIJson.assets[0].browserDownloadUrl;
        updateDetail.detail = githubAPIJson.body;
        return updateDetail;
      }
    }
    return null;
  }

  static Future<String> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }
}
