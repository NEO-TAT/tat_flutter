import 'package:tat/src/R.dart';
import 'package:tat/src/connector/course_connector.dart';
import 'package:tat/src/connector/course_oad_connector.dart';
import 'package:tat/src/model/course/course_class_json.dart';
import 'package:tat/src/model/course_table/course_table_json.dart';
import 'package:tat/src/store/model.dart';
import 'package:tat/src/task/ntut/ntut_task.dart';
import 'package:tat/src/util/language_utils.dart';

import '../task.dart';
import 'course_system_task.dart';

class CourseTableTask extends CourseSystemTask<CourseTableJson> {
  final String studentId;
  final SemesterJson semester;

  CourseTableTask(this.studentId, this.semester) : super("CourseTableTask");

  @override
  Future<TaskStatus> execute() async {
    final status = await super.execute();
    if (status == TaskStatus.Success) {
      super.onStart(R.current.getCourse);
      CourseMainInfo? value;

      if (studentId.length == 5) {
        value = await CourseConnector.getTWTeacherCourseMainInfoList(
          studentId,
          semester,
        );
      } else {
        if (LanguageUtils.getLangIndex() == LangEnum.zh) {
          value = await CourseConnector.getTWCourseMainInfoList(
            studentId,
            semester,
          );
        } else {
          value = await CourseConnector.getENCourseMainInfoList(
            studentId,
            semester,
          );
        }
      }

      super.onEnd();

      if (value == null && studentId == Model.instance.getAccount()) {
        super.onStart(R.current.courseSystemFailUseBackupSystem);
        await CourseOadConnector.login();
        value = await CourseOadConnector.backupGetCourseMainInfoList();
        super.onEnd();
        NTUTTask.isLogin = false;
        CourseSystemTask.isLogin = false;
      }

      if (value != null) {
        final courseTable = CourseTableJson();
        courseTable.courseSemester = semester;
        courseTable.studentId = studentId;
        courseTable.studentName = value.studentName!;

        for (final courseMainInfo in value.json!) {
          final courseInfo = CourseInfoJson();
          bool add = false;

          for (int i = 0; i < 7; i++) {
            final day = Day.values[i];
            final time = courseMainInfo.course!.time![day]!;
            courseInfo.main = courseMainInfo;
            add |=
                courseTable.setCourseDetailByTimeString(day, time, courseInfo);
          }

          if (!add) {
            courseTable.setCourseDetailByTime(
              Day.UnKnown,
              SectionNumber.T_UnKnown,
              courseInfo,
            );
          }
        }

        if (studentId == Model.instance.getAccount()) {
          Model.instance.addCourseTable(courseTable);
          await Model.instance.saveCourseTableList();
        }

        result = courseTable;
        return TaskStatus.Success;
      } else {
        NTUTTask.isLogin = false;
        CourseSystemTask.isLogin = false;
        return TaskStatus.GiveUp;
      }
    }
    return status;
  }
}
