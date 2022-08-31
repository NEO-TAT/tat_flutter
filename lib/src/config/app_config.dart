import 'package:flutter_app/src/util/remote_config_util.dart';

class AppConfig {
  static const appName = "TAT";
  static const methodChannelName = "tat/global";
  static final zuvioRollCallFeatureEnabled = RemoteConfigUtil.getFeatureToggleZuvioRollCallFlag();
}
