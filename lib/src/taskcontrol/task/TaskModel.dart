import 'package:flutter/cupertino.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';

enum TaskStatus { TaskSuccess, TaskFail }

abstract class TaskModel {
  String _taskName;
  List<String> requireSystem;
  BuildContext _context;
  TaskModel(BuildContext context, String name , this.requireSystem) {
    _taskName = name;
    _context = context;
  }
  String get getTaskName {
    return _taskName;
  }

  set setContext(BuildContext value) {
    _context = value;
  }

  BuildContext get context {
    return _context;
  }

  void reStartTask() {
    TaskHandler.instance.continueTask();
  }

  void giveUpTask() {
    TaskHandler.instance.giveUpTask();
  }

  Future<TaskStatus> taskStart();
  //Future<List<TaskModel>> taskErrorList();

}
