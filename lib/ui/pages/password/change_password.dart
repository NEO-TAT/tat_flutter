import 'package:get/get.dart';
import 'package:tat/ui/pages/password/change_password_dialog.dart';
import 'package:tat/ui/pages/password/check_password_dialog.dart';

class ChangePassword {
  static Future<void> show() async {
    final passAuth = await Get.dialog(CheckPasswordDialog());
    if (passAuth) {
      await Get.dialog(ChangePasswordDialog());
    }
  }
}
