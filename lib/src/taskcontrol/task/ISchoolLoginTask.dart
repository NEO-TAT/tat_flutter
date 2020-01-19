import 'package:flutter/cupertino.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';

class ISchoolLoginTask extends TaskModel{
  static final String taskName = "ISchoolLoginTask";
  ISchoolLoginTask(BuildContext context) : super(context , taskName);

  @override
  Future<TaskStatus> taskStart() {
    return null;
  }
}