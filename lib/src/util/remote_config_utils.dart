import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:tat/src/model/remote_config/remote_config_version_info.dart';

class RemoteConfigUtils {
  static RemoteConfig _remoteConfig;

  static String versionConfigKey = "version_config";

  static Future<void> init() async {
    _remoteConfig = RemoteConfig.instance;
    _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: Duration(hours: 1),
        minimumFetchInterval: Duration(hours: 1),
      ),
    );
  }

  static Future<RemoteConfigVersionInfo> getVersionConfig() async {
    await _remoteConfig.fetchAndActivate();
    String result = _remoteConfig.getString(versionConfigKey);
    return RemoteConfigVersionInfo.fromJson(json.decode(result));
  }
}
