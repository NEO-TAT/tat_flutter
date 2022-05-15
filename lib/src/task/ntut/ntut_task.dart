// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_app/src/connector/ntut_connector.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:flutter_app/src/task/task.dart';
import 'package:flutter_app/ui/other/error_dialog.dart';
import 'package:flutter_app/ui/other/route_utils.dart';

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
    final account = LocalStorage.instance.getAccount();
    final password = LocalStorage.instance.getPassword();

    if (account.isEmpty || password.isEmpty) {
      return TaskStatus.giveUp;
    }

    super.onStart(R.current.loginNTUT);
    final value = await NTUTConnector.login(account, password);
    super.onEnd();

    if (value == NTUTConnectorStatus.loginSuccess) {
      _isLogin = true;
      await LocalStorage.instance.saveUserData();
      return TaskStatus.success;
    }

    return _onError(value);
  }

  Future<TaskStatus> _onError(NTUTConnectorStatus value) {
    unawaited(RouteUtils.toLoginScreen());

    ErrorDialogParameter parameter = ErrorDialogParameter(
      desc: "",
      dialogType: DialogType.WARNING,
      offCancelBtn: true,
    );

    switch (value) {
      case NTUTConnectorStatus.accountLockWarning:
        parameter.desc = R.current.accountLock;
        break;
      case NTUTConnectorStatus.accountPasswordIncorrect:
        parameter.desc = R.current.accountPasswordError;
        parameter.btnOkText = R.current.restart;
        break;
      case NTUTConnectorStatus.authCodeFailError:
        parameter.desc = R.current.authCodeFail;
        break;
      default:
        parameter.desc = R.current.unknownError;
        break;
    }

    LocalStorage.instance.clearUserData();
    return onErrorParameter(parameter);
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
