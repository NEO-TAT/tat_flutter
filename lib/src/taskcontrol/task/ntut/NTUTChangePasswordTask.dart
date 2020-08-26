import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/NTUTConnector.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/taskcontrol/task/CheckCookiesTask.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';

class NTUTChangePasswordTask extends TaskModel {
  static final String taskName = "NTUTChangePasswordTask";
  static final List<String> require = [CheckCookiesTask.checkNTUT];
  String password;

  NTUTChangePasswordTask(BuildContext context, this.password)
      : super(context, taskName, require);

  @override
  Future<TaskStatus> taskStart() async {
    MyProgressDialog.showProgressDialog(context, R.current.changingPassword);
    String value = await NTUTConnector.changePassword(password);
    MyProgressDialog.hideProgressDialog();
    if (value.isNotEmpty) {
      _handleError(value);
      return TaskStatus.TaskFail;
    } else {
      return TaskStatus.TaskSuccess;
    }
  }

  void _handleError(String value) {
    ErrorDialogParameter parameter = ErrorDialogParameter(
      context: context,
      desc: value ?? R.current.changingPasswordError,
    );
    ErrorDialog(parameter).show();
  }
}
