// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:flutter_app/src/util/remote_config_util.dart';
import 'package:flutter_app/src/version/update/app_update.dart';

class APPVersion {
  static void initAndCheck() async {
    final versionConfig = await RemoteConfigUtil.getVersionConfig();

    if (!versionConfig.isFocusUpdate) {
      if (!LocalStorage.instance.autoCheckAppUpdate ||
          !LocalStorage.instance.getFirstUse(LocalStorage.appCheckUpdate) ||
          LocalStorage.instance.getAccount().isEmpty) return;
    }

    LocalStorage.instance.setAlreadyUse(LocalStorage.appCheckUpdate);

    Log.d("Start check update");
    await AppUpdate.checkUpdate(versionConfig: versionConfig);

    updateLocalVersion();
  }

  static Future<bool> checkShouldUpdate() {
    return AppUpdate.checkUpdate();
  }

  static Future<void> updateLocalVersion() async {
    final current = await AppUpdate.getAppVersion();
    final previous = LocalStorage.instance.getVersion();
    Log.d("Previous: $previous\nCurrent: $current");

    if (previous != current) {
      await LocalStorage.instance.setVersion(current);
    }
  }
}
