import 'package:connectivity/connectivity.dart';
import 'package:tat/debug/log/log.dart';
import 'package:tat/src/R.dart';
import 'package:tat/src/task/course/course_system_task.dart';
import 'package:tat/src/task/iplus/iplus_system_task.dart';
import 'package:tat/src/task/ntut/ntut_task.dart';
import 'package:tat/src/task/score/score_system_task.dart';
import 'package:tat/ui/other/my_toast.dart';

import 'course_oads/course_oad_system_task.dart';
import 'task.dart';

typedef OnSuccessCallBack = Function(Task);

class TaskFlow {
  late final List<Task> _queue;
  late final List<Task> _completeTask;
  late final List<Task> _failTask;
  late final OnSuccessCallBack? callback;

  TaskFlow() {
    _queue = [];
    _completeTask = [];
    _failTask = [];
  }

  static resetLoginStatus() {
    NTUTTask.isLogin = false;
    ScoreSystemTask.isLogin = false;
    IPlusSystemTask.isLogin = false;
    CourseSystemTask.isLogin = false;
    CourseOadSystemTask.isLogin = false;
  }

  int get length => _queue.length;

  List<Task> get completeTask => _completeTask;

  void addTask(Task task) {
    _queue.add(task);
  }

  Future<bool> start() async {
    final connectivityResult = await (new Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      MyToast.show(R.current.pleaseConnectToNetwork);
      return false;
    }

    bool success = true;

    while (_queue.length > 0) {
      Task task = _queue.first;
      final status = await task.execute();
      switch (status) {
        case TaskStatus.Success:
          _queue.removeAt(0);
          _completeTask.add(task);

          if (callback != null) {
            callback!(task);
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
