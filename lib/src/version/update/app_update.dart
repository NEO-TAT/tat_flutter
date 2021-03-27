import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/config/app_link.dart';
import 'package:flutter_app/src/model/remote_config/remote_config_version_info.dart';
import 'package:flutter_app/src/util/remote_config_utils.dart';
import 'package:flutter_app/ui/other/my_toast.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';
import 'package:sprintf/sprintf.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';

class AppUpdate {
  static Future<bool> checkUpdate() async {
    try {
      RemoteConfigVersionInfo config =
          await RemoteConfigUtils.getVersionConfig();
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      Version currentVersion = Version.parse(packageInfo.version);
      Version latestVersion = Version.parse(config.last.version);
      bool needUpdate = latestVersion > currentVersion;
      if (needUpdate) {
        _showUpdateDialog(config);
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  static Future<String> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  static void _showUpdateDialog(RemoteConfigVersionInfo value) async {
    String title =
        sprintf("%s %s", [R.current.findNewVersion, value.last.version]);

    Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              if (value.isFocusUpdate) ...[
                Text(R.current.isFocusUpdate),
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                )
              ],
              Text(value.lastVersionDetail),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(R.current.cancel),
            onPressed: () {
              Get.back<bool>(result: false);
            },
          ),
          TextButton(
            child: Text(R.current.update),
            onPressed: () {
              Get.back<bool>(result: true);
              _openAppStore();
            },
          ),
        ],
      ),
      useRootNavigator: false,
      barrierDismissible: false, // user must tap button!
    );
    if (value.isFocusUpdate) {
      MyToast.show(R.current.appWillClose);
      await Future.delayed(Duration(seconds: 1));
      SystemNavigator.pop();
      exit(0);
    }
  }

  static void _openAppStore() async {
    String url = AppLink.storeLink;
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
