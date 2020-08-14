import 'package:flutter/material.dart';
import 'file:///C:/Users/Morris/Desktop/tat_flutter/lib/src/config/AppColors.dart';
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
