// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter_app/src/connector/course_connector.dart';
import 'package:flutter_app/src/r.dart';

import '../task.dart';
import 'course_system_task.dart';

class CourseDivisionTask extends CourseSystemTask<List<Map>> {
  final String year;

  CourseDivisionTask(this.year) : super("CourseDivisionTask");

  @override
  Future<TaskStatus> execute() async {
    final status = await super.execute();
    if (status == TaskStatus.success) {
      super.onStart(R.current.searchingDivision);
      final value = await CourseConnector.getDivisionList(year);
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
