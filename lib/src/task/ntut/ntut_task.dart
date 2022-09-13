// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_app/src/connector/ntut_connector.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:flutter_app/src/task/task.dart';
import 'package:flutter_app/ui/other/error_dialog.dart';
import 'package:flutter_app/ui/other/route_utils.dart';
import 'package:flutter_app/debug/log/log.dart';

import '../dialog_task.dart';

class NTUTTask<T> extends DialogTask<T> {
  static bool _isLogin = false;

  NTUTTask(name) : super("NTUTTask $name");

  static set isLogin(bool value) {
    _isLogin = value;
  }

  @override
  Future<TaskStatus> execute() async {
    if (_isLogin) return TaskStatus.success;

    final account = LocalStorage.instance.getAccount();
    final password = LocalStorage.instance.getPassword();

    if (account.isEmpty || password.isEmpty) {
      return TaskStatus.shouldGiveUp;
    }

    try {
      super.onStart(R.current.loginNTUT);
      final loginResult = await NTUTConnector.login(account, password);
      super.onEnd();

      if (loginResult == NTUTConnectorStatus.loginSuccess) {
        _isLogin = true;
        return TaskStatus.success;
      }

      return _onError(loginResult);
    } catch(e, stackTrace) {
      // When some errors happened, such as server timeout, we directly return
      // an unknown type status to the error handle function.
      Log.error(e, stackTrace);
      return _onError(NTUTConnectorStatus.unknownError);
    }
  }

  Future<TaskStatus> _onError(NTUTConnectorStatus status) {
    final parameter = ErrorDialogParameter(
      desc: "",
      dialogType: DialogType.WARNING,
      offCancelBtn: true,
    );

    switch (status) {
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
