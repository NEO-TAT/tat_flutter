import 'package:tat/src/R.dart';
import 'package:tat/src/connector/course_connector.dart';

import '../task.dart';
import 'course_system_task.dart';

class CourseDepartmentTask extends CourseSystemTask<List<Map>> {
  final Map code;

  CourseDepartmentTask(this.code) : super("CourseDepartmentTask");

  @override
  Future<TaskStatus> execute() async {
    final status = await super.execute();
    if (status == TaskStatus.Success) {
      super.onStart(R.current.searchingDepartment);
      final value = await CourseConnector.getDepartmentList(code);
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
