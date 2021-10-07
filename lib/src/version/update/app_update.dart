import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';
import 'package:sprintf/sprintf.dart';
import 'package:tat/src/R.dart';
import 'package:tat/src/config/app_link.dart';
import 'package:tat/src/model/remote_config/remote_config_version_info.dart';
import 'package:tat/src/util/remote_config_utils.dart';
import 'package:tat/ui/other/my_toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';

class AppUpdate {
  static Future<bool> checkUpdate() async {
    try {
      final config = await RemoteConfigUtils.getVersionConfig();
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = Version.parse(packageInfo.version);
      final latestVersion = Version.parse(config.last!.version);
      final needUpdate = latestVersion > currentVersion;

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
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  static void _showUpdateDialog(RemoteConfigVersionInfo value) async {
    final title =
        sprintf("%s %s", [R.current.findNewVersion, value.last!.version]);

    Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              if (value.isFocusUpdate!) ...[
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
      barrierDismissible: false, // user must tap button!
    );
    if (value.isFocusUpdate!) {
      MyToast.show(R.current.appWillClose);
      await Future.delayed(Duration(seconds: 1));
      SystemNavigator.pop();
      exit(0);
    }
  }

  static void _openAppStore() async {
    final url = AppLink.storeLink;
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
