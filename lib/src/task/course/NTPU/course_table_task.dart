import 'package:flutter_app/src/connector/NTPU/course_connector.dart';
import 'package:flutter_app/src/model/course/course_class_json.dart';
import 'package:flutter_app/src/model/coursetable/course_table_json.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:flutter_app/src/task/course/NTPU/course_system_task.dart';
import 'package:flutter_app/src/util/language_util.dart';

import '../../task.dart';

class CourseTableTask extends CourseSystemTask<CourseTableJson> {
  final studentId;

  CourseTableTask(this.studentId) : super("CourseTableTask");


  @override
  Future<TaskStatus> execute() async {
    final status = await super.execute();
    if (status == TaskStatus.success) {
      super.onStart(R.current.getCourse);
      CourseMainInfo? value = await CourseConnector.getCurrentSemesterCourseMainInfoList();

      super.onEnd();
      if (value != null) {
        final courseTable = CourseTableJson();
        // courseTable.courseSemester = semester;
        courseTable.studentId = studentId;
        courseTable.studentName = value.studentName;

        for (final courseMainInfo in value.json) {
          final courseInfo = CourseInfoJson();
          bool add = false;
          for (int i = 0; i < 7; i++) {
            final day = Day.values[i];
            final time = courseMainInfo.course.time[day];
            courseInfo.main = courseMainInfo;
            add |= courseTable.setCourseDetailByTimeString(day, time, courseInfo);
          }
          if (!add) {
            courseTable.setCourseDetailByTime(Day.UnKnown, SectionNumber.T_UnKnown, courseInfo);
          }
        }
        // if (studentId == LocalStorage.instance.getAccount()) {
        //   //只儲存自己的課表
        //   LocalStorage.instance.addCourseTable(courseTable);
        //   await LocalStorage.instance.saveCourseTableList();
        // }
        result = courseTable;
        return TaskStatus.success;
      } else {
        return super.onError(R.current.getCourseError);
      }
    }


    // if (status == TaskStatus.success) {
    //   super.onStart(R.current.getCourse);
    //   CourseMainInfo? value;
    //   if (studentId.length == 5) {
    //     value = await CourseConnector.getTWTeacherCourseMainInfoList(studentId, semester);
    //   } else {
    //     if (LanguageUtil.getLangIndex() == LangEnum.zh) {
    //       value = await CourseConnector.getTWCourseMainInfoList(studentId, semester);
    //     } else {
    //       value = await CourseConnector.getENCourseMainInfoList(studentId, semester) as CourseMainInfo?;
    //     }
    //   }
    //   super.onEnd();
    //   if (value != null) {
    //     final courseTable = CourseTableJson();
    //     courseTable.courseSemester = semester;
    //     courseTable.studentId = studentId;
    //     courseTable.studentName = value.studentName;
    //
    //     for (final courseMainInfo in value.json) {
    //       final courseInfo = CourseInfoJson();
    //       bool add = false;
    //       for (int i = 0; i < 7; i++) {
    //         final day = Day.values[i];
    //         final time = courseMainInfo.course.time[day];
    //         courseInfo.main = courseMainInfo;
    //         add |= courseTable.setCourseDetailByTimeString(day, time, courseInfo);
    //       }
    //       if (!add) {
    //         courseTable.setCourseDetailByTime(Day.UnKnown, SectionNumber.T_UnKnown, courseInfo);
    //       }
    //     }
    //     if (studentId == LocalStorage.instance.getAccount()) {
    //       //只儲存自己的課表
    //       LocalStorage.instance.addCourseTable(courseTable);
    //       await LocalStorage.instance.saveCourseTableList();
    //     }
    //     result = courseTable;
    //     return TaskStatus.success;
    //   } else {
    //     return super.onError(R.current.getCourseError);
    //   }
    // }
    return status;
  }
}