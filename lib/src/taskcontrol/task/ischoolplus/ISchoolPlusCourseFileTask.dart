import 'package:flutter/cupertino.dart';
import 'package:flutter_app/generated/R.dart';
import 'package:flutter_app/src/connector/ISchoolPlusConnector.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/CourseFileJson.dart';
import 'package:flutter_app/src/taskcontrol/task/CheckCookiesTask.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';

class ISchoolPlusCourseFileTask extends TaskModel {
  static final String taskName =
      "ISchoolPlusCourseFileTask" + CheckCookiesTask.checkPlusISchool;
  final String courseId;
  static String courseFileListTempKey = "ISchoolPlusCourseFileTempKey";
  ISchoolPlusCourseFileTask(BuildContext context, this.courseId)
      : super(context, taskName);

  @override
  Future<TaskStatus> taskStart() async {
    MyProgressDialog.showProgressDialog(
        context, R.current.getISchoolPlusCourseFile);
    List<CourseFileJson> value = await ISchoolPlusConnector.getCourseFile(courseId);
    MyProgressDialog.hideProgressDialog();
    if (value != null) {
      Model.instance.setTempData(courseFileListTempKey, value);
      return TaskStatus.TaskSuccess;
    } else {
      _handleError();
      return TaskStatus.TaskFail;
    }
  }

  void _handleError() {
    ErrorDialogParameter parameter = ErrorDialogParameter(
      context: context,
      desc: R.current.getISchoolPlusCourseFileError,
    );
    ErrorDialog(parameter).show();
  }
}
