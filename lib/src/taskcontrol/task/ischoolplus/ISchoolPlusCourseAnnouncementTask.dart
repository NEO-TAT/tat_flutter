import 'package:flutter/cupertino.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/ISchoolPlusConnector.dart';
import 'package:flutter_app/src/json/ISchoolPlusAnnouncementJson.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/object/CourseFileJson.dart';
import 'package:flutter_app/src/taskcontrol/task/CheckCookiesTask.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';

class ISchoolPlusCourseAnnouncementTask extends TaskModel {
  static final String taskName = "ISchoolPlusCourseFileTask";
  static final List<String> require = [CheckCookiesTask.checkPlusISchool];
  final String courseId;
  static String announcementListTempKey =
      "ISchoolPlusCourseAnnouncementTempKey";

  ISchoolPlusCourseAnnouncementTask(BuildContext context, this.courseId)
      : super(context, taskName , require);

  @override
  Future<TaskStatus> taskStart() async {
    MyProgressDialog.showProgressDialog(
        context, R.current.getISchoolPlusCourseAnnouncement);
    List<ISchoolPlusAnnouncementJson> value =
        await ISchoolPlusConnector.getCourseAnnouncement(courseId);
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
      desc: R.current.getISchoolPlusCourseAnnouncementError,
    );
    ErrorDialog(parameter).show();
  }
}
