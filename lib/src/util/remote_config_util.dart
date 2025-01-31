// ignore_for_file: import_of_legacy_library_into_null_safe
import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_app/src/model/remoteconfig/remote_config_version_info.dart';

class RemoteConfigUtil {
  static final _remoteConfig = FirebaseRemoteConfig.instance;

  static const _versionConfigKey = "version_config";
  static const _androidIncognitoSetupGuidePageUrlKey = "android_incognito_setup_guide_page_url";

  static Future<RemoteConfigVersionInfo> getVersionConfig() async {
    await _remoteConfig.fetchAndActivate();
    final result = _remoteConfig.getString(_versionConfigKey);
    return RemoteConfigVersionInfo.fromJson(json.decode(result));
  }

  static Future<String> getAndroidIncognitoSetupGuidePageUrl() async {
    await _remoteConfig.fetchAndActivate();
    return _remoteConfig.getString(_androidIncognitoSetupGuidePageUrlKey);
  }
}
