import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/src/connector/CourseConnector.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/CourseClassJson.dart';
import 'package:flutter_app/src/store/json/CoursePartJson.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';
import 'package:flutter_app/src/store/json/CourseMainJson.dart';
import '../../../ui/other/ErrorDialog.dart';
import 'TaskModel.dart';

class CourseMainInfoListTask extends TaskModel{
  static final String taskName = "CourseMainInfoListTask";
  String id;
  SemesterJson semester;
  CourseMainInfoListTask(BuildContext context,this.id,this.semester) : super(context, taskName);

  @override
  Future<TaskStatus> taskStart() async{
    MyProgressDialog.showProgressDialog(context, S.current.getCourseSemester );
    List<CourseMainInfoJson> courseMainInfoList = await CourseConnector.getCourseMainInfoList(id , semester );
    MyProgressDialog.hideProgressDialog();
    CourseTableJson courseTable = CourseTableJson();

    for( CourseMainInfoJson courseMainInfo in courseMainInfoList ) {
      CourseInfoJson courseInfo = CourseInfoJson();
      courseInfo.main = courseMainInfo;
      int courseDay = 0;
      int classroomIndex = 0;
      int classroomLength = courseMainInfo.classroom.length;
      bool add = false;
      for (int j = 0; j < 7; j++) {
        Day day = Day.values[j];
        String time = courseMainInfo.course.time[day];
        //計算教室
        if (classroomLength >= 1) {
          classroomIndex = (courseDay < classroomLength)
              ? courseDay
              : classroomLength - 1;
          courseMainInfo.classroom[classroomIndex].mainUse = true;  // 標記
        }
        courseDay++;
        //加入課程時間
        add |= courseTable.setCourseDetailByTimeString(
            day , time, courseInfo);
        courseMainInfo.classroom[classroomIndex].mainUse = false;  //取消標記
      }
      if (!add) { //代表課程沒有時間
        courseTable.setCourseDetailByTime(
            Day.UnKnown, SectionNumber.T_UnKnown, courseInfo);
      }
    }
    Model.instance.addCourseTable( courseTable );
    await Model.instance.save( Model.courseTableJsonKey );

    if( courseTable != null  ) {
      return TaskStatus.TaskSuccess;
    }else {
      _handleError();
      return TaskStatus.TaskFail;
    }
  }

  void _handleError() {

    ErrorDialogParameter parameter = ErrorDialogParameter(
      context: context,
      desc: S.current.getCourseSemesterError,
    );
    ErrorDialog(parameter).show();
  }


}