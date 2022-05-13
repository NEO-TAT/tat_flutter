// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'package:flutter_app/src/connector/course_connector.dart';
import 'package:flutter_app/src/r.dart';

import '../task.dart';
import 'course_system_task.dart';

class CourseDepartmentTask extends CourseSystemTask<List<Map>> {
  final Map code;

  CourseDepartmentTask(this.code) : super("CourseDepartmentTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.success) {
      super.onStart(R.current.searchingDepartment);
      List<Map> value = await CourseConnector.getDepartmentList(code);
      super.onEnd();
      if (value != null) {
        result = value;
        return TaskStatus.success;
      } else {
        return TaskStatus.giveUp;
      }
    }
    return status;
  }
}