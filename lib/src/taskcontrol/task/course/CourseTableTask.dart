import 'package:flutter/cupertino.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/CourseConnector.dart';
import 'package:flutter_app/src/model/course/CourseClassJson.dart';
import 'package:flutter_app/src/model/course/CourseMainExtraJson.dart';
import 'package:flutter_app/src/model/coursetable/CourseTableJson.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/taskcontrol/task/CheckCookiesTask.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';
import 'package:flutter_app/src/util/LanguageUtil.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';

class CourseTableTask extends TaskModel {
  static final String taskName = "CourseTableTask";
  static final List<String> require = [CheckCookiesTask.checkCourse];
  String studentId;
  SemesterJson semester;

  CourseTableTask(BuildContext context, this.studentId, this.semester)
      : super(context, taskName, require);
  static String tempDataKey = "CourseTableTempKey";

  @override
  Future<TaskStatus> taskStart() async {
    MyProgressDialog.showProgressDialog(context, R.current.getCourse);
    List<CourseMainInfoJson> courseMainInfoList;
    if (studentId.length == 5) {
      courseMainInfoList =
          await CourseConnector.getTWTeacherCourseMainInfoList(studentId, semester);
    } else {
      if (LanguageUtil.getLangIndex() == LangEnum.zh) {
        //根據語言選擇課表
        courseMainInfoList =
            await CourseConnector.getTWCourseMainInfoList(studentId, semester);
      } else {
        courseMainInfoList =
            await CourseConnector.getENCourseMainInfoList(studentId, semester);
      }
    }

    MyProgressDialog.hideProgressDialog();
    if (courseMainInfoList != null) {
      CourseTableJson courseTable = CourseTableJson();
      courseTable.courseSemester = semester;
      courseTable.studentId = studentId;
      courseTable.studentName = Model.instance.getTempData("studentName");
      //依照時間創建課表
      for (CourseMainInfoJson courseMainInfo in courseMainInfoList) {
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
          courseTable.setCourseDetailByTime(
              Day.UnKnown, SectionNumber.T_UnKnown, courseInfo);
        }
      }
      if (studentId == Model.instance.getAccount()) {
        //只儲存自己的課表
        Model.instance.addCourseTable(courseTable);
        await Model.instance.saveCourseTableList();
      }
      Model.instance.setTempData(tempDataKey, courseTable);
      return TaskStatus.TaskSuccess;
    } else {
      _handleError();
      return TaskStatus.TaskFail;
    }
  }

  void _handleError() {
    ErrorDialogParameter parameter = ErrorDialogParameter(
      context: context,
      desc: R.current.getCourseSemesterError,
    );
    ErrorDialog(parameter).show();
  }
}
