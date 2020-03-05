import 'package:flutter/cupertino.dart';
import 'package:flutter_app/generated/R.dart';
import 'package:flutter_app/src/connector/ISchoolPlusConnector.dart';
import 'package:flutter_app/src/json/ISchoolPlusAnnouncementJson.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/CourseFileJson.dart';
import 'package:flutter_app/src/taskcontrol/task/CheckCookiesTask.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';

class ISchoolPlusCourseAnnouncementDetailTask extends TaskModel {
  static final String taskName = "ISchoolPlusCourseFileTask";
  static final List<String> require = [CheckCookiesTask.checkPlusISchool];
  final ISchoolPlusAnnouncementJson data;
  static String announcementListTempKey =
      "ISchoolPlusCourseAnnouncementDetailTempKey";

  ISchoolPlusCourseAnnouncementDetailTask(BuildContext context, this.data)
      : super(context, taskName, require);

  @override
  Future<TaskStatus> taskStart() async {
    MyProgressDialog.showProgressDialog(
        context, R.current.getISchoolPlusCourseAnnouncementDetail);
    String value = await ISchoolPlusConnector.getCourseAnnouncementDetail(data);
    MyProgressDialog.hideProgressDialog();
    if (value != null) {
      Model.instance.setTempData(announcementListTempKey, value);
      return TaskStatus.TaskSuccess;
    } else {
      _handleError();
      return TaskStatus.TaskFail;
    }
  }

  void _handleError() {
    ErrorDialogParameter parameter = ErrorDialogParameter(
      context: context,
      desc: R.current.getISchoolPlusCourseAnnouncementDetailError,
    );
    ErrorDialog(parameter).show();
  }
}
