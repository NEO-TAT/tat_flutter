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
    title              = ( title         != null )? title         : S.current.alertError;
    btnOkText          = ( btnOkText     != null )? btnOkText     : S.current.restart;
    btnCancelText      = ( btnCancelText != null )? btnCancelText : S.current.cancel;
    animType           = ( animType      != null )? animType      : AnimType.BOTTOMSLIDE;
    dialogType         = ( dialogType    != null )? dialogType    : DialogType.ERROR;
    btnCancelOnPress   = ( btnCancelOnPress  != null )? btnCancelOnPress: (){
      TaskHandler.instance.giveUpTask();
    };
    btnOkOnPress       = ( btnOkOnPress      != null )? btnOkOnPress    : (){
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