import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigUtil {
  RemoteConfig _remoteConfig;

  Future<void> init() async {
    _remoteConfig = await RemoteConfig.instance;
    _remoteConfig.getAll();
  }
}
