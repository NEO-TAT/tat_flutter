import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/src/connector/ISchoolConnector.dart';
import 'package:flutter_app/src/connector/NTUTConnector.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';

import '../../../../ui/other/ErrorDialog.dart';
import '../CheckCookiesTask.dart';

class ISchoolLoginTask extends TaskModel {
  static final String taskName =
      "ISchoolLoginTask" + CheckCookiesTask.checkISchool;
  String studentId;
  ISchoolLoginTask(BuildContext context, {this.studentId})
      : super(context, taskName);

  @override
  Future<TaskStatus> taskStart() async {
    MyProgressDialog.showProgressDialog(context, S.current.loginISchool);
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
      desc: S.current.loginISchoolError,
    );
    ErrorDialog(parameter).show();
  }
}
