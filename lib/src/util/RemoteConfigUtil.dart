import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_app/src/model/remoteconfig/RemoteConfigVersionInfo.dart';

class RemoteConfigUtil {
  RemoteConfig _remoteConfig;

  static String versionConfigKey = "version_config";

  Future<void> init() async {
    _remoteConfig = await RemoteConfig.instance;
  }

  Future<RemoteConfigVersionInfo> getVersionConfig() {
    return json.decode(_remoteConfig.getString(versionConfigKey));
  }
}
