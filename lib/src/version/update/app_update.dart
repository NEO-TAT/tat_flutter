// ignore_for_file: import_of_legacy_library_into_null_safe
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/src/config/app_link.dart';
import 'package:flutter_app/src/model/remoteconfig/remote_config_version_info.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/util/remote_config_util.dart';
import 'package:flutter_app/ui/other/my_toast.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';
import 'package:sprintf/sprintf.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';

class AppUpdate {
  static Future<bool> checkUpdate({RemoteConfigVersionInfo? versionConfig}) async {
    try {
      versionConfig = versionConfig ?? await RemoteConfigUtil.getVersionConfig();

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = Version.parse(packageInfo.version);
      final latestVersion = Version.parse(versionConfig.last.version);
      final needUpdate = latestVersion > currentVersion;

      if (needUpdate) {
        _showUpdateDialog(versionConfig);
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
    final title = sprintf("%s %s", [R.current.findNewVersion, value.last.version]);

    await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              if (value.isFocusUpdate) ...[
                Text(R.current.isFocusUpdate),
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                )
              ],
              Text(value.lastVersionDetail),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text(R.current.cancel),
            onPressed: () => Get.back<bool>(result: false),
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
    if (value.isFocusUpdate) {
      MyToast.show(R.current.appWillClose);
      await Future.delayed(const Duration(seconds: 1));
      SystemNavigator.pop();
      exit(0);
    }
  }

  static void _openAppStore() async {
    final url = AppLink.storeUrlString;
    if (await canLaunchUrl(Uri.parse(url))) {
      await canLaunchUrl(Uri.parse(url));
    }
  }
}
