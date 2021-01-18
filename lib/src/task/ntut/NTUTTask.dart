import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/NTUTConnector.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/task/Task.dart';
import 'package:flutter_app/src/task/ntutapp/NTUTAppTask.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';
import 'package:flutter_app/ui/pages/password/ChangePassword.dart';
import 'package:flutter_app/ui/screen/LoginScreen.dart';
import 'package:get/get.dart';

class NTUTTask<T> extends Task<T> {
  static bool _remindPasswordExpiredWarning = false;
  static bool _isLogin = false;
  bool openLoadingDialog = true;

  NTUTTask(name) : super(name);

  static set isLogin(bool value) {
    _isLogin = value;
  }

  @override
  Future<TaskStatus> execute() async {
    if (_isLogin) return TaskStatus.Success;
    String account = Model.instance.getAccount();
    String password = Model.instance.getPassword();
    onStart(R.current.loginNTUT);
    NTUTConnectorStatus value = await NTUTConnector.login(account, password);
    onEnd();
    NTUTAppTask.isLogin = false;
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
      case NTUTConnectorStatus.ConnectTimeOutError:
        parameter.desc = R.current.connectTimeOut;
        break;
      case NTUTConnectorStatus.AuthCodeFailError:
        parameter.desc = R.current.authCodeFail;
        break;
      case NTUTConnectorStatus.NetworkError:
        parameter.desc = R.current.networkError;
        break;
      default:
        parameter.desc = R.current.unknownError;
        break;
    }
    return await onErrorParameter(parameter);
  }

  void onStart(String message) {
    if (openLoadingDialog) {
      MyProgressDialog.progressDialog(message);
    }
  }

  void onEnd() {
    if (openLoadingDialog) {
      MyProgressDialog.hideProgressDialog();
    }
  }

  Future<TaskStatus> onError(String message) async {
    ErrorDialogParameter parameter = ErrorDialogParameter(
      desc: message,
    );
    return await onErrorParameter(parameter);
  }

  Future<TaskStatus> onErrorParameter(ErrorDialogParameter parameter) async {
    //可自定義處理Error
    _isLogin = false;
    try {
      return (await ErrorDialog(parameter).show())
          ? TaskStatus.Restart
          : TaskStatus.GiveUp;
    } catch (e) {
      return TaskStatus.GiveUp;
    }
  }
}
