import 'package:tat/src/R.dart';
import 'package:tat/src/connector/score_connector.dart';
import 'package:tat/src/model/course/course_score_json.dart';

import '../task.dart';
import 'score_system_task.dart';

class ScoreRankTask extends ScoreSystemTask<List<SemesterCourseScoreJson>> {
  ScoreRankTask() : super("ScoreRankTask");

  @override
  Future<TaskStatus> execute() async {
    final status = await super.execute();

    if (status == TaskStatus.Success) {
      super.onStart(R.current.getScoreRank);
      final value = await ScoreConnector.getScoreRankList();
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
