import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/src/connector/CourseConnector.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/CourseClassJson.dart';
import 'package:flutter_app/src/store/json/CourseMainExtraJson.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';
import 'package:flutter_app/src/store/json/CourseTableJson.dart';
import '../../../ui/other/ErrorDialog.dart';
import 'TaskModel.dart';

class CourseTableListTask extends TaskModel{
  static final String taskName = "CourseTableListTask";
  String id;
  SemesterJson semester;
  CourseTableListTask(BuildContext context,this.id,this.semester) : super(context, taskName);

  @override
  Future<TaskStatus> taskStart() async{
    MyProgressDialog.showProgressDialog(context, S.current.getCourse );
    List<CourseMainInfoJson> courseMainInfoList = await CourseConnector.getCourseMainInfoList(id , semester );
    MyProgressDialog.hideProgressDialog();
    CourseTableJson courseTable = CourseTableJson();
    courseTable.courseSemester = semester;

    for( CourseMainInfoJson courseMainInfo in courseMainInfoList ) {
      CourseInfoJson courseInfo = CourseInfoJson();
      bool add = false;
      for( int i = 0 ; i < 7 ; i++){
        Day day = Day.values[i];
        String time = courseMainInfo.course.time[ day];
        courseInfo.main = courseMainInfo;
          add |= courseTable.setCourseDetailByTimeString(
              day , time, courseInfo);
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