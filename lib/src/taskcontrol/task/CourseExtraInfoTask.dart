import 'package:flutter/cupertino.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/src/connector/CourseConnector.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/CourseMainExtraJson.dart';
import 'package:flutter_app/src/taskcontrol/task/CheckCookiesTask.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';

import '../../../ui/other/ErrorDialog.dart';

class CourseExtraInfoTask extends TaskModel{
  static final String taskName = "CourseExtraInfoTask" + CheckCookiesTask.checkCourse ;
  String id;
  CourseExtraInfoTask(BuildContext context,this.id) : super(context, taskName);
  static String tempDataKey = "CourseExtraInfoJsonTampKey";
  @override
  Future<TaskStatus> taskStart() async{
    MyProgressDialog.showProgressDialog(context, S.current.getCourseDetail );
    CourseExtraInfoJson courseInfo = await CourseConnector.getCourseExtraInfo(id);
    MyProgressDialog.hideProgressDialog();
    if( courseInfo != null ) {
      Model.instance.setTempData(tempDataKey, courseInfo);
      return TaskStatus.TaskSuccess;
    }else {
      _handleError();
      return TaskStatus.TaskFail;
    }
  }

  void _handleError() {
    ErrorDialogParameter parameter = ErrorDialogParameter(
      context: context,
      desc: S.current.getCourseDetailError,
    );
    ErrorDialog(parameter).show();
  }


}