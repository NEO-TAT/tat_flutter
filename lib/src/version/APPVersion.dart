import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/model/remoteconfig/RemoteConfigVersionInfo.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:flutter_app/src/util/RemoteConfigUtil.dart';
import 'package:flutter_app/src/version/update/AppUpdate.dart';

class APPVersion {
  static void initAndCheck() async {
    RemoteConfigVersionInfo config = await RemoteConfigUtil.getVersionConfig();
    if (!config.isFocusUpdate) {
      if (!LocalStorage.instance.autoCheckAppUpdate ||
          !LocalStorage.instance.getFirstUse(LocalStorage.appCheckUpdate) ||
          LocalStorage.instance.getAccount().isEmpty) return;
    }
    LocalStorage.instance.setAlreadyUse(LocalStorage.appCheckUpdate);
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
    String preVersion = await LocalStorage.instance.getVersion();
    Log.d(" preVersion: $preVersion \n version: $version");
    if (preVersion != version) {
      await LocalStorage.instance.setVersion(version);
      updateVersionCallback();
    }
  }

  static void updateVersionCallback() {
    //更新版本後會執行函數
    //用途資料更新...
  }
}
