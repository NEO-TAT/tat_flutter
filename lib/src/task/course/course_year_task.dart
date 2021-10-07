import 'package:tat/src/R.dart';
import 'package:tat/src/connector/course_connector.dart';

import '../task.dart';
import 'course_system_task.dart';

class CourseYearTask extends CourseSystemTask<List<String>> {
  CourseYearTask() : super("CourseYearTask");

  @override
  Future<TaskStatus> execute() async {
    final status = await super.execute();
    if (status == TaskStatus.Success) {
      super.onStart(R.current.searchingYear);
      final value = await CourseConnector.getYearList();
      super.onEnd();

      if (value != null) {
        result = value;
        return TaskStatus.Success;
      } else {
        return TaskStatus.GiveUp;
      }
    }
    return status;
  }
}
