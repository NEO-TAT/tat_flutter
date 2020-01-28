import 'package:flutter/cupertino.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/src/connector/CourseConnector.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';

import 'TaskModel.dart';

class CourseLoginTask extends TaskModel{
  static final String taskName = "CourseLoginTask";
  CourseLoginTask(BuildContext context) : super(context, taskName);

  @override
  Future<TaskStatus> taskStart() async{
    MyProgressDialog.showProgressDialog(context, S.current.loginCourse );
    CourseConnectorStatus value = await CourseConnector.login();
    MyProgressDialog.hideProgressDialog();
    if( value == CourseConnectorStatus.LoginSuccess){
      return TaskStatus.TaskSuccess;
    }else{
      return TaskStatus.TaskFail;
    }
  }

}