import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/connector/course_connector.dart';
import 'package:flutter_app/src/model/course/course_class_json.dart';
import 'package:flutter_app/src/model/course/course_main_extra_json.dart';
import 'package:flutter_app/src/model/coursetable/course_table_json.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:flutter_app/src/util/language_util.dart';

import '../task.dart';
import 'course_system_task.dart';

class CourseTableTask extends CourseSystemTask<CourseTableJson> {
  final String studentId;
  final SemesterJson semester;

  CourseTableTask(this.studentId, this.semester) : super("CourseTableTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.success) {
      super.onStart(R.current.getCourse);
      CourseMainInfo value;
      if (studentId.length == 5) {
        value = await CourseConnector.getTWTeacherCourseMainInfoList(studentId, semester);
      } else {
        if (LanguageUtil.getLangIndex() == LangEnum.zh) {
          //根據語言選擇課表
          value = await CourseConnector.getTWCourseMainInfoList(studentId, semester);
        } else {
          value = await CourseConnector.getENCourseMainInfoList(studentId, semester);
        }
      }
      super.onEnd();
      if (value != null) {
        CourseTableJson courseTable = CourseTableJson();
        courseTable.courseSemester = semester;
        courseTable.studentId = studentId;
        courseTable.studentName = value.studentName;
        //依照時間創建課表
        for (CourseMainInfoJson courseMainInfo in value.json) {
          CourseInfoJson courseInfo = CourseInfoJson();
          bool add = false;
          for (int i = 0; i < 7; i++) {
            Day day = Day.values[i];
            String time = courseMainInfo.course.time[day];
            courseInfo.main = courseMainInfo;
            add |= courseTable.setCourseDetailByTimeString(day, time, courseInfo);
          }
          if (!add) {
            //代表課程沒有時間
            courseTable.setCourseDetailByTime(Day.UnKnown, SectionNumber.T_UnKnown, courseInfo);
          }
        }
        if (studentId == LocalStorage.instance.getAccount()) {
          //只儲存自己的課表
          LocalStorage.instance.addCourseTable(courseTable);
          await LocalStorage.instance.saveCourseTableList();
        }
        result = courseTable;
        return TaskStatus.success;
      } else {
        return await super.onError(R.current.getCourseError);
      }
    }
    return status;
  }
}
