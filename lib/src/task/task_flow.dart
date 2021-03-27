import 'package:connectivity/connectivity.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/task/course/course_system_task.dart';
import 'package:flutter_app/src/task/iplus/iplus_system_task.dart';
import 'package:flutter_app/src/task/ntut/ntut_task.dart';
import 'package:flutter_app/src/task/score/score_system_task.dart';
import 'package:flutter_app/ui/other/my_toast.dart';

import 'course_oads/course_oad_system_task.dart';
import 'task.dart';

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
    CourseOadSystemTask.isLogin = false;
  }

  int get length {
    return _queue.length;
  }

  List<Task> get completeTask {
    return _completeTask;
  }

  TaskFlow() {
    _queue = [];
    _completeTask = [];
    _failTask = [];
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
          _queue = [];
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
    _completeTask = [];
    _failTask = [];
    Log.d(log);
    return success;
  }
}
