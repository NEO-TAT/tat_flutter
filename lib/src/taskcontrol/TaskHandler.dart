import 'dart:async';

import 'package:flutter_app/src/taskcontrol/task/NTUTLoginTask.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';

class TaskHandler {
  TaskHandler._privateConstructor();
  static final TaskHandler instance = TaskHandler._privateConstructor();
  static final List<TaskModel> _taskQueue = List();

  void addTask(TaskModel task) {
    _taskQueue.add(task);
  }

  void startTask() async{
    while ( _taskQueue.length > 0 ){
      TaskModel task = _taskQueue.removeAt(0);
      TaskStatus result = await task.taskStart();
      if( result == TaskStatus.TaskFail ){
        _handleErrorTask( task );
        break;
      }
    }
  }

  void _handleErrorTask(TaskModel task ) async{
    if (task is NTUTLoginTask){
      addTask( NTUTLoginTask(task.context) );
    }
  }


}