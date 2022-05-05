// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.16

import 'dart:async';

import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:get/get.dart';
import 'package:tat_core/core/zuvio/domain/login_credential.dart';
import 'package:tat_core/core/zuvio/usecase/login_use_case.dart';

typedef _UISuspendedTransaction<T> = FutureOr<T> Function();

class ZLoginBoxController extends GetxController {
  ZLoginBoxController({
    required this.isLoginBtnEnabled,
    required this.isInputBoxesEnabled,
    required ZLoginUseCase loginUseCase,
  }) : _loginUseCase = loginUseCase;

  static ZLoginBoxController get to => Get.find();

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

  Future<void> _login(String username, String password) async {
    final loginCredential = ZLoginCredential(email: username, password: password);
    final result = await _loginUseCase(credential: loginCredential);

    if (result.userInfo == null) {
      Log.d('Zuvio login failed.');

      ErrorDialog(ErrorDialogParameter(
        desc: result.msg,
        title: R.current.error,
      )).show();

      return;
    }

    Log.d('Zuvio login successfully.');
  }

  Future<void> login(String username, String password) =>
      _suspendInteractionsTransaction(transaction: () => _login(username, password));
}