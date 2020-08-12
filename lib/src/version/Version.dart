import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/version/VersionConfig.dart';
import 'package:flutter_app/src/version/hotfix/AppHotFix.dart';
import 'package:flutter_app/src/version/update/AppUpdate.dart';

class Version {
  static void initAndCheck(BuildContext context) async {
    if (!Model.instance.autoCheckAppUpdate ||
        !Model.instance.getFirstUse(Model.appCheckUpdate) ||
        Model.instance.getAccount().isEmpty) return;
    Model.instance.setAlreadyUse(Model.appCheckUpdate);
    await AppHotFix.getInstance();
    await check(context);
  }

  static Future<bool> check(BuildContext context) async {
    if (VersionConfig.enableUpdate) {
      Log.d("Start check update");
      UpdateDetail value = await AppUpdate.checkUpdate();
      if (value != null) {
        //檢查到app要更新
        AppUpdate.showUpdateDialog(context, value);
        return true;
      }
    }
    if (VersionConfig.enableHotfix) {
      Log.d("Start check hotfix");
      Crashlytics.instance.setInt(
          "Patch Version", VersionConfig.patchVersion); //設定patch version
      Crashlytics.instance
          .setBool("inDevMode", AppHotFix.inDevMode); //設定是否加入內測版
      List<String> supportedABis = await AppHotFix.getSupportABis();
      Crashlytics.instance
          .setString("Supported ABis", supportedABis.toString());
      //不開啟就算手動放入檔案下次重新開啟也會還原
      await AppHotFix.hotFixSuccess(context);
      PatchDetail patch = await AppHotFix.checkPatchVersion();
      if (patch != null) {
        bool v = await AppHotFix.showUpdateDialog(context, patch);
        if (v) AppHotFix.downloadPatch(context, patch);
        return true;
      }
    }
    return false;
  }
}
