import 'package:flutter/cupertino.dart';
import 'package:flutter_app/generated/R.dart';
import 'package:flutter_app/src/connector/ISchoolConnector.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/taskcontrol/task/CheckCookiesTask.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';

class ISchoolNewAnnouncementPageTask extends TaskModel {
  static final String taskName =
      "ISchoolNewAnnouncementPageTask" + CheckCookiesTask.checkISchool;
  ISchoolNewAnnouncementPageTask(BuildContext context)
      : super(context, taskName);

  @override
  Future<TaskStatus> taskStart() async {
    MyProgressDialog.showProgressDialog(
        context, R.current.getISchoolNewAnnouncementPage);
    int value = await ISchoolConnector.getNewAnnouncementPage();
    MyProgressDialog.hideProgressDialog();
    if (value != null) {
      Model.instance.getAnnouncementSetting().maxPage = value;
      return TaskStatus.TaskSuccess;
    } else {
      _handleError();
      return TaskStatus.TaskFail;
    }
  }

  void _handleError() {
    ErrorDialogParameter parameter = ErrorDialogParameter(
      context: context,
      desc: R.current.getISchoolNewAnnouncementPageError,
    );
    ErrorDialog(parameter).show();
  }
}
