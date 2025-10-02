// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter_app/src/connector/course_connector.dart';
import 'package:flutter_app/src/model/course/course_syllabus_json.dart';
import 'package:flutter_app/src/r.dart';

import '../../task.dart';
import 'course_system_task.dart';

class CourseCategoryTask extends CourseSystemTask<CourseSyllabusJson> {
  final String code;

  CourseCategoryTask(this.code) : super("CourseCategoryTask");

  @override
  Future<TaskStatus> execute() async {
    final status = await super.execute();
    if (status == TaskStatus.success) {
      super.onStart(R.current.searchingCreditInfo);
      final value = await CourseConnector.getCourseCategory(code);
      super.onEnd();

      result = value;
      return TaskStatus.success;
    }
    return status;
  }
}
