// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/connector/ntut_connector.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:flutter_app/src/task/task.dart';
import 'package:flutter_app/ui/other/msg_dialog.dart';
import 'package:flutter_app/ui/other/route_utils.dart';
import 'package:get/get.dart';
import 'package:tat_core/tat_core.dart';

import '../cache_task.dart';

class NTUTTask<T> extends CacheTask<T> {
  static bool _isLogin = false;

  NTUTTask(name) : super("NTUTTask $name");

  static set isLogin(bool value) {
    _isLogin = value;
  }

  @override
  Future<TaskStatus> execute() async {
    final account = LocalStorage.instance.getAccount();
    final password = LocalStorage.instance.getPassword();
    checkCache();

    if (account.isEmpty || password.isEmpty) {
      _isLogin = false;
      LocalStorage.instance.logout();
      RouteUtils.toLoginScreen();
      return TaskStatus.shouldGiveUp;
    }

    if (_isLogin) {
      // Strictly check if the current session is still alive.
      // This is because the school's backend only allow one session at the same time.
      // So if current session was expired or hijacked by other client, we should try to login again.

      final checkSessionUseCase = Get.find<CheckSessionUseCase>();

      super.onStart(R.current.loading);
      final isCurrentSessionAlive = await checkSessionUseCase();
      super.onEnd();

      if (isCurrentSessionAlive) {
        return TaskStatus.success;
      }
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
    final parameter = MsgDialogParameter(
      desc: R.current.unknownServerError,
      dialogType: DialogType.warning,
      removeCancelButton: true,
    );

    TaskStatus taskStatus = TaskStatus.shouldIgnore;
    bool shouldShowDialog = false;
    bool shouldLogout = false;
    bool shouldWipeData = false;

    switch (status) {
      case AccountStatus.normal:
        // If the status is normal, we will do nothing and let the task continue.
        taskStatus = TaskStatus.success;
        break;
      case AccountStatus.locked:
        // If the status is locked, we will prepare to show the error dialog.
        shouldShowDialog = true;
        // And we will not allow the user to continue the task.
        parameter.desc = R.current.accountLock;
        taskStatus = TaskStatus.shouldGiveUp;
        // Force to mark the login status as false, so that the user will be forced to login again.
        shouldLogout = true;
        break;
      case AccountStatus.receivedInvalidCredential:
        // If the status is credential invalid, we will prepare to show the error dialog.
        shouldShowDialog = true;
        // And we will not allow the user to continue the task.
        parameter.desc = R.current.accountPasswordError;
        parameter.okButtonText = R.current.restart;
        parameter.dialogType = DialogType.error;
        taskStatus = TaskStatus.shouldGiveUp;
        // Force to mark the login status as false, so that the user will be forced to login again.
        shouldLogout = true;
        shouldWipeData = true;
        break;
      case AccountStatus.passwordExpired:
        // If the status is password expired, we will prepare to show the error dialog.
        shouldShowDialog = true;
        // And we will not allow the user to continue the task.
        parameter.desc = R.current.passwordExpiredWarning;
        parameter.title = R.current.warning;
        taskStatus = TaskStatus.shouldGiveUp;
        // Force to mark the login status as false, so that the user will be forced to login again.
        shouldLogout = true;
        // Note that we don't need to wipe the data here, since the user can login again with the new password.
        // This is different from the credential invalid case.
        break;
      case AccountStatus.passwordWillExpired:
        // If the status is password expired, we will prepare to show the error dialog.
        shouldShowDialog = true;
        // But we will still let the user to continue the task, since the user may want to change the password,
        // or the password expiration time is not come yet.
        parameter.desc = R.current.passwordWillExpiredWarning;
        parameter.title = R.current.warning;
        taskStatus = TaskStatus.success;
        break;
      case AccountStatus.needsVerifyMobile:
        // If the status is mobile not verified, we will prepare to show the error dialog.

        // TODO: inspect sending params to the main screen through route for showing the dialog.
        // For urgent fix, we will not show the dialog here.
        shouldShowDialog = false;
        // But we will still let the user to continue the task, since the user may not want to verify the mobile.
        parameter.desc = R.current.needsVerifyMobileWarning;
        parameter.dialogType = DialogType.info;
        parameter.title = R.current.warning;
        taskStatus = TaskStatus.success;
        break;
      default:
        // If the status is unknown, we will prepare to show the error dialog.
        shouldShowDialog = true;
        parameter.desc = R.current.unknownServerError;
        break;
    }

    if (shouldWipeData) {
      LocalStorage.instance.logout();
    }

    if (shouldLogout) {
      RouteUtils.toLoginScreen();
      // This is aim to invalidate the login status, prevent it use the previous one.
      _isLogin = false;
    }

    if (shouldShowDialog) {
      return await msgDialogShownResult(msgDialogParam: parameter, result: taskStatus);
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
  Future<TaskStatus> onErrorParameter(MsgDialogParameter parameter) {
    // This is aim to invalidate the login status, make it trigger the login task again.
    _isLogin = false;
    return super.onErrorParameter(parameter);
  }
}
