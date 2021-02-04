import 'package:connectivity/connectivity.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/task/course/CourseSystemTask.dart';
import 'package:flutter_app/src/task/iplus/IPlusSystemTask.dart';
import 'package:flutter_app/src/task/ntut/NTUTTask.dart';
import 'package:flutter_app/src/task/score/ScoreSystemTask.dart';
import 'package:flutter_app/ui/other/MyToast.dart';

import 'Task.dart';

typedef onSuccessCallBack = Function(Task);

class TaskFlow {
  List<Task> _queue;
  List<Task> _completeTask;
  List<Task> _failTask;
  onSuccessCallBack callback;

  static resetLoginStatus() {
    NTUTTask.isLogin = false;
    ScoreSystemTask.isLogin = false;
    IPlusSystemTask.isLogin = false;
    CourseSystemTask.isLogin = false;
  }

  int get length {
    return _queue.length;
  }

  List<Task> get completeTask {
    return _completeTask;
  }

  TaskFlow() {
    _queue = List();
    _completeTask = List();
    _failTask = List();
  }

  void addTask(Task task) {
    _queue.add(task);
  }

  Future<bool> start() async {
    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      MyToast.show(R.current.pleaseConnectToNetwork);
      return false;
    }
    bool success = true;
    while (_queue.length > 0) {
      Task task = _queue.first;
      TaskStatus status = await task.execute();
      switch (status) {
        case TaskStatus.Success:
          _queue.removeAt(0);
          _completeTask.add(task);
          if (callback != null) {
            callback(task);
          }
          break;
        case TaskStatus.GiveUp:
          _failTask.addAll(_queue);
          _queue = List();
          success = false;
          break;
        case TaskStatus.Restart:
          break;
      }
    }
    String log = "success";
    for (Task task in _completeTask) {
      log += '\n--' + task.name;
    }
    if (!success) {
      log += "\nfail";
      for (Task task in _failTask) {
        log += '\n--' + task.name;
      }
    }
    _completeTask = List();
    _failTask = List();
    Log.d(log);
    return success;
  }
}
