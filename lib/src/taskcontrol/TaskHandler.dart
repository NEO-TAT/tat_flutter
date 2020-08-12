//  TaskHandler.dart
//  北科課程助手
//  用於處理任務失敗與成功
//  Created by morris13579 on 2020/02/12.
//  Copyright © 2020 morris13579 All rights reserved.
//
import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/taskcontrol/task/CheckCookiesTask.dart';
import 'package:flutter_app/src/taskcontrol/task/course/CourseLoginTask.dart';
import 'package:flutter_app/src/taskcontrol/task/ischoolplus/ISchoolPlusLoginTask.dart';
import 'package:flutter_app/src/taskcontrol/task/ntut/NTUTLoginTask.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';
import 'package:flutter_app/src/taskcontrol/task/ntutapp/NTUTAppLoginTask.dart';
import 'package:flutter_app/src/taskcontrol/task/score/ScoreLoginTask.dart';

import '../../ui/other/MyToast.dart';
import '../R.dart';

class TaskHandler {
  TaskHandler._privateConstructor();

  static final TaskHandler instance = TaskHandler._privateConstructor();
  static final List<TaskModel> _taskQueue = List();
  static String alreadyCheckSystem = "";
  bool taskContinue;
  BuildContext startTaskContext;

  void addTask(TaskModel task, {bool onLoginCheck: true}) {
    if (onLoginCheck) {
      if (Model.instance.getOtherSetting().focusLogin) {
        //直接重新登入不檢查
        _taskQueue.add(CheckCookiesTask(task.context,
            checkSystem: task.requireSystem.toString()));
      } else {
        String needLoginSystem = "";
        for (String require in task.requireSystem) {
          if (!alreadyCheckSystem.contains(require)) {
            alreadyCheckSystem += require;
            needLoginSystem += require;
          }
        }
        if (needLoginSystem.isNotEmpty) {
          _taskQueue.add(
              CheckCookiesTask(task.context, checkSystem: needLoginSystem));
        }
      }
    }
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
    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      MyToast.show(R.current.pleaseConnectToNetwork);
      giveUpTask();
    }
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
      } catch (e, stack) {
        Log.eWithStack(e.toString(), stack);
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
    if (task is NTUTLoginTask || task is NTUTAppLoginTask) {
      _addFirstTask(task);
    } else if (task is CourseLoginTask ||
        task is ISchoolPlusLoginTask ||
        task is ScoreLoginTask) {
      _addFirstTaskList([NTUTLoginTask(task.context), task]);
    } else if (task is CheckCookiesTask) {
      String needLoginSystem =
          Model.instance.getTempData(CheckCookiesTask.tempDataKey);
      _addLoginTask(task.context, needLoginSystem); //加入需要登入的任務
      continueTask();
    } else {
      _addFirstTaskList([
        CheckCookiesTask(task.context,
            checkSystem: task.requireSystem.toString()),
        task
      ]);
    }
  }

  void _handleSuccessTask(TaskModel task) {
    Log.d("Task Success " + task.getTaskName);
  }

  void _addLoginTask(BuildContext context, String needLoginSystem) {
    List<TaskModel> taskList = List();
    Log.d("needLoginSystem : $needLoginSystem");
    Map<String, TaskModel> loginMap = {
      CheckCookiesTask.checkNTUT: NTUTLoginTask(context),
      CheckCookiesTask.checkNTUTApp: NTUTAppLoginTask(context),
      CheckCookiesTask.checkCourse: CourseLoginTask(context),
      CheckCookiesTask.checkScore: ScoreLoginTask(context),
      CheckCookiesTask.checkPlusISchool: ISchoolPlusLoginTask(context),
    };
    for (String key in loginMap.keys.toList()) {
      if (needLoginSystem.contains(key)) {
        taskList.add(loginMap[key]);
      }
    }
    _addFirstTaskList(taskList);
  }
}
