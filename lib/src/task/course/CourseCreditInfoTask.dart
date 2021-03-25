import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/CourseConnector.dart';
import 'package:flutter_app/src/model/course/CourseScoreJson.dart';

import '../Task.dart';
import 'CourseSystemTask.dart';

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
