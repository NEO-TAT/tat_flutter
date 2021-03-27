import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/ntut_connector.dart';
import 'package:flutter_app/src/store/model.dart';
import 'package:flutter_app/src/task/task.dart';
import 'package:flutter_app/ui/other/error_dialog.dart';
import 'package:flutter_app/ui/pages/password/change_password.dart';
import 'package:flutter_app/ui/screen/login_screen.dart';
import 'package:get/get.dart';

import '../dialog_task.dart';

class NTUTTask<T> extends DialogTask<T> {
  static bool _remindPasswordExpiredWarning = false;
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
    if (value == NTUTConnectorStatus.LoginSuccess) {
      _isLogin = true;
      return TaskStatus.Success;
    } else {
      return await _onError(value);
    }
  }

  Future<TaskStatus> _onError(NTUTConnectorStatus value) async {
    ErrorDialogParameter parameter = ErrorDialogParameter(
      desc: "",
    );
    switch (value) {
      case NTUTConnectorStatus.PasswordExpiredWarning:
        if (_remindPasswordExpiredWarning)
          return TaskStatus.Success; //只執行一次避免進入無限迴圈
        _remindPasswordExpiredWarning = true;
        parameter.dialogType = DialogType.INFO;
        parameter.title = R.current.warning;
        parameter.desc = R.current.passwordExpiredWarning;
        parameter.btnOkText = R.current.update;
        parameter.btnOkOnPress = () async {
          await ChangePassword.show();
          Get.back<bool>(result: false);
        };
        parameter.btnCancelOnPress = () {
          Get.back<bool>(result: true);
        };
        break;
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
