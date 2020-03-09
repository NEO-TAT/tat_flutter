import 'package:flutter/cupertino.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/ISchoolConnector.dart';
import 'package:flutter_app/src/taskcontrol/task/CheckCookiesTask.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';

class ISchoolLoginTask extends TaskModel {
  static final String taskName = "ISchoolLoginTask";
  static final List<String> require = [CheckCookiesTask.checkISchool];
  String studentId;

  ISchoolLoginTask(BuildContext context, {this.studentId})
      : super(context, taskName, require);

  @override
  Future<TaskStatus> taskStart() async {
    MyProgressDialog.showProgressDialog(context, R.current.loginISchool);
    ISchoolConnectorStatus value =
        await ISchoolConnector.login(studentId: studentId);
    MyProgressDialog.hideProgressDialog();
    if (value == ISchoolConnectorStatus.LoginSuccess) {
      return TaskStatus.TaskSuccess;
    } else {
      _handleError();
      return TaskStatus.TaskFail;
    }
  }

  void _handleError() {
    ErrorDialogParameter parameter = ErrorDialogParameter(
      context: context,
      desc: R.current.loginISchoolError,
    );
    ErrorDialog(parameter).show();
  }
}
