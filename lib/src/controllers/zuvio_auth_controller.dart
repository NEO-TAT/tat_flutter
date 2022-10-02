// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:flutter_app/ui/other/error_dialog.dart';
import 'package:get/get.dart';
import 'package:tat_core/core/zuvio/domain/login_credential.dart';
import 'package:tat_core/core/zuvio/domain/user_info.dart';
import 'package:tat_core/core/zuvio/usecase/login_use_case.dart';

typedef _UISuspendedTransaction<T> = FutureOr<T> Function();

class ZAuthController extends GetxController {
  ZAuthController({
    required this.isLoginBtnEnabled,
    required this.isInputBoxesEnabled,
    required ZLoginUseCase loginUseCase,
  }) : _loginUseCase = loginUseCase;

  static ZAuthController get to => Get.find();

  bool isLoginBtnEnabled;
  bool isInputBoxesEnabled;

  final ZLoginUseCase _loginUseCase;

  void _suspendUIInteractions() {
    isLoginBtnEnabled = false;
    isInputBoxesEnabled = false;
    update();
  }

  void _resumeUIInteractions() {
    isLoginBtnEnabled = true;
    isInputBoxesEnabled = true;
    update();
  }

  FutureOr<T> _suspendInteractionsTransaction<T>({required _UISuspendedTransaction<T> transaction}) async {
    _suspendUIInteractions();
    final result = await transaction();
    _resumeUIInteractions();
    return result;
  }

  Future<void> _saveCredential(ZLoginCredential credential) =>
      LocalStorage.instance.saveZuvioLoginCredential(credential);

  Future<void> _saveUserInfo(ZUserInfo userInfo) => LocalStorage.instance.saveZuvioUserInfo(userInfo);

  Future<void> _login(String username, String password) async {
    final loginCredential = ZLoginCredential(email: username, password: password);
    final result = await _loginUseCase(credential: loginCredential);

    if (result.userInfo == null) {
      Log.d('Zuvio login failed.');

      // TODO: move dialog showing to the UI layer.
      ErrorDialog(ErrorDialogParameter(
        desc: result.msg,
        title: R.current.error,
      )).show();

      return;
    }

    Log.d('Zuvio login successfully.');

    await _saveCredential(loginCredential);
    Log.d('Zuvio login credential saved.');

    await _saveUserInfo(result.userInfo!);
    Log.d('Zuvio user info saved.');

    if (kDebugMode) {
      Log.d(LocalStorage.instance.getZuvioLoginCredential().email);
      Log.d(LocalStorage.instance.getZuvioUserInfo());
    }
  }

  Future<void> login(String username, String password) =>
      _suspendInteractionsTransaction(transaction: () => _login(username, password));

  bool isLoggedIntoZuvio() {
    final accessToken = LocalStorage.instance.getZuvioUserInfo()?.accessToken;

    // TODO(TU): Check if the accessToken is valid.
    return accessToken != null && accessToken.isNotEmpty;
  }

  ZUserInfo? currentZUserInfo() => LocalStorage.instance.getZuvioUserInfo();
}
