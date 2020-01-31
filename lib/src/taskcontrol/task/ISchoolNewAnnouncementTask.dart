import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/src/connector/ISchoolConnector.dart';
import 'package:flutter_app/src/connector/NTUTConnector.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';

import 'TaskModel.dart';

class ISchoolNewAnnouncementTask extends TaskModel{
  static final String taskName = "ISchoolNewAnnouncementTask";
  ISchoolNewAnnouncementTask(BuildContext context) : super(context , taskName);

  @override
  Future<TaskStatus> taskStart() async {
    MyProgressDialog.showProgressDialog(context, S.current.getISchoolNewAnnouncement );
    bool value = await ISchoolConnector.getISchoolNewAnnouncement();
    MyProgressDialog.hideProgressDialog();
    if( value ){
      return TaskStatus.TaskSuccess;
    }else{
      _handleError();
      return TaskStatus.TaskFail;
    }
  }


  void _handleError(){
    AwesomeDialog(
      context: context,
      dialogType: DialogType.ERROR,
      animType: AnimType.BOTTOMSLIDE,
      tittle: S.current.alertError,
      desc: S.current.getISchoolNewAnnouncementError,
      btnOkText: S.current.restart ,
      btnCancelText: S.current.cancel,
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        reStartTask();
      },
    ).show();
  }

}