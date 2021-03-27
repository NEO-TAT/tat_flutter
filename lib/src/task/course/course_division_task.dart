import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/course_connector.dart';

import '../task.dart';
import 'course_system_task.dart';

class CourseDivisionTask extends CourseSystemTask<List<Map>> {
  final year;

  CourseDivisionTask(this.year) : super("CourseDivisionTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.Success) {
      super.onStart(R.current.searchingDivision);
      List<Map> value = await CourseConnector.getDivisionList(year);
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
