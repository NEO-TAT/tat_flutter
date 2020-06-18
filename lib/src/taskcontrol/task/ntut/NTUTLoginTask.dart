import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/NTUTConnector.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/taskcontrol/task/CheckCookiesTask.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:flutter_app/ui/other/MyPageTransition.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:flutter_app/ui/screen/LoginScreen.dart';

class NTUTLoginTask extends TaskModel {
  static final String taskName = "NTUTLoginTask";
  static final List<String> require = [CheckCookiesTask.checkNTUT];

  NTUTLoginTask(BuildContext context) : super(context, taskName, require);

  @override
  Future<TaskStatus> taskStart() async {
    String account = Model.instance.getAccount();
    String password = Model.instance.getPassword();
    MyProgressDialog.showProgressDialog(context, R.current.loginNTUT);
    NTUTConnectorStatus value = await NTUTConnector.login(account, password);
    MyProgressDialog.hideProgressDialog();
    if (value != NTUTConnectorStatus.LoginSuccess) {
      if (value == NTUTConnectorStatus.PasswordExpiredWarning) {
        MyToast.show(R.current.passwordExpiredWarning);
        return TaskStatus.TaskSuccess;
      }
      _handleError(value);
      return TaskStatus.TaskFail;
    } else {
      return TaskStatus.TaskSuccess;
    }
  }

  void _handleError(NTUTConnectorStatus value) {
    ErrorDialogParameter parameter = ErrorDialogParameter(
      context: context,
      desc: "",
    );

    switch (value) {
      case NTUTConnectorStatus.PasswordExpiredWarning:
        parameter.dialogType = DialogType.INFO;
        parameter.desc = R.current.passwordExpiredWarning;
        parameter.btnOkText = R.current.update;
        parameter.btnOkOnPress = () {};
        return;
        break;
      case NTUTConnectorStatus.AccountLockWarning:
        parameter.dialogType = DialogType.INFO;
        parameter.desc = R.current.accountLock;
        break;
      case NTUTConnectorStatus.AccountPasswordIncorrect:
        parameter.dialogType = DialogType.INFO;
        parameter.desc = R.current.accountPasswordError;
        parameter.btnOkText = R.current.setting;
        parameter.btnOkOnPress = () {
          Navigator.of(context)
              .push(MyPage.transition(LoginScreen()))
              .then((_) {
            reStartTask();
          });
        };
        break;
      case NTUTConnectorStatus.ConnectTimeOutError:
        parameter.desc = R.current.connectTimeOut;
        break;
      case NTUTConnectorStatus.AuthCodeFailError:
        parameter.desc = R.current.authCodeFail;
        break;
      case NTUTConnectorStatus.NetworkError:
        parameter.desc = R.current.networkError;
        break;
      default:
        parameter.desc = R.current.unknownError;
        break;
    }

    ErrorDialog(parameter).show();
  }
}
