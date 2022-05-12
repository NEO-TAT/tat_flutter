import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_app/src/model/remoteconfig/remote_config_version_info.dart';

class RemoteConfigUtil {
  static FirebaseRemoteConfig _remoteConfig;

  static const versionConfigKey = "version_config";

  static Future<void> init() async {
    _remoteConfig = FirebaseRemoteConfig.instance;
  }

  static Future<RemoteConfigVersionInfo> getVersionConfig() async {
    await _remoteConfig.fetch();
    await _remoteConfig.activate();
    final result = _remoteConfig.getString(versionConfigKey);
    return RemoteConfigVersionInfo.fromJson(json.decode(result));
  }
}
