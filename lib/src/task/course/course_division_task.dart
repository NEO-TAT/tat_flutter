import 'package:tat/src/R.dart';
import 'package:tat/src/connector/course_connector.dart';

import '../task.dart';
import 'course_system_task.dart';

class CourseDivisionTask extends CourseSystemTask<List<Map>> {
  final String year;

  CourseDivisionTask(this.year) : super("CourseDivisionTask");

  @override
  Future<TaskStatus> execute() async {
    final status = await super.execute();
    if (status == TaskStatus.Success) {
      super.onStart(R.current.searchingDivision);
      final value = await CourseConnector.getDivisionList(year);
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
