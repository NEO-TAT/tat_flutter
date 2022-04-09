import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/ScoreConnector.dart';
import 'package:flutter_app/src/model/course/CourseScoreJson.dart';

import '../Task.dart';
import 'ScoreSystemTask.dart';

class ScoreRankTask extends ScoreSystemTask<List<SemesterCourseScoreJson>> {
  ScoreRankTask() : super("ScoreRankTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.Success) {
      super.onStart(R.current.getScoreRank);
      List<SemesterCourseScoreJson> value = await ScoreConnector.getScoreRankList();
      super.onEnd();
      if (value != null) {
        result = value;
        return TaskStatus.Success;
      } else {
        return await super.onError(R.current.getScoreRankError);
      }
    }
    return status;
  }
}
