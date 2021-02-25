import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/CourseConnector.dart';
import 'package:flutter_app/src/connector/CourseOadConnector.dart';
import 'package:flutter_app/src/model/course/CourseClassJson.dart';
import 'package:flutter_app/src/model/course/CourseMainExtraJson.dart';
import 'package:flutter_app/src/model/coursetable/CourseTableJson.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/task/ntut/NTUTTask.dart';
import 'package:flutter_app/src/util/LanguageUtil.dart';

import '../Task.dart';
import 'CourseSystemTask.dart';

class CourseTableTask extends CourseSystemTask<CourseTableJson> {
  final String studentId;
  final SemesterJson semester;

  CourseTableTask(this.studentId, this.semester) : super("CourseTableTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.Success) {
      super.onStart(R.current.getCourse);
      CourseMainInfo value;
      if (studentId.length == 5) {
        value = await CourseConnector.getTWTeacherCourseMainInfoList(
            studentId, semester);
      } else {
        if (LanguageUtil.getLangIndex() == LangEnum.zh) {
          //根據語言選擇課表
          value = await CourseConnector.getTWCourseMainInfoList(
              studentId, semester);
        } else {
          value = await CourseConnector.getENCourseMainInfoList(
              studentId, semester);
        }
      }
      super.onEnd();
      if (value == null && studentId == Model.instance.getAccount()) {
        super.onStart(R.current.courseSystemFailUseBackupSystem);
        await CourseOadConnector.login();
        value = await CourseOadConnector.backupGetCourseMainInfoList();
        super.onEnd();
      }
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
            add |=
                courseTable.setCourseDetailByTimeString(day, time, courseInfo);
          }
          if (!add) {
            //代表課程沒有時間
            courseTable.setCourseDetailByTime(
                Day.UnKnown, SectionNumber.T_UnKnown, courseInfo);
          }
        }
        if (studentId == Model.instance.getAccount()) {
          //只儲存自己的課表
          Model.instance.addCourseTable(courseTable);
          await Model.instance.saveCourseTableList();
        }
        result = courseTable;
        return TaskStatus.Success;
      } else {
        NTUTTask.isLogin = false;
        return TaskStatus.GiveUp;
        return await super.onError(R.current.getCourseError);
      }
    }
    return status;
  }
}
