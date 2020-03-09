import 'package:flutter/cupertino.dart';
import 'package:flutter_app/generated/R.dart';
import 'package:flutter_app/src/connector/ScoreConnector.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';

import '../CheckCookiesTask.dart';

class ScoreLoginTask extends TaskModel{
  static final String taskName = "ScoreLoginTask";
  static final List<String> require = [CheckCookiesTask.checkNTUT];

  ScoreLoginTask(BuildContext context) : super(context, taskName, require);

  @override
  Future<TaskStatus> taskStart() async {
    MyProgressDialog.showProgressDialog(context, R.current.loginScore);
    ScoreConnectorStatus value = await ScoreConnector.login();
    MyProgressDialog.hideProgressDialog();
    if (value != ScoreConnectorStatus.LoginSuccess) {
      _handleError();
      return TaskStatus.TaskFail;
    } else {
      return TaskStatus.TaskSuccess;
    }
  }

  void _handleError() {
    ErrorDialogParameter parameter = ErrorDialogParameter(
      context: context,
      desc: R.current.loginScoreError,
    );
    ErrorDialog(parameter).show();
  }
}