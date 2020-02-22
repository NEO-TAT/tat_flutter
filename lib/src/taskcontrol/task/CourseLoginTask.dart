import 'package:flutter/cupertino.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/src/connector/CourseConnector.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';

import '../../../ui/other/ErrorDialog.dart';
import 'CheckCookiesTask.dart';
import 'TaskModel.dart';

class CourseLoginTask extends TaskModel {
  static final String taskName =
      "CourseLoginTask" + CheckCookiesTask.checkCourse;
  CourseLoginTask(BuildContext context) : super(context, taskName);

  @override
  Future<TaskStatus> taskStart() async {
    MyProgressDialog.showProgressDialog(context, S.current.loginCourse);
    CourseConnectorStatus value = await CourseConnector.login();
    MyProgressDialog.hideProgressDialog();
    if (value == CourseConnectorStatus.LoginSuccess) {
      return TaskStatus.TaskSuccess;
    } else {
      _handleError();
      return TaskStatus.TaskFail;
    }
  }

  void _handleError() {
    ErrorDialogParameter parameter = ErrorDialogParameter(
      context: context,
      desc: S.current.getCourseDetailError,
    );
    ErrorDialog(parameter).show();
  }
}
