import 'package:flutter_app/ui/pages/password/ChangePasswordDialog.dart';
import 'package:flutter_app/ui/pages/password/CheckPasswordDialog.dart';
import 'package:get/get.dart';

class ChangePassword {
  static Future<void> show() async {
    bool passAuth =
        await Get.dialog(CheckPasswordDialog(), useRootNavigator: false);
    if (passAuth) {
      await Get.dialog(ChangePasswordDialog(), useRootNavigator: false);
    }
  }
}
