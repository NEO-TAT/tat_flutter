// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter_app/src/connector/score_connector.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/task/ntut/ntut_task.dart';
import 'package:flutter_app/ui/other/error_dialog.dart';

import '../task.dart';

class ScoreSystemTask<T> extends NTUTTask<T> {
  ScoreSystemTask(String name) : super("ScoreSystemTask $name");
  static bool isLogin = false;

  @override
  Future<TaskStatus> execute() async {
    final status = await super.execute();
    if (isLogin) return TaskStatus.success;

    if (status == TaskStatus.success) {
      isLogin = true;

      super.onStart(R.current.loginScore);
      final value = await ScoreConnector.login();
      super.onEnd();

      if (value != ScoreConnectorStatus.loginSuccess) {
        return onError(R.current.loginScoreError);
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
