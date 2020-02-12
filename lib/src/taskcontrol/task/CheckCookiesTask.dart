import 'package:flutter/cupertino.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/src/connector/CourseConnector.dart';
import 'package:flutter_app/src/connector/ISchoolConnector.dart';
import 'package:flutter_app/src/connector/NTUTConnector.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';

class CheckCookiesTask extends TaskModel {
  static final String taskName = "CheckCookiesTask";
  String checkSystem;
  static String checkCourse = "__Course__";
  static String checkISchool = "__ISchool__";
  static String checkNTUT = "__NTUT__";
  static String checkScore = "__Score__";

  CheckCookiesTask(BuildContext context, {this.checkSystem})
      : super(context, taskName) {
    checkSystem = checkSystem ?? checkCourse + checkISchool + checkNTUT;
  }

  @override
  Future<TaskStatus> taskStart() async {
    Log.d(checkSystem);
    MyProgressDialog.showProgressDialog(context, S.current.checkLogin);
    bool isLoginCourse = true;
    bool isLoginSchool = true;
    bool isLoginNTUT = true;
    bool checkCourseSystem = checkSystem.contains(checkCourse);
    bool checkISchoolSystem = checkSystem.contains(checkISchool);
    bool checkNTUTSystem = checkSystem.contains(checkNTUT);
    if (checkCourseSystem || checkISchoolSystem || checkNTUTSystem) {
      NTUTConnector.loginFalse();
      isLoginNTUT = await NTUTConnector.checkLogin();
    }
    if(checkCourseSystem){
      CourseConnector.loginFalse();
    }
    if(checkISchoolSystem){
      ISchoolConnector.loginFalse();
    }
    if (!isLoginNTUT) {
      //代表學校沒登入
      return TaskStatus.TaskFail;
    }
    if (checkCourseSystem) {
      isLoginCourse = await CourseConnector.checkLogin();
    }
    if (checkISchoolSystem) {
      isLoginSchool = await ISchoolConnector.checkLogin();
    }
    MyProgressDialog.hideProgressDialog();
    if (isLoginSchool && isLoginCourse) {
      return TaskStatus.TaskSuccess;
    } else {
      return TaskStatus.TaskFail;
    }
  }
}
