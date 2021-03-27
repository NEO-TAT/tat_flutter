import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'custom_progress_dialog.dart';

class MyProgressDialog {
  static void showProgressDialogOld(
      BuildContext context, String message) async {}

  static void progressDialog(String message) async {
    BotToast.showCustomLoading(toastBuilder: (cancel) {
      return CustomProgressDialog(
        child: Container(
          decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: const BorderRadius.all(Radius.circular(5))),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Platform.isIOS
                  ? CupertinoActivityIndicator(
                      radius: 15,
                    )
                  : CircularProgressIndicator(),
              message == null
                  ? Padding(
                      padding: EdgeInsets.all(0),
                    )
                  : Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        message,
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
            ],
          ),
        ),
      );
    });
  }

  static Future<void> hideProgressDialog() async {
    BotToast.cleanAll();
  }

  static Future<void> hideAllDialog() async {
    BotToast.cleanAll();
  }
}
