import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/NTUTAppConnector.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/task/DialogTask.dart';
import 'package:flutter_app/src/task/Task.dart';
import 'package:flutter_app/src/task/ntut/NTUTTask.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';

class NTUTAppTask<T> extends DialogTask<T> {
  static bool _isLogin = false;

  NTUTAppTask(name) : super(name);

  static set isLogin(bool value) {
    _isLogin = value;
  }

  @override
  Future<TaskStatus> execute() async {
    if (_isLogin) return TaskStatus.Success;
    name = "NTUTAppTask " + name;
    String account = Model.instance.getAccount();
    String password = Model.instance.getPassword();
    if(account.isEmpty || password.isEmpty){
      return TaskStatus.GiveUp;
    }
    super.onStart(R.current.loginNTUTApp);
    NTUTAppConnectorStatus value =
        await NTUTAppConnector.login(account, password);
    super.onEnd();
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
