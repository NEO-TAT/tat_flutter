import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/taskcontrol/task/CheckCookiesTask.dart';
import 'package:flutter_app/src/taskcontrol/task/ISchoolLoginTask.dart';
import 'package:flutter_app/src/taskcontrol/task/ISchoolNewAnnouncementTask.dart';
import 'package:flutter_app/src/taskcontrol/task/NTUTLoginTask.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';

class TaskHandler {
  TaskHandler._privateConstructor();
  static final TaskHandler instance = TaskHandler._privateConstructor();
  static final List<TaskModel> _taskQueue = List();

  void addTask(TaskModel task) {
    _taskQueue.add(task);
  }

  void _addFirstTask(TaskModel task){
    Log.d( "add Task " + task.getTaskName );
    _taskQueue.insert(0, task);
  }

  void _addFirstTaskList(List<TaskModel> taskList){
    for( int i = taskList.length-1 ; i >= 0 ; i--){
      TaskModel task = taskList[i];
      _taskQueue.insert(0, task );
    }
    for( int i = 0 ; i < taskList.length ; i++){
      TaskModel task = taskList[i];
      Log.d( "add Task " + task.getTaskName );
    }
  }

  void startTask( [BuildContext context]) async{
    while ( _taskQueue.length > 0 ){
      TaskModel task = _taskQueue.removeAt(0);
      if( context != null ){
        task.setContext = context;
        Log.d( "SetContext") ;
      }
      Log.d( "Start " + task.getTaskName );
      try {
        TaskStatus result = await task.taskStart();
        if( result == TaskStatus.TaskFail ){
          _handleErrorTask( task );
          break;
        }else{
          _handleSuccessTask( task );
        }
      }on Exception catch(e){
        Log.e(e.toString());
        _handleErrorTask( task );
      }
    }
  }

  void _handleErrorTask(TaskModel task ) async{
    Log.d( "Task fail " + task.getTaskName );
    if (task is NTUTLoginTask){
      _addFirstTask( NTUTLoginTask(task.context) );
    }else if (task is ISchoolLoginTask){
      _addFirstTask( CheckCookiesTask(task.context) );
    }
    else if (task is ISchoolNewAnnouncementTask){
      _addFirstTaskList( [
        CheckCookiesTask(task.context),
        task
      ]);
    }
    else if (task is CheckCookiesTask){
      _addFirstTaskList( [
        NTUTLoginTask(task.context) ,
        ISchoolLoginTask(task.context)
      ]);
      startTask();
    }
  }


  void _handleSuccessTask(TaskModel task ) async{
    Log.d( "Task Success " + task.getTaskName );
  }



}