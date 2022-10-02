// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'package:flutter_app/src/connector/course_connector.dart';
import 'package:flutter_app/src/r.dart';

import '../task.dart';
import 'course_system_task.dart';

class CourseYearTask extends CourseSystemTask<List<String>> {
  CourseYearTask() : super("CourseYearTask");

  @override
  Future<TaskStatus> execute() async {
    final status = await super.execute();
    if (status == TaskStatus.success) {
      super.onStart(R.current.searchingYear);
      List<String> value = await CourseConnector.getYearList();
      super.onEnd();
      if (value != null) {
        result = value;
        return TaskStatus.success;
      } else {
        return TaskStatus.shouldGiveUp;
      }
    }
    return status;
  }
}
