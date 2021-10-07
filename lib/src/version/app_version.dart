import 'package:tat/debug/log/log.dart';
import 'package:tat/src/store/model.dart';
import 'package:tat/src/util/remote_config_utils.dart';
import 'package:tat/src/version/update/app_update.dart';

class APPVersion {
  static void initAndCheck() async {
    final config = await RemoteConfigUtils.getVersionConfig();
    if (!config.isFocusUpdate!) {
      if (!Model.instance.autoCheckAppUpdate ||
          !Model.instance.getFirstUse(Model.appCheckUpdate) ||
          Model.instance.getAccount().isEmpty) return;
    }

    Model.instance.setAlreadyUse(Model.appCheckUpdate);
    await check();
    checkIFAPPUpdate();
  }

  static Future<bool> check() async {
    Log.d("Start check update");
    final value = await AppUpdate.checkUpdate();
    return value;
  }

  static Future<void> checkIFAPPUpdate() async {
    final version = await AppUpdate.getAppVersion();
    final preVersion = await Model.instance.getVersion();
    Log.d(" preVersion: $preVersion \n version: $version");
    if (preVersion != version) {
      await Model.instance.setVersion(version);
      updateVersionCallback();
    }
  }

  static void updateVersionCallback() {
    // TODO implementation
  }
}
