import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/src/connector/NTUTConnector.dart';
import 'package:flutter_app/src/taskcontrol/task/CheckCookiesTask.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';
import 'package:flutter_app/ui/other/CustomRoute.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';
import 'package:flutter_app/ui/pages/login/LoginPage.dart';
import '../../store/Model.dart';
import '../../store/json/UserDataJson.dart';
import '../../../ui/other/ErrorDialog.dart';

class NTUTLoginTask extends TaskModel {
  static final String taskName = "NTUTLoginTask" + CheckCookiesTask.checkNTUT ;

  NTUTLoginTask(BuildContext context) : super(context, taskName);

  @override
  Future<TaskStatus> taskStart() async {
    String account = Model.instance.getAccount();
    String password = Model.instance.getPassword();
    MyProgressDialog.showProgressDialog(context, S.current.loginNTUT);
    NTUTConnectorStatus value = await NTUTConnector.login(account, password);
    MyProgressDialog.hideProgressDialog();
    if (value != NTUTConnectorStatus.LoginSuccess) {
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
        parameter.desc = S.current.passwordExpiredWarning;
        parameter.btnOkText = S.current.update;
        break;
      case NTUTConnectorStatus.AccountLockWarning:
        parameter.dialogType = DialogType.INFO;
        parameter.desc = S.current.accountLock;
        break;
      case NTUTConnectorStatus.AccountPasswordIncorrect:
        parameter.dialogType = DialogType.INFO;
        parameter.desc = S.current.accountPasswordError;
        parameter.btnOkText = S.current.setting;
        parameter.btnOkOnPress =  () {
          Navigator.of(context).push(CustomRoute(LoginPage())).then( (_){
            reStartTask();
          });
        };
        break;
      case NTUTConnectorStatus.ConnectTimeOutError:
        parameter.desc = S.current.connectTimeOut;
        break;
      case NTUTConnectorStatus.AuthCodeFailError:
        parameter.desc = S.current.authCodeFail;
        break;
      case NTUTConnectorStatus.NetworkError:
        parameter.desc = S.current.networkError;
        break;
      default:
        parameter.desc = S.current.unknownError;
        break;
    }

    ErrorDialog(parameter).show();



  }
}
