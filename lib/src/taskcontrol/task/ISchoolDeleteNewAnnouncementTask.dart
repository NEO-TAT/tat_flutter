import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/src/connector/ISchoolConnector.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/CourseFileJson.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';
import 'CheckCookiesTask.dart';
import 'TaskModel.dart';

class ISchoolDeleteNewAnnouncementTask extends TaskModel{
  static final String taskName = "ISchoolDeleteNewAnnouncementTask" + CheckCookiesTask.checkISchool ;
  final String messageId;
  static final String isDeleteKey = "isDeleteKey";
  ISchoolDeleteNewAnnouncementTask(BuildContext context,this.messageId) : super(context , taskName);

  @override
  Future<TaskStatus> taskStart() async {
    MyProgressDialog.showProgressDialog(context, S.current.deleteMessage );
    bool value = await ISchoolConnector.deleteNewAnnouncement( messageId );
    MyProgressDialog.hideProgressDialog();
    Model.instance.tempData[isDeleteKey] = value;
    if( value != null ){
      if( value ){
        return TaskStatus.TaskSuccess;
      }
      else{
        _handleError();
        return TaskStatus.TaskFail;
      }
    }else{
      _handleError();
      return TaskStatus.TaskFail;
    }
  }


  void _handleError(){
    ErrorDialogParameter parameter = ErrorDialogParameter(
      context: context,
      desc: S.current.deleteMessageError,
    );
    ErrorDialog(parameter).show();

  }

}