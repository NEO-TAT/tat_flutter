import 'package:flutter/cupertino.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/ScoreConnector.dart';
import 'package:flutter_app/src/model/course/CourseScoreJson.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/taskcontrol/task/CheckCookiesTask.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';

class ScoreRankTask extends TaskModel {
  static final String taskName = "ScoreRankTask";
  static final List<String> require = [CheckCookiesTask.checkScore];
  static String tempDataKey = "ScoreRankTempKey";

  ScoreRankTask(BuildContext context) : super(context, taskName, require);

  @override
  Future<TaskStatus> taskStart() async {
    MyProgressDialog.showProgressDialog(context, R.current.getScoreRank);
    List<SemesterCourseScoreJson> courseList =
        await ScoreConnector.getScoreRankList();
    MyProgressDialog.hideProgressDialog();
    if (courseList == null) {
      _handleError();
      return TaskStatus.TaskFail;
    } else {
      Model.instance.setTempData(tempDataKey, courseList);
      return TaskStatus.TaskSuccess;
    }
  }

  void _handleError() {
    ErrorDialogParameter parameter = ErrorDialogParameter(
      context: context,
      desc: R.current.getScoreRankError,
    );
    ErrorDialog(parameter).show();
  }
}
