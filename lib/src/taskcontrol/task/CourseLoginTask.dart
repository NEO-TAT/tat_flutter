import 'package:flutter/cupertino.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/connector/CourseConnector.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';

import 'TaskModel.dart';

class CourseLoginTask extends TaskModel{
  static final String taskName = "CourseLoginTask";
  CourseLoginTask(BuildContext context) : super(context, taskName);

  @override
  Future<TaskStatus> taskStart() async{
    MyProgressDialog.showProgressDialog(context, "CourseLogin");
    try{
      CourseConnector.login();
      MyProgressDialog.hideProgressDialog();
      return TaskStatus.TaskSuccess;
    }on Exception catch(e){
      Log.e(e.toString());
      return TaskStatus.TaskFail;
    }
  }

}