import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/model/remote_config/remote_config_version_info.dart';
import 'package:flutter_app/src/store/model.dart';
import 'package:flutter_app/src/util/remote_config_utils.dart';
import 'package:flutter_app/src/version/update/app_update.dart';

class APPVersion {
  static void initAndCheck() async {
    RemoteConfigVersionInfo config = await RemoteConfigUtils.getVersionConfig();
    if (!config.isFocusUpdate) {
      if (!Model.instance.autoCheckAppUpdate ||
          !Model.instance.getFirstUse(Model.appCheckUpdate) ||
          Model.instance.getAccount().isEmpty) return;
    }
    Model.instance.setAlreadyUse(Model.appCheckUpdate);
    await check();
    checkIFAPPUpdate(); //檢查是否有更新
  }

  static Future<bool> check() async {
    Log.d("Start check update");
    bool value = await AppUpdate.checkUpdate();
    return value;
  }

  static Future<void> checkIFAPPUpdate() async {
    //檢查是否有更新APP
    String version = await AppUpdate.getAppVersion();
    String preVersion = await Model.instance.getVersion();
    Log.d(" preVersion: $preVersion \n version: $version");
    if (preVersion != version) {
      await Model.instance.setVersion(version);
      updateVersionCallback();
    }
  }

  static void updateVersionCallback() {
    //更新版本後會執行函數
    //用途資料更新...
  }
}
