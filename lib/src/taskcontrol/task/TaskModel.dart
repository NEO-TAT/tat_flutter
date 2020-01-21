import 'package:flutter/cupertino.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';

enum TaskStatus { TaskSuccess , TaskFail}

abstract class TaskModel {
  String _taskName;
  BuildContext _context;
  TaskModel(BuildContext context , String name){
    _taskName = name;
    _context = context;
  }
  String get getTaskName{
    return _taskName;
  }

  BuildContext get context {
    return _context;
  }
  void reStartTask() {
    TaskHandler.instance.startTask();
  }
  Future<TaskStatus> taskStart();
}