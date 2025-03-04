import 'package:flutter_app/src/util/remote_config_util.dart';

class AppConfig {
  static const appName = "TAT";
  static const methodChannelName = "tat/global";

  // Only for android use.
  static final androidChromeIncognitoFlagSetupPageUrl = RemoteConfigUtil.getAndroidIncognitoSetupGuidePageUrl();
}
