// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/connector/ntut_connector.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:flutter_app/src/task/task.dart';
import 'package:flutter_app/ui/other/error_dialog.dart';
import 'package:flutter_app/ui/other/route_utils.dart';
import 'package:tat_core/core/portal/domain/simple_login_result.dart';

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
      _isLogin = false;
      LocalStorage.instance.logout();
      RouteUtils.toLoginScreen();
      return TaskStatus.shouldGiveUp;
    }

    try {
      super.onStart(R.current.loginNTUT);
      final loginResult = await NTUTConnector.login(account, password);
      super.onEnd();

      if (loginResult == AccountStatus.normal) {
        _isLogin = true;
      }

      return _handleConnectorStatus(loginResult);
    } catch (e, stackTrace) {
      // When some errors happened, such as server timeout, we directly return
      // an unknown type status to the error handle function.
      Log.error(e, stackTrace);
      return _handleConnectorStatus(AccountStatus.unknown);
    }
  }

  Future<TaskStatus> _handleConnectorStatus(AccountStatus status) async {
    final parameter = ErrorDialogParameter(
      desc: "",
      dialogType: DialogType.warning,
      offCancelBtn: true,
    );

    switch (status) {
      case AccountStatus.normal:
        return TaskStatus.success;
      case AccountStatus.locked:
        parameter.desc = R.current.accountLock;
        break;
      case AccountStatus.receivedInvalidCredential:
        parameter.desc = R.current.accountPasswordError;
        parameter.btnOkText = R.current.restart;
        parameter.dialogType = DialogType.error;
        break;
      case AccountStatus.needsResetPassword:
        parameter.desc = R.current.passwordExpiredWarning;
        parameter.title = R.current.warning;
        break;
      case AccountStatus.needsVerifyMobile:
        parameter.desc = R.current.needsVerifyMobileWarning;
        parameter.dialogType = DialogType.info;
        parameter.title = R.current.warning;
        break;
      default:
        parameter.desc = R.current.unknownServerError;
        break;
    }

    // We will logout the user only when the status is password incorrect.
    if (status == AccountStatus.receivedInvalidCredential) {
      LocalStorage.instance.logout();
      RouteUtils.toLoginScreen();
      return onErrorParameter(parameter);
    }

    _isLogin = false;
    ErrorDialog(parameter).show();

    // Ignore all error cases exclude the password incorrect.
    return TaskStatus.shouldIgnore;
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
