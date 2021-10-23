import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tat/src/R.dart';

class ErrorDialogParameter {
  final BuildContext? context;
  late final String? title;
  late final String desc;
  late final String? btnOkText;
  late final String? btnCancelText;
  late final DialogType? dialogType;
  late final AnimType? animType;
  late final Function? btnOkOnPress;
  late final Function? btnCancelOnPress;
  late final bool offOkBtn;
  late final bool offCancelBtn;

  ErrorDialogParameter({
    this.context,
    required this.desc,
    this.title,
    this.btnOkText,
    this.btnCancelText,
    this.animType,
    this.dialogType,
    this.btnCancelOnPress,
    this.btnOkOnPress,
    this.offOkBtn: false,
    this.offCancelBtn: false,
  }) {
    title ??= R.current.alertError;
    btnOkText ??= R.current.restart;
    btnCancelText ??= R.current.cancel;
    animType ??= AnimType.BOTTOMSLIDE;
    dialogType ??= DialogType.ERROR;
    btnCancelOnPress ??= () => Get.back<bool>(result: false);
    btnOkOnPress ??= () => Get.back<bool>(result: true);
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
      context: Get.key.currentState!.context,
      dialogType: parameter.dialogType!,
      animType: parameter.animType!,
      title: parameter.title,
      desc: parameter.desc,
      btnOkText: parameter.btnOkText,
      btnCancelText: parameter.btnCancelText,
      useRootNavigator: false,
      dismissOnTouchOutside: false,
      btnCancelOnPress: parameter.btnCancelOnPress,
      btnOkOnPress: parameter.btnOkOnPress,
    )..show();
  }
}
