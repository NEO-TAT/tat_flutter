import 'package:flutter/cupertino.dart';
import 'package:flutter_app/generated/R.dart';
import 'package:flutter_app/src/connector/CourseConnector.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/CourseMainExtraJson.dart';
import 'package:flutter_app/src/taskcontrol/task/CheckCookiesTask.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';


class TaskModelFunction extends TaskModel {
  static final String taskName = "TaskModelFunction";
  List<String> require;
  Function taskFunction;
  Function errorFunction;
  TaskModelFunction(BuildContext context , this.require , this.taskFunction , this.errorFunction)
      : super(context, taskName, require);

  @override
  Future<TaskStatus> taskStart() async {
    bool pass = await taskFunction();
    if( pass ){
      return TaskStatus.TaskSuccess;
    }else{
      errorFunction();
      return TaskStatus.TaskFail;
    }
  }


}