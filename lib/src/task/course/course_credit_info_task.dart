// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter_app/src/connector/course_connector.dart';
import 'package:flutter_app/src/model/course/course_score_json.dart';
import 'package:flutter_app/src/r.dart';

import '../task.dart';
import 'course_system_task.dart';

class CourseCreditInfoTask extends CourseSystemTask<GraduationInformationJson> {
  final Map code;
  final String creditName;

  CourseCreditInfoTask(this.code, this.creditName) : super("CourseCreditInfoTask");

  @override
  Future<TaskStatus> execute() async {
    final status = await super.execute();
    if (status == TaskStatus.success) {
      super.onStart(R.current.searchingCreditInfo);
      final value = await CourseConnector.getCreditInfo(code, creditName);
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
