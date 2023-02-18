import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/src/r.dart';
import 'package:get/get.dart';

class MsgDialogParameter {
  String? title;
  String? desc;
  String? okButtonText;
  String? cancelButtonText;
  DialogType dialogType;
  VoidCallback? onOkButtonClicked;
  VoidCallback? onCancelButtonClicked;
  final AnimType animType;
  final bool removeOkButton;
  final bool removeCancelButton;

  MsgDialogParameter({
    required this.desc,
    this.title = '',
    this.okButtonText,
    this.cancelButtonText,
    this.animType = AnimType.bottomSlide,
    this.dialogType = DialogType.noHeader,
    this.removeOkButton = false,
    this.removeCancelButton = false,
    this.onOkButtonClicked,
    this.onCancelButtonClicked,
  }) {
    if (!removeOkButton) {
      okButtonText ??= R.current.sure;
      onOkButtonClicked ??= () {};
    }

    if (!removeCancelButton) {
      cancelButtonText ??= R.current.cancel;
      onCancelButtonClicked ??= () {};
    }
  }
}

class MsgDialog {
  const factory MsgDialog(MsgDialogParameter parameter) = MsgDialog._;
  const MsgDialog._(this.parameter);

  final MsgDialogParameter parameter;

  Future<void> show({BuildContext? context}) => AwesomeDialog(
        context: context ?? Get.key.currentContext!,
        dialogType: parameter.dialogType,
        animType: parameter.animType,
        title: parameter.title,
        desc: parameter.desc,
        btnOkText: parameter.okButtonText,
        btnCancelText: parameter.cancelButtonText,
        useRootNavigator: true,
        dismissOnTouchOutside: false,
        btnCancelOnPress: parameter.onCancelButtonClicked,
        btnOkOnPress: parameter.onOkButtonClicked,
      ).show();
}
