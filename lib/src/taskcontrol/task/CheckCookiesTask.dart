import 'package:flutter/cupertino.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/src/connector/ISchoolConnector.dart';
import 'package:flutter_app/src/connector/NTUTConnector.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';

class CheckCookiesTask extends TaskModel{
  static final String taskName = "CheckCookiesTask";
  CheckCookiesTask(BuildContext context) : super(context , taskName);

  @override
  Future<TaskStatus> taskStart() async{
    MyProgressDialog.showProgressDialog(context, S.current.checkLogin);
    bool isLoginNTUT = await NTUTConnector.checkLogin();
    bool isLoginSchool = await ISchoolConnector.checkLogin();
    MyProgressDialog.hideProgressDialog();
    if( isLoginSchool && isLoginNTUT){
      return TaskStatus.TaskSuccess;
    }else{
      return TaskStatus.TaskFail;
    }
  }
}