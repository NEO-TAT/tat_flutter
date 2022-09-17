// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/src/r.dart';
import 'package:get/get.dart';

class ErrorDialogParameter {
  final BuildContext context;
  String title;
  String desc;
  String btnOkText;
  String btnCancelText;
  DialogType dialogType;
  AnimType animType;
  Function btnOkOnPress;
  Function btnCancelOnPress;
  final bool offOkBtn;
  final bool offCancelBtn;

  ErrorDialogParameter({
    this.context,
    @required this.desc,
    this.title,
    this.btnOkText,
    this.btnCancelText,
    this.animType,
    this.dialogType,
    this.btnCancelOnPress,
    this.btnOkOnPress,
    this.offOkBtn = false,
    this.offCancelBtn = false,
  }) {
    title ??= R.current.alertError;
    btnOkText ??= R.current.sure;
    btnCancelText ??= R.current.cancel;
    animType ??= AnimType.BOTTOMSLIDE;
    dialogType ??= DialogType.ERROR;
    btnCancelOnPress ??= () => null;
    btnOkOnPress ??= () => null;
    if (offOkBtn) {
      btnOkOnPress = null;
    }
    if (offCancelBtn) {
      btnCancelOnPress = null;
    }
  }
}

class ErrorDialog {
  final ErrorDialogParameter parameter;

  const ErrorDialog(this.parameter);

  void show() {
    AwesomeDialog(
      context: Get.key.currentState.context,
      dialogType: parameter.dialogType,
      animType: parameter.animType,
      title: parameter.title,
      desc: parameter.desc,
      btnOkText: parameter.btnOkText,
      btnCancelText: parameter.btnCancelText,
      useRootNavigator: false,
      dismissOnTouchOutside: false,
      btnCancelOnPress: parameter.btnCancelOnPress,
      btnOkOnPress: parameter.btnOkOnPress,
    ).show();
  }
}
