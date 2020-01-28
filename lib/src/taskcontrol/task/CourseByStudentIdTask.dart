import 'package:flutter/cupertino.dart';
import 'package:flutter_app/src/connector/CourseConnector.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';

import 'TaskModel.dart';

class CourseByStudentIdTask extends TaskModel{
  static final String taskName = "CourseByStudentIdTask";
  String id;
  String year;
  String semester;
  CourseByStudentIdTask(BuildContext context,this.id,this.year,this.semester) : super(context, taskName);

  @override
  Future<TaskStatus> taskStart() async{
    MyProgressDialog.showProgressDialog(context, "getcourse");
    bool value = await CourseConnector.getCourseByStudentId(id , year , semester );
    MyProgressDialog.hideProgressDialog();
    if( value ) {
      return TaskStatus.TaskSuccess;
    }else {
      return TaskStatus.TaskFail;
    }
  }


}