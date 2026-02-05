import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/task/course/course_system_task.dart';
import 'package:flutter_app/src/task/iplus/iplus_system_task.dart';
import 'package:flutter_app/src/task/ntut/ntut_task.dart';
import 'package:flutter_app/src/task/score/score_system_task.dart';
import 'package:flutter_app/ui/other/my_toast.dart';

import 'task.dart';

typedef OnSuccessCallBack = Function(Task);

class TaskFlow {
  TaskFlow()
      : _queue = [],
        _completeTask = [],
        _failTask = [],
        callback = null;

  final List<Task> _queue;
  final List<Task> _completeTask;
  final List<Task> _failTask;
  OnSuccessCallBack? callback;

  static resetLoginStatus() {
    NTUTTask.isLogin = false;
    ScoreSystemTask.isLogin = false;
    IPlusSystemTask.isLogin = false;
    CourseSystemTask.isLogin = false;
  }

  int get length => _queue.length;

  List<Task> get completeTask => _completeTask;

  void addTask(Task task) {
    _queue.add(task);
  }

  Future<bool> start() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      MyToast.show(R.current.pleaseConnectToNetwork);
      return false;
    }
    bool success = true;
    while (_queue.isNotEmpty) {
      final task = _queue.first;
      final status = await task.execute();
      switch (status) {
        case TaskStatus.success:
          _queue.removeAt(0);
          _completeTask.add(task);
          callback?.call(task);
          break;
        case TaskStatus.shouldGiveUp:
          _failTask.addAll(_queue);
          _queue.clear();
          success = false;
          break;
        case TaskStatus.shouldRestart:
        case TaskStatus.shouldIgnore:
          _queue.removeAt(0);
          _completeTask.add(task);
          break;
      }
    }
    String log = "success";
    for (final task in _completeTask) {
      log += '\n--${task.name}';
    }
    if (!success) {
      log += "\nfail";
      for (final task in _failTask) {
        log += '\n--${task.name}';
      }
    }
    _completeTask.clear();
    _failTask.clear();
    Log.d(log);
    return success;
  }
}
