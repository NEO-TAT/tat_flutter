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
    final account = LocalStorage.instance.getAccount();
    final password = LocalStorage.instance.getPassword();

    if (account.isEmpty || password.isEmpty) {
      _isLogin = false;
      LocalStorage.instance.logout();
      RouteUtils.toLoginScreen();
      return TaskStatus.shouldGiveUp;
    } else if (_isLogin) {
      return TaskStatus.success;
    }

    try {
      super.onStart(R.current.loginNTUT);
      final loginResult = await NTUTConnector.login(account, password);
      super.onEnd();

      _isLogin = loginResult.isSuccess;

      return _handleConnectorStatus(loginResult.accountStatus);
    } catch (e, stackTrace) {
      // When some errors happened, such as server timeout, we directly return
      // an unknown type status to the error handle function.
      Log.error(e, stackTrace);
      return _handleConnectorStatus(AccountStatus.unknown);
    }
  }

  /// Handle the account status from the connector.
  ///
  /// If the login status is false, we will force the user to login again.
  /// Otherwise, we will show the error dialog to the user, but still let the user to continue the task.
  Future<TaskStatus> _handleConnectorStatus(AccountStatus status) async {
    final parameter = ErrorDialogParameter(
      desc: R.current.unknownServerError,
      dialogType: DialogType.warning,
      offCancelBtn: true,
    );

    TaskStatus taskStatus = TaskStatus.shouldIgnore;

    switch (status) {
      case AccountStatus.normal:
        // If the status is normal, we will do nothing and let the task continue.
        taskStatus = TaskStatus.success;
        break;
      case AccountStatus.locked:
        // If the status is locked, we will prepare to show the error dialog.
        // And we will not allow the user to continue the task.
        parameter.desc = R.current.accountLock;
        taskStatus = TaskStatus.shouldGiveUp;
        break;
      case AccountStatus.receivedInvalidCredential:
        // If the status is credential invalid, we will prepare to show the error dialog.
        // And we will not allow the user to continue the task.
        parameter.desc = R.current.accountPasswordError;
        parameter.btnOkText = R.current.restart;
        parameter.dialogType = DialogType.error;
        taskStatus = TaskStatus.shouldGiveUp;
        break;
      case AccountStatus.needsResetPassword:
        // If the status is password expired, we will prepare to show the error dialog.
        // But we will still let the user to continue the task, since the user may want to change the password,
        // or the password expiration time is not come yet.
        // TODO: analyze the password `really` expired response from the server.
        parameter.desc = R.current.passwordExpiredWarning;
        parameter.title = R.current.warning;
        taskStatus = TaskStatus.success;
        break;
      case AccountStatus.needsVerifyMobile:
        // If the status is mobile not verified, we will prepare to show the error dialog.
        // But we will still let the user to continue the task, since the user may not want to verify the mobile.
        parameter.desc = R.current.needsVerifyMobileWarning;
        parameter.dialogType = DialogType.info;
        parameter.title = R.current.warning;
        taskStatus = TaskStatus.success;
        break;
      default:
        // If the status is unknown, we will prepare to show the error dialog.
        parameter.desc = R.current.unknownServerError;
        break;
    }

    // We will logout the user when the server returned unsuccessful result.
    if (!_isLogin) {
      LocalStorage.instance.logout();
      RouteUtils.toLoginScreen();

      if (status != AccountStatus.normal) {
        return onErrorParameter(parameter);
      }
    } else if (status != AccountStatus.normal && status != AccountStatus.needsVerifyMobile) {
      // We will prevent to show the error dialog when the status is normal,
      // or mobile verify requested.
      ErrorDialog(parameter).show();
    }

    return taskStatus;
  }

  @override
  Future<TaskStatus> onError(String message) {
    // This is aim to invalidate the login status, make it trigger the login task again.
    _isLogin = false;
    return super.onError(message);
  }

  @override
  Future<TaskStatus> onErrorParameter(ErrorDialogParameter parameter) {
    // This is aim to invalidate the login status, make it trigger the login task again.
    _isLogin = false;
    return super.onErrorParameter(parameter);
  }
}
