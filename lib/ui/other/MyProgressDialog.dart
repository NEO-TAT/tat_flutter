import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:progress_dialog/progress_dialog.dart';


class MyProgressDialog{
  static ProgressDialog _progressDialog;
  static BuildContext _context;
  static void showProgressDialog( BuildContext context , String message ){

    hideProgressDialog();
    _progressDialog = new ProgressDialog(
        context ,
        showLogs:false
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

  static void hideProgressDialog() async{

    if( _progressDialog!= null ){
      if ( _progressDialog.isShowing() ){
        bool value = await _progressDialog.hide();
        if (!value){
          Log.e( "hideProgressDialog Fail" );
        }else{
          Log.d("hideProgressDialog Success");
        }
      }else{
        Log.d("ProgressDialog is not display");
      }
    }else{
      Log.d("ProgressDialog is Null");
    }


    /*
    if( _progressDialog != null ){
      _progressDialog.dismiss();
    }
    _progressDialog = null;

     */
    //_progressDialog.dismissProgressDialog( _context);
  }


}