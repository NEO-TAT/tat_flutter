import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/config/AppLink.dart';
import 'package:flutter_app/src/model/remoteconfig/RemoteConfigVersionInfo.dart';
import 'package:flutter_app/src/util/RemoteConfigUtil.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:package_info/package_info.dart';
import 'package:sprintf/sprintf.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';

class AppUpdate {
  static Future<bool> checkUpdate(BuildContext context) async {
    try {
      RemoteConfigVersionInfo config =
          await RemoteConfigUtil.getVersionConfig();
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      Version currentVersion = Version.parse(packageInfo.version);
      Version latestVersion = Version.parse(config.lastVersion);
      bool needUpdate = latestVersion > currentVersion;
      if (needUpdate) {
        _showUpdateDialog(context, config);
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

  static void _showUpdateDialog(
      BuildContext context, RemoteConfigVersionInfo value) async {
    bool v = await showDialog<bool>(
      useRootNavigator: false,
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        String title =
            sprintf("%s %s", [R.current.findNewVersion, value.lastVersion]);
        return AlertDialog(
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
                _openAppStore();
              },
            ),
          ],
        );
      },
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
