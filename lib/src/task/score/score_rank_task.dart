// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter_app/src/connector/score_connector.dart';
import 'package:flutter_app/src/model/course/course_score_json.dart';
import 'package:flutter_app/src/r.dart';

import '../task.dart';
import 'score_system_task.dart';

class ScoreRankTask extends ScoreSystemTask<List<SemesterCourseScoreJson>> {
  ScoreRankTask() : super("ScoreRankTask");

  @override
  Future<TaskStatus> execute() async {
    final status = await super.execute();
    if (status == TaskStatus.success) {
      super.onStart(R.current.getScoreRank);
      final value = await ScoreConnector.getScoreRankList() as List<SemesterCourseScoreJson>?;
      super.onEnd();
      if (value != null) {
        result = value;
        return TaskStatus.success;
      } else {
        return super.onError(R.current.getScoreRankError);
      }
    }
    return status;
  }
}
