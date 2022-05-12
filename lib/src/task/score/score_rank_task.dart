import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/connector/score_connector.dart';
import 'package:flutter_app/src/model/course/course_score_json.dart';

import '../task.dart';
import 'score_system_task.dart';

class ScoreRankTask extends ScoreSystemTask<List<SemesterCourseScoreJson>> {
  ScoreRankTask() : super("ScoreRankTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.success) {
      super.onStart(R.current.getScoreRank);
      List<SemesterCourseScoreJson> value = await ScoreConnector.getScoreRankList();
      super.onEnd();
      if (value != null) {
        result = value;
        return TaskStatus.success;
      } else {
        return await super.onError(R.current.getScoreRankError);
      }
    }
    return status;
  }
}
