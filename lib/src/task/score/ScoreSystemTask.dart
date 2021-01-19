import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/ScoreConnector.dart';
import 'package:flutter_app/src/task/ntut/NTUTTask.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';

import '../Task.dart';

class ScoreSystemTask<T> extends NTUTTask<T> {
  ScoreSystemTask(String name) : super(name);
  static bool _isLogin = false;

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (_isLogin) return TaskStatus.Success;
    name = "ScoreSystemTask " + name;
    if (status == TaskStatus.Success) {
      _isLogin = true;
      super.onStart(R.current.loginScore);
      ScoreConnectorStatus value = await ScoreConnector.login();
      super.onEnd();
      if (value != ScoreConnectorStatus.LoginSuccess) {
        return await onError(R.current.loginScoreError);
      }
    }
    return status;
  }

  @override
  Future<TaskStatus> onError(String message) {
    _isLogin = false;
    return super.onError(message);
  }

  @override
  Future<TaskStatus> onErrorParameter(ErrorDialogParameter parameter) {
    _isLogin = false;
    return super.onErrorParameter(parameter);
  }
}
