import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/ui/pages/password/ChangePasswordDialog.dart';
import 'package:flutter_app/ui/pages/password/CheckPasswordDialog.dart';

class ChangePassword {
  static Future<void> show(BuildContext context) async {
    bool passAuth = await showDialog(
        context: context,
        child: CheckPasswordDialog(),
        useRootNavigator: false);
    if (passAuth) {
      await showDialog(
          context: context,
          child: ChangePasswordDialog(),
          useRootNavigator: false);
    }
  }
}
