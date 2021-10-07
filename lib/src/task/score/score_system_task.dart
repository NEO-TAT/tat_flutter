import 'package:tat/src/R.dart';
import 'package:tat/src/connector/score_connector.dart';
import 'package:tat/src/task/ntut/ntut_task.dart';
import 'package:tat/ui/other/error_dialog.dart';

import '../task.dart';

class ScoreSystemTask<T> extends NTUTTask<T> {
  ScoreSystemTask(String name) : super(name);
  static bool isLogin = false;

  @override
  Future<TaskStatus> execute() async {
    final status = await super.execute();
    if (isLogin) return TaskStatus.Success;
    name = "ScoreSystemTask " + name;

    if (status == TaskStatus.Success) {
      isLogin = true;
      super.onStart(R.current.loginScore);
      final value = await ScoreConnector.login();
      super.onEnd();

      if (value != ScoreConnectorStatus.LoginSuccess) {
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
