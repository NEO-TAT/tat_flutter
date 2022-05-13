// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'package:flutter_app/src/connector/score_connector.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/task/ntut/ntut_task.dart';
import 'package:flutter_app/ui/other/error_dialog.dart';

import '../task.dart';

class ScoreSystemTask<T> extends NTUTTask<T> {
  ScoreSystemTask(String name) : super(name);
  static bool isLogin = false;

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (isLogin) return TaskStatus.success;
    name = "ScoreSystemTask $name";
    if (status == TaskStatus.success) {
      isLogin = true;
      super.onStart(R.current.loginScore);
      ScoreConnectorStatus value = await ScoreConnector.login();
      super.onEnd();
      if (value != ScoreConnectorStatus.loginSuccess) {
        return await onError(R.current.loginScoreError);
      }
    }
    return status;
  }

  @override
  Future<TaskStatus> onError(String message) {
    isLogin = false;
    return super.onError(message);
  }

  @override
  Future<TaskStatus> onErrorParameter(ErrorDialogParameter parameter) {
    isLogin = false;
    return super.onErrorParameter(parameter);
  }
}