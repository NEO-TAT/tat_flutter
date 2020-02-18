import 'package:flutter/cupertino.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/src/connector/ScoreConnector.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/CourseScoreJson.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';
import 'CheckCookiesTask.dart';
import 'TaskModel.dart';

class ScoreRankTask extends TaskModel {
  static final String taskName = "ScoreRankTask" + CheckCookiesTask.checkNTUT ;
  static String scoreRankTempKey = "ScoreRankTempKey";
  ScoreRankTask(BuildContext context) : super(context, taskName);

  @override
  Future<TaskStatus> taskStart() async {
    MyProgressDialog.showProgressDialog(context, S.current.getScoreRank);
    ScoreConnectorStatus value = await ScoreConnector.login();
    List<CourseScoreJson> courseList = await ScoreConnector.getScoreRankList();
    MyProgressDialog.hideProgressDialog();
    if (value != ScoreConnectorStatus.LoginSuccess || courseList == null ) {
      _handleError();
      return TaskStatus.TaskFail;
    } else {
      Model.instance.setTempData(scoreRankTempKey, courseList);
      return TaskStatus.TaskSuccess;
    }
  }

  void _handleError() {
    ErrorDialogParameter parameter = ErrorDialogParameter(
      context: context,
      desc: S.current.getScoreRankError,
    );
    ErrorDialog(parameter).show();
  }
}