import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/NTUTAppConnector.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/task/Task.dart';
import 'package:flutter_app/src/task/ntut/NTUTTask.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';

class NTUTAppTask<T> extends Task<T> {
  static bool _remindPasswordExpiredWarning = false;
  static bool _isLogin = false;
  static bool openLoadingDialog = true;

  NTUTAppTask(name) : super(name);

  static set isLogin(bool value) {
    _isLogin = value;
  }

  @override
  Future<TaskStatus> execute() async {
    if (_isLogin) return TaskStatus.Success;
    String account = Model.instance.getAccount();
    String password = Model.instance.getPassword();
    onStart(R.current.loginNTUTApp);
    NTUTAppConnectorStatus value =
        await NTUTAppConnector.login(account, password);
    onEnd();
    NTUTTask.isLogin = false;
    if (value == NTUTAppConnectorStatus.LoginSuccess) {
      _isLogin = true;
      return TaskStatus.Success;
    } else {
      return await onError(R.current.loginNTUTAppError);
    }
  }

  void onStart(String message) {
    if (openLoadingDialog) {
      MyProgressDialog.progressDialog(message);
    }
  }

  void onEnd() {
    if (openLoadingDialog) {
      MyProgressDialog.hideProgressDialog();
    }
  }

  Future<TaskStatus> onError(String message) async {
    ErrorDialogParameter parameter = ErrorDialogParameter(
      desc: message,
    );
    return await onErrorParameter(parameter);
  }

  Future<TaskStatus> onErrorParameter(ErrorDialogParameter parameter) async {
    //可自定義處理Error
    _isLogin = false;
    try {
      return (await ErrorDialog(parameter).show())
          ? TaskStatus.Restart
          : TaskStatus.GiveUp;
    } catch (e) {
      return TaskStatus.GiveUp;
    }
  }
}
