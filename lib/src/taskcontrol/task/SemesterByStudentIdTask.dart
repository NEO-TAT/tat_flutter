import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/src/connector/CourseConnector.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/CourseDetailJson.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';

class SemesterByStudentIdTask extends TaskModel {
  static final String taskName = "SemesterByStudentIdTask";
  String id;

  SemesterByStudentIdTask(BuildContext context, this.id)
      : super(context, taskName);

  @override
  Future<TaskStatus> taskStart() async {
    MyProgressDialog.showProgressDialog(context, S.current.getCourse);
    List<SemesterJson> value = await CourseConnector.getSemesterByStudentId(id);
    MyProgressDialog.hideProgressDialog();
    if ( value != null ) {
      Model.instance.courseSemesterList = value;
      return TaskStatus.TaskSuccess;
    } else {
      _handleError();
      return TaskStatus.TaskFail;
    }
  }

  void _handleError() {
    ErrorDialogParameter parameter = ErrorDialogParameter(
      context: context,
      desc: S.current.getCourseError,
    );
    ErrorDialog(parameter).show();
  }
}
