import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';

class ErrorDialogParameter{
  BuildContext context;
  String title;
  String desc;
  String btnOkText;
  String btnCancelText;
  DialogType dialogType;
  AnimType animType;
  Function btnOkOnPress;
  Function btnCancelOnPress;
  ErrorDialogParameter( { @required this.context , @required this.desc ,this.title , this.btnOkText , this.btnCancelText , this.animType , this.dialogType , this.btnCancelOnPress , this.btnOkOnPress}){
    title              = title             ?? S.current.alertError;
    btnOkText          = btnOkText         ?? S.current.restart;
    btnCancelText      = btnCancelText     ?? S.current.cancel;
    animType           = animType          ?? AnimType.BOTTOMSLIDE;
    dialogType         = dialogType        ?? DialogType.ERROR;
    btnCancelOnPress   = btnCancelOnPress  ??  (){
      TaskHandler.instance.giveUpTask();
    };
    btnOkOnPress       = btnOkOnPress      ??  (){
      TaskHandler.instance.continueTask();
    };
  }
}

class ErrorDialog {
  ErrorDialogParameter parameter;
  ErrorDialog( this.parameter );

  void show(){
    AwesomeDialog(
      context: parameter.context,
      dialogType: parameter.dialogType,
      animType: parameter.animType,
      tittle: parameter.title,
      desc: parameter.desc,
      btnOkText: parameter.btnOkText,
      btnCancelText: parameter.btnCancelText,
      useRootNavigator: true,
      dismissOnTouchOutside: false,
      btnCancelOnPress: parameter.btnCancelOnPress ,
      btnOkOnPress: parameter.btnOkOnPress
    ).show();
  }

}