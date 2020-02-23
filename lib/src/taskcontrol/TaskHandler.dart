//  TaskHandler.dart
//  北科課程助手
//  用於處理任務失敗與成功
//  Created by morris13579 on 2020/02/12.
//  Copyright © 2020 morris13579 All rights reserved.
//
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/connector/CourseConnector.dart';
import 'package:flutter_app/src/connector/ISchoolConnector.dart';
import 'package:flutter_app/src/connector/NTUTConnector.dart';
import 'package:flutter_app/src/taskcontrol/task/CheckCookiesTask.dart';
import 'package:flutter_app/src/taskcontrol/task/course/CourseLoginTask.dart';
import 'package:flutter_app/src/taskcontrol/task/ischool/ISchoolLoginTask.dart';
import 'package:flutter_app/src/taskcontrol/task/ntut/NTUTLoginTask.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';

class TaskHandler {
  TaskHandler._privateConstructor();

  static final TaskHandler instance = TaskHandler._privateConstructor();
  static final List<TaskModel> _taskQueue = List();
  bool taskContinue;
  BuildContext startTaskContext;

  void addTask(TaskModel task) {
    _taskQueue.add(task);
  }

  void _addFirstTask(TaskModel task) {
    _addFirstTaskList([task]);
  }

  void _addFirstTaskList(List<TaskModel> taskList) {
    for (int i = taskList.length - 1; i >= 0; i--) {
      TaskModel task = taskList[i];
      _taskQueue.insert(0, task);
    }
    for (int i = 0; i < taskList.length; i++) {
      TaskModel task = taskList[i];
      Log.d("add Task " + task.getTaskName);
    }
  }

  Future<void> startTaskQueue(BuildContext context) async {
    startTaskContext = context;
    for (TaskModel task in _taskQueue) {
      Log.d("Task: " + task.getTaskName);
    }
    while (_taskQueue.length > 0) {
      TaskModel task = _taskQueue.removeAt(0);
      task.setContext = context;
      Log.d("Start " + task.getTaskName);
      try {
        TaskStatus result = await task.taskStart();
        if (result == TaskStatus.TaskFail) {
          taskContinue = false;
          _handleErrorTask(task);
          while (!taskContinue) {
            await Future.delayed(Duration(milliseconds: 10));
          }
        } else {
          _handleSuccessTask(task);
        }
      } catch (e) {
        Log.e(e.toString());
        _handleErrorTask(task);
      }
    }
    Log.d("startTaskQueue finish");
  }

  void continueTask() {
    taskContinue = true;
  }

  void giveUpTask() {
    continueTask();
    _taskQueue.removeRange(0, _taskQueue.length);
  }

  void _handleErrorTask(TaskModel task) async {
    Log.d("Task fail " + task.getTaskName);

    if (task is ISchoolLoginTask ||
        task is CourseLoginTask ||
        task is NTUTLoginTask) {
      _addFirstTask(task);
    } else if (task is CheckCookiesTask) {
      List<TaskModel> taskList = List();
      if (!NTUTConnector.isLogin) {
        taskList.add(NTUTLoginTask(task.context));
      }
      if (!CourseConnector.isLogin) {
        taskList.add(CourseLoginTask(task.context));
      }
      if (!ISchoolConnector.isLogin) {
        taskList.add(ISchoolLoginTask(task.context));
      }
      _addFirstTaskList(taskList);
      continueTask();
    } else {
      _addFirstTaskList([
        CheckCookiesTask(task.context, checkSystem: task.getTaskName),
        task
      ]);
    }
  }

  void _handleSuccessTask(TaskModel task) {
    Log.d("Task Success " + task.getTaskName);
  }
}
