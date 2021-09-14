import 'package:tat/src/R.dart';
import 'package:tat/src/connector/course_connector.dart';
import 'package:tat/src/model/course/course_score_json.dart';

import '../task.dart';
import 'course_system_task.dart';

class CourseCreditInfoTask extends CourseSystemTask<GraduationInformationJson> {
  final divisionName;
  final matricCode;

  CourseCreditInfoTask(this.matricCode, this.divisionName)
      : super("CourseCreditInfoTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.Success) {
      super.onStart(R.current.searchingCreditInfo);
      GraduationInformationJson value =
          await CourseConnector.getCreditInfo(matricCode, divisionName);
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
