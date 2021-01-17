import 'package:connectivity/connectivity.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/ui/other/MyToast.dart';

import 'Task.dart';

typedef onSuccessCallBack = Function(Task);

class TaskFlow {
  List<Task> _queue;
  List<Task> _completeTask;
  onSuccessCallBack callback;

  int get length {
    return _queue.length;
  }

  List<Task> get completeTask {
    return _completeTask;
  }

  TaskFlow() {
    _queue = List();
    _completeTask = List();
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
          _queue = List();
          success = false;
          break;
        case TaskStatus.Restart:
          break;
      }
    }
    return success;
  }
}
