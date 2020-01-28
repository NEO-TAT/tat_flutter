import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/src/connector/ISchoolConnector.dart';
import 'package:flutter_app/src/connector/NTUTConnector.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';

class ISchoolLoginTask extends TaskModel {
  static final String taskName = "ISchoolLoginTask";

  ISchoolLoginTask(BuildContext context) : super(context, taskName);

  @override
  Future<TaskStatus> taskStart() async {
    MyProgressDialog.showProgressDialog(context, S.current.loggingISchool);
    ISchoolConnectorStatus value = await ISchoolConnector.login();
    MyProgressDialog.hideProgressDialog();
    if (value == ISchoolConnectorStatus.LoginSuccess) {
      return TaskStatus.TaskSuccess;
    } else {
      _handleError();
      return TaskStatus.TaskFail;
    }
  }

  void _handleError() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.ERROR,
      animType: AnimType.BOTTOMSLIDE,
      tittle: S.current.alertError,
      desc: S.current.loginISchoolFail,
      btnOkText: S.current.restart,
      btnCancelText: S.current.cancel,
      useRootNavigator: true,
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        reStartTask();
      },
    ).show();
  }
}
