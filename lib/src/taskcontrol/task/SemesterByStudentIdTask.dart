import 'package:flutter/cupertino.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/src/connector/CourseConnector.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';

class SemesterByStudentIdTask extends TaskModel{
  static final String taskName = "CourseByCourseIdTask";
  String id;
  SemesterByStudentIdTask(BuildContext context , this.id) : super(context, taskName);

  @override
  Future<TaskStatus> taskStart() async{
    MyProgressDialog.showProgressDialog(context, S.current.getCourse );
    bool value = await CourseConnector.getSemesterByStudentId(id);
    MyProgressDialog.hideProgressDialog();
    if( value ) {
      return TaskStatus.TaskSuccess;
    }else {
      return TaskStatus.TaskFail;
    }
  }

}