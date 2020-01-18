import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';


class MyProgressDialog{
  static ProgressDialog _progressDialog;
  static void showProgressDialog( BuildContext context , String message){
    _progressDialog = new ProgressDialog(context);
    /*
    _progressDialog.style(
        message: message,
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
    );

     */
    _progressDialog.show();
  }

  static void hideProgressDialog(){
    _progressDialog.hide();
  }

}