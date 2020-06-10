//  ErrorDialog.dart
//  北科課程助手
//  用於顯示錯誤視窗
//  Created by morris13579 on 2020/02/12.
//  Copyright © 2020 morris13579 All rights reserved.
//

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';

class ErrorDialogParameter {
  BuildContext context;
  String title;
  String desc;
  String btnOkText;
  String btnCancelText;
  DialogType dialogType;
  AnimType animType;
  Function btnOkOnPress;
  Function btnCancelOnPress;
  ErrorDialogParameter(
      {@required this.context,
      @required this.desc,
      this.title,
      this.btnOkText,
      this.btnCancelText,
      this.animType,
      this.dialogType,
      this.btnCancelOnPress,
      this.btnOkOnPress}) {
    title = title ?? R.current.alertError;
    btnOkText = btnOkText ?? R.current.restart;
    btnCancelText = btnCancelText ?? R.current.cancel;
    animType = animType ?? AnimType.BOTTOMSLIDE;
    dialogType = dialogType ?? DialogType.ERROR;
    btnCancelOnPress = btnCancelOnPress ??
        () {
          TaskHandler.instance.giveUpTask();
        };
    btnOkOnPress = btnOkOnPress ??
        () {
          TaskHandler.instance.continueTask();
        };
  }
}

class ErrorDialog {
  ErrorDialogParameter parameter;
  ErrorDialog(this.parameter);

  void show() {
    AwesomeDialog(
            context: parameter.context,
            dialogType: parameter.dialogType,
            animType: parameter.animType,
            title: parameter.title,
            desc: parameter.desc,
            btnOkText: parameter.btnOkText,
            btnCancelText: parameter.btnCancelText,
            useRootNavigator: true,
            dismissOnTouchOutside: false,
            btnCancelOnPress: parameter.btnCancelOnPress,
            btnOkOnPress: parameter.btnOkOnPress)
        .show();
  }
}
