import 'package:flutter/cupertino.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/CourseConnector.dart';
import 'package:flutter_app/src/model/course/CourseClassJson.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/taskcontrol/task/CheckCookiesTask.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';

class CourseSemesterTask extends TaskModel {
  static final String taskName = "CourseSemesterTask";
  static final List<String> require = [CheckCookiesTask.checkCourse];
  String id;

  CourseSemesterTask(BuildContext context, this.id)
      : super(context, taskName, require);

  @override
  Future<TaskStatus> taskStart() async {
    List<SemesterJson> value;
    if (id.length == 5) {
      value = List();
      DateTime dateTime = DateTime.now();
      int year = dateTime.year - 1911;
      int semester = (dateTime.month <= 8 && dateTime.month >= 1) ? 2 : 1;
      value.add(
          SemesterJson(semester: semester.toString(), year: year.toString()));
    } else {
      MyProgressDialog.showProgressDialog(context, R.current.getCourseSemester);
      value = await CourseConnector.getCourseSemester(id);
      MyProgressDialog.hideProgressDialog();
    }
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
