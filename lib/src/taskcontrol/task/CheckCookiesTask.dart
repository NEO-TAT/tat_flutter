import 'package:flutter/cupertino.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/CourseConnector.dart';
import 'package:flutter_app/src/connector/ISchoolPlusConnector.dart';
import 'package:flutter_app/src/connector/NTUTAppConnector.dart';
import 'package:flutter_app/src/connector/NTUTConnector.dart';
import 'package:flutter_app/src/connector/ScoreConnector.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';

class CheckCookiesTask extends TaskModel {
  static final String taskName = "CheckCookiesTask";
  String checkSystem;
  String studentId;
  static String checkNTUT = "__NTUT__";
  static String checkNTUTApp = "__NTUTApp__";
  // subSystem
  static String checkCourse = "__Course__";
  static String checkPlusISchool = "__ISchoolPlus__";
  static String checkScore = "__Score__";
  static String tempDataKey = "CheckCookiesTempKey";
  CheckCookiesTask(BuildContext context, {this.checkSystem, this.studentId})
      : super(context, taskName, []) {
    checkSystem = checkSystem ?? checkNTUT;
  }

  @override
  Future<TaskStatus> taskStart() async {
    Log.d(checkSystem);
    if (Model.instance.getOtherSetting().focusLogin) {
      //直接重新登入不檢查
      checkSystem += checkNTUT;
      Model.instance.setTempData(tempDataKey, checkSystem);
      return TaskStatus.TaskFail;
    }
    MyProgressDialog.showProgressDialog(context, R.current.checkLogin);
    String loginSystem = "";
    Map<String, Function> checkMap = {
      checkScore: () async {
        return await ScoreConnector.checkLogin();
      },
      checkCourse: () async {
        return await CourseConnector.checkLogin();
      },
      checkPlusISchool: () async {
        return await ISchoolPlusConnector.checkLogin();
      },
    };
    for (String check in checkMap.keys.toList()) {
      if (checkSystem.contains(check)) {
        bool pass = await checkMap[check]();
        if (!pass) {
          loginSystem += check;
        }
      }
    }
    if (loginSystem.isNotEmpty || checkSystem.contains(checkNTUT)) {
      //代表有任務錯誤
      bool pass = await NTUTConnector.checkLogin();
      if (!pass) {
        loginSystem += checkNTUT;
      }
    }
    if (checkSystem.contains(checkNTUTApp)) {
      //代表有任務錯誤
      bool pass = await NTUTAppConnector.checkLogin();
      if (!pass) {
        loginSystem += checkNTUTApp;
      }
    }
    MyProgressDialog.hideProgressDialog();
    Log.d("loginSystem: $loginSystem");
    if (loginSystem.isEmpty) {
      return TaskStatus.TaskSuccess;
    } else {
      Model.instance.setTempData(tempDataKey, loginSystem);
      return TaskStatus.TaskFail;
    }
  }
}
