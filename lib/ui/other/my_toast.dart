// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'package:flutter/material.dart';
import 'package:flutter_app/src/config/app_colors.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyToast {
  static void show(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors.mainColor,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
