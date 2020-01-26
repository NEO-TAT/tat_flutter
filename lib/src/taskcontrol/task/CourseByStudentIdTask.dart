import 'package:flutter/cupertino.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/connector/CourseConnector.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';

class CourseByStudentIdTask extends TaskModel{
  static final String taskName = "CourseByCourseIdTask";
  String id;
  CourseByStudentIdTask(BuildContext context , this.id) : super(context, taskName);

  @override
  Future<TaskStatus> taskStart() async{
    MyProgressDialog.showProgressDialog(context, "getcourse");
    try{
      CourseConnector.getCourseByStudentId(id);
      MyProgressDialog.hideProgressDialog();
      return TaskStatus.TaskSuccess;
    }on Exception catch(e){
      Log.e(e.toString());
      return TaskStatus.TaskFail;
    }
  }

}