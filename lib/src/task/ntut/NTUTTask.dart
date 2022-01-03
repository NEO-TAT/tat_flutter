import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/NTUTConnector.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/task/Task.dart';
import 'package:flutter_app/src/task/ntutapp/NTUTAppTask.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:flutter_app/ui/screen/LoginScreen.dart';
import 'package:get/get.dart';

import '../DialogTask.dart';

class NTUTTask<T> extends DialogTask<T> {
  static bool _isLogin = false;

  NTUTTask(name) : super(name);

  static set isLogin(bool value) {
    _isLogin = value;
  }

  @override
  Future<TaskStatus> execute() async {
    if (_isLogin) return TaskStatus.Success;
    name = "NTUTTask " + name;
    String account = Model.instance.getAccount();
    String password = Model.instance.getPassword();
    if (account.isEmpty || password.isEmpty) {
      return TaskStatus.GiveUp;
    }
    super.onStart(R.current.loginNTUT);
    NTUTConnectorStatus value = await NTUTConnector.login(account, password);
    super.onEnd();
    NTUTAppTask.isLogin = false;
    if (value == NTUTConnectorStatus.LoginSuccess) {
      _isLogin = true;
      print('#########################');
      return TaskStatus.Success;
    } else {
      print('@@@@@@@@@@@@@@@@@@@@@@@@@@');
      return await _onError(value);
    }
  }

  Future<TaskStatus> _onError(NTUTConnectorStatus value) async {
    ErrorDialogParameter parameter = ErrorDialogParameter(
      desc: "",
    );
    switch (value) {
      case NTUTConnectorStatus.AccountLockWarning:
        parameter.dialogType = DialogType.INFO;
        parameter.desc = R.current.accountLock;
        break;
      case NTUTConnectorStatus.AccountPasswordIncorrect:
        parameter.dialogType = DialogType.INFO;
        parameter.desc = R.current.accountPasswordError;
        parameter.btnOkText = R.current.setting;
        parameter.btnOkOnPress = () {
          Get.to(LoginScreen()).then((value) => Get.back<bool>(result: true));
        };
        break;
      case NTUTConnectorStatus.AuthCodeFailError:
        parameter.desc = R.current.authCodeFail;
        break;
      default:
        parameter.desc = R.current.unknownError;
        break;
    }
    return await onErrorParameter(parameter);
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
