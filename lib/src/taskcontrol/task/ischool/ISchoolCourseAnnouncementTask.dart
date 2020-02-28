import 'package:flutter/cupertino.dart';
import 'package:flutter_app/generated/R.dart';
import 'package:flutter_app/src/connector/ISchoolConnector.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/CourseAnnouncementJson.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';

import '../../../../ui/other/ErrorDialog.dart';
import '../CheckCookiesTask.dart';
import '../TaskModel.dart';

class ISchoolCourseAnnouncementTask extends TaskModel {
  static final String taskName =
      "ISchoolCourseAnnouncementTask" + CheckCookiesTask.checkISchool;
  final String courseId;
  static String courseAnnouncementListTempKey = "CourseAnnouncementListTempKey";
  ISchoolCourseAnnouncementTask(BuildContext context, this.courseId)
      : super(context, taskName);

  @override
  Future<TaskStatus> taskStart() async {
    MyProgressDialog.showProgressDialog(
        context, R.current.getISchoolCourseAnnouncement);
    List<CourseAnnouncementJson> value =
        await ISchoolConnector.getCourseAnnouncement(courseId);
    MyProgressDialog.hideProgressDialog();
    if (value != null) {
      Model.instance.setTempData(courseAnnouncementListTempKey, value);
      return TaskStatus.TaskSuccess;
    } else {
      _handleError();
      return TaskStatus.TaskFail;
    }
  }

  void _handleError() {
    ErrorDialogParameter parameter = ErrorDialogParameter(
      context: context,
      desc: R.current.getISchoolCourseAnnouncementError,
    );
    ErrorDialog(parameter).show();
  }
}
