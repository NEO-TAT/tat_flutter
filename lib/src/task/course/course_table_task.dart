// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter_app/src/connector/course_connector.dart';
import 'package:flutter_app/src/model/course/course_class_json.dart';
import 'package:flutter_app/src/model/coursetable/course_table_json.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:flutter_app/src/util/language_util.dart';

import '../../model/coursetable/course.dart';
import '../../model/coursetable/course_table.dart';
import '../task.dart';
import 'course_system_task.dart';

class CourseTableTask extends CourseSystemTask<CourseTable> {
  final String studentId;
  final int year;
  final int semester;

  CourseTableTask(this.studentId, this.year, this.semester) : super("CourseTableTask");

  @override
  Future<TaskStatus> execute() async {
    final status = await super.execute();
    if (status == TaskStatus.success) {
        super.onStart(R.current.getCourse);
        List<Course>? courses;
        var userInfo = await CourseConnector.getUserInfo(studentId, year, semester);
        // TODO: Handle Teacher Situation.
        if (LanguageUtil.getLangIndex() == LangEnum.zh) {
          courses = await CourseConnector.getChineseCourses(studentId, year, semester);
        } else {
          courses = await CourseConnector.getEnglishCourses(studentId, year, semester);
        }
        super.onEnd();
        final courseTable = CourseTable(
          year: year,
          semester: semester,
          courses: courses,
          user: userInfo
        );
        LocalStorage.instance.addCourseTable(courseTable);
        await LocalStorage.instance.saveCourseTableList();

        result = courseTable;
        return TaskStatus.success;
      } else {
        return super.onError(R.current.getCourseError);
      }
  }
}
