import 'package:flutter/cupertino.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/version/update/AppUpdate.dart';

class Version {
  static void initAndCheck(BuildContext context) async {
    if (!Model.instance.autoCheckAppUpdate ||
        !Model.instance.getFirstUse(Model.appCheckUpdate) ||
        Model.instance.getAccount().isEmpty) return;
    Model.instance.setAlreadyUse(Model.appCheckUpdate);
    await check(context);
  }

  static Future<bool> check(BuildContext context) async {
    Log.d("Start check update");
    UpdateDetail value = await AppUpdate.checkUpdate();
    if (value != null) {
      //檢查到app要更新
      AppUpdate.showUpdateDialog(context, value);
      return true;
    }
    return false;
  }
}
