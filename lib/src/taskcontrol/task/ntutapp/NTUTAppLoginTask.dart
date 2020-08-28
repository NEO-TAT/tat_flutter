import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/NTUTAppConnector.dart';
import 'package:flutter_app/src/taskcontrol/task/CheckCookiesTask.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';

import '../../../../ui/other/ErrorDialog.dart';
import '../../../store/Model.dart';

class NTUTAppLoginTask extends TaskModel {
  static final String taskName = "NTUTAppLoginTask";
  static final List<String> require = [CheckCookiesTask.checkNTUTApp];

  NTUTAppLoginTask(BuildContext context) : super(context, taskName, require);

  @override
  Future<TaskStatus> taskStart() async {
    String account = Model.instance.getAccount();
    String password = Model.instance.getPassword();
    MyProgressDialog.showProgressDialog(context, R.current.loginNTUTApp);
    NTUTAppConnectorStatus value =
        await NTUTAppConnector.login(account, password);
    MyProgressDialog.hideProgressDialog();
    if (value != NTUTAppConnectorStatus.LoginSuccess) {
      _handleError(value);
      return TaskStatus.TaskFail;
    } else {
      return TaskStatus.TaskSuccess;
    }
  }

  void _handleError(NTUTAppConnectorStatus value) {
    ErrorDialogParameter parameter = ErrorDialogParameter(
      context: context,
      desc: R.current.loginNTUTAppError,
    );
    ErrorDialog(parameter).show();
  }
}
