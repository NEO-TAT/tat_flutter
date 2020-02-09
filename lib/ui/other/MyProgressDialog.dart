import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';

import 'CustomProgressDialog.dart';
import 'ProgressDialog.dart';


class MyProgressDialog {
  static StyleProgressDialog _progressDialog = StyleProgressDialog();
  static BuildContext _context;

  static void showProgressDialog(BuildContext context, String message) async{
    _context = context;
    _progressDialog.showProgressDialog(
        context,
        dismissAfter: Duration(seconds: 20 ),
        textToBeDisplayed:message,
        onDismiss:(){

        }
        );
  }

  static void hideProgressDialog()  {
    _progressDialog.dismissProgressDialog(_context);
  }

}




/*
class MyProgressDialog {
  static ProgressDialog _progressDialog;
  static BuildContext _context;

  static void showProgressDialog(BuildContext context, String message) {
    hideProgressDialog();
    _progressDialog = new ProgressDialog(
      context,
      showLogs: false,
      useRootNavigator:false,
    );


    _progressDialog.style(
      message: message,
        /*
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600)

         */
    );
    _progressDialog.show();
  }

  static void hideProgressDialog() async {
    if( _progressDialog != null ){
      _progressDialog.dismiss();
    }

  }


}
*/