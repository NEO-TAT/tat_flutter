// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_app/src/connector/ntut_connector.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:flutter_app/src/task/task.dart';
import 'package:flutter_app/ui/other/error_dialog.dart';
import 'package:flutter_app/ui/screen/login_screen.dart';
import 'package:get/get.dart';

import '../dialog_task.dart';

class NTUTTask<T> extends DialogTask<T> {
  static bool _isLogin = false;

  NTUTTask(name) : super(name);

  static set isLogin(bool value) {
    _isLogin = value;
  }

  @override
  Future<TaskStatus> execute() async {
    if (_isLogin) return TaskStatus.success;
    name = "NTUTTask $name";
    String account = LocalStorage.instance.getAccount();
    String password = LocalStorage.instance.getPassword();
    if (account.isEmpty || password.isEmpty) {
      return TaskStatus.giveUp;
    }
    super.onStart(R.current.loginNTUT);
    NTUTConnectorStatus value = await NTUTConnector.login(account, password);
    super.onEnd();
    if (value == NTUTConnectorStatus.loginSuccess) {
      _isLogin = true;
      return TaskStatus.success;
    } else {
      return await _onError(value);
    }
  }

  Future<TaskStatus> _onError(NTUTConnectorStatus value) async {
    ErrorDialogParameter parameter = ErrorDialogParameter(
      desc: "",
    );
    switch (value) {
      case NTUTConnectorStatus.accountLockWarning:
        parameter.dialogType = DialogType.INFO;
        parameter.desc = R.current.accountLock;
        break;
      case NTUTConnectorStatus.accountPasswordIncorrect:
        parameter.dialogType = DialogType.INFO;
        parameter.desc = R.current.accountPasswordError;
        parameter.btnOkText = R.current.setting;
        parameter.btnOkOnPress = () {
          Get.to(() => const LoginScreen()).then((value) => Get.back<bool>(result: true));
        };
        break;
      case NTUTConnectorStatus.authCodeFailError:
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