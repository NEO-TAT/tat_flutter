import 'package:flutter/cupertino.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/CourseConnector.dart';
import 'package:flutter_app/src/model/course/CourseClassJson.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/taskcontrol/task/CheckCookiesTask.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';

class CourseSemesterTask extends TaskModel {
  static final String taskName = "CourseSemesterTask";
  static final List<String> require = [CheckCookiesTask.checkCourse];
  String id;

  CourseSemesterTask(BuildContext context, this.id)
      : super(context, taskName, require);

  @override
  Future<TaskStatus> taskStart() async {
    MyProgressDialog.showProgressDialog(context, R.current.getCourseSemester);
    List<SemesterJson> value = await CourseConnector.getCourseSemester(id);
    MyProgressDialog.hideProgressDialog();
    if (value != null) {
      Model.instance.setSemesterJsonList(value);
      return TaskStatus.TaskSuccess;
    } else {
      _handleError();
      return TaskStatus.TaskFail;
    }
  }

  void _handleError() {
    ErrorDialogParameter parameter = ErrorDialogParameter(
      context: context,
      desc: R.current.getCourseError,
    );
    ErrorDialog(parameter).show();
  }
}
