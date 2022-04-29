// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.16

import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:get/get.dart';
import 'package:tat_core/core/zuvio/domain/login_credential.dart';
import 'package:tat_core/core/zuvio/usecase/login_use_case.dart';

class LoginBoxController extends GetxController {
  LoginBoxController({
    required this.isLoginBtnEnabled,
    required this.isInputBoxesEnabled,
    required ZLoginUseCase loginUseCase,
  }) : _loginUseCase = loginUseCase;

  static LoginBoxController get to => Get.find();

  bool isLoginBtnEnabled;
  bool isInputBoxesEnabled;
  final ZLoginUseCase _loginUseCase;

  void _postStateUpdates() {
    isLoginBtnEnabled = true;
    isInputBoxesEnabled = true;
    update();
  }

  Future<void> login(String username, String password) async {
    isLoginBtnEnabled = false;
    isInputBoxesEnabled = false;
    update();

    final loginCredential = ZLoginCredential(email: username, password: password);
    final result = await _loginUseCase(credential: loginCredential);

    if (result.userInfo == null) {
      ErrorDialog(ErrorDialogParameter(
        desc: result.msg,
        title: R.current.error,
      )).show();
    }

    _postStateUpdates();
  }
}
