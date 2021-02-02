import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_app/src/model/remoteconfig/RemoteConfigVersionInfo.dart';

class RemoteConfigUtil {
  static RemoteConfig _remoteConfig;

  static String versionConfigKey = "version_config";

  static Future<void> init() async {
    _remoteConfig = await RemoteConfig.instance;
  }

  static Future<RemoteConfigVersionInfo> getVersionConfig() async {
    await _remoteConfig.fetch(expiration: Duration(hours: 1));
    await _remoteConfig.activateFetched();
    String result = _remoteConfig.getString(versionConfigKey);
    return RemoteConfigVersionInfo.fromJson(json.decode(result));
  }
}
