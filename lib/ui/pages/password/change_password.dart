import 'package:flutter_app/ui/pages/password/change_password_dialog.dart';
import 'package:flutter_app/ui/pages/password/check_password_dialog.dart';
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
