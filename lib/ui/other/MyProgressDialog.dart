import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'CustomProgressDialog.dart';

class MyProgressDialog {
  static StyleProgressDialog _progressDialog = StyleProgressDialog();
  static BuildContext _context;

  static void showProgressDialog(BuildContext context, String message) async {
    _context = context;
    _progressDialog.showProgressDialog(context,
        //dismissAfter: Duration(seconds: 20 ),
        dismissAfter: null, //不設置自動關閉時間
        textToBeDisplayed: message, onDismiss: () {
      _progressDialog.dismissProgressDialog(_context);
    });
  }

  static Future<void> hideProgressDialog() async {
    await _progressDialog.dismissProgressDialog(_context);
  }
}
