import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/ui/other/custom_progress_dialog.dart';

class MyProgressDialog {
  static void progressDialog(String? message) {
    BotToast.showCustomLoading(
      toastBuilder: (cancel) => CustomProgressDialog(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(5),
          ),
          padding: const EdgeInsets.all(20),
          child: FittedBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (message != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      message,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void hideProgressDialog() => BotToast.cleanAll();

  static void hideAllDialog() => BotToast.cleanAll();
}
