import 'package:flutter/cupertino.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/R.dart';
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
  Function successFunction;

  TaskModelFunction(BuildContext context,
      {@required this.require,
      @required this.taskFunction,
      @required this.errorFunction,
      @required this.successFunction})
      : super(context, taskName, require);

  @override
  Future<TaskStatus> taskStart() async {
    bool pass;
    try {
      pass = await taskFunction();
      if (pass) {
        successFunction();
        return TaskStatus.TaskSuccess;
      } else {
        errorFunction();
        return TaskStatus.TaskFail;
      }
    }catch(e){
      Log.d( e.toString() );
      errorFunction();
      return TaskStatus.TaskFail;
    }
  }
}
