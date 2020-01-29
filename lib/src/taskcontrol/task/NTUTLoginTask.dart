import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/src/connector/NTUTConnector.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';
import 'package:flutter_app/ui/other/CustomRoute.dart';
import 'package:flutter_app/ui/other/MyAlertDialog.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';
import 'package:flutter_app/ui/pages/bottomnavigationbar/bottom_navigation_widget.dart';
import 'package:flutter_app/ui/pages/login/LoginPage.dart';

import '../../../main.dart';
import '../../store/Model.dart';
import '../../store/json/UserDataJson.dart';

class NTUTLoginTask extends TaskModel {
  static final String taskName = "NTUTLoginTask";

  NTUTLoginTask(BuildContext context) : super(context, taskName);

  @override
  Future<TaskStatus> taskStart() async {
    UserDataJson userData = Model.instance.userData ;
    String account = userData.account;
    String password = userData.password;
    MyProgressDialog.showProgressDialog(context, S.current.loggingNTUT);
    NTUTConnectorStatus value = await NTUTConnector.login(account, password);
    MyProgressDialog.hideProgressDialog();
    if (value != NTUTConnectorStatus.LoginSuccess) {
      _handleError(value);
      return TaskStatus.TaskFail;
    } else {
      return TaskStatus.TaskSuccess;
    }
  }

  void _handleError(NTUTConnectorStatus value) {
    switch (value) {
      case NTUTConnectorStatus.PasswordExpiredWarning:
        AwesomeDialog(
            context: context,
            dialogType: DialogType.INFO,
            animType: AnimType.BOTTOMSLIDE,
            tittle: S.current.alertError,
            desc: S.current.passwordExpiredWarning,
            btnOkText: S.current.updatePassword,
            btnCancelText: S.current.cancel,
            useRootNavigator: true,
            btnCancelOnPress: () {},
            btnOkOnPress: () {
              _reLogin();
            }).show();
        break;
      case NTUTConnectorStatus.AccountLockWarning:
        AwesomeDialog(
            context: context,
            dialogType: DialogType.INFO,
            animType: AnimType.BOTTOMSLIDE,
            tittle: S.current.alertError,
            desc: S.current.accountLock,
            btnOkText: S.current.restart,
            btnCancelText: S.current.cancel,
            useRootNavigator: true,
            btnCancelOnPress: () {},
            btnOkOnPress: () {
              _reLogin();
            }).show();
        break;
      case NTUTConnectorStatus.AccountPasswordIncorrect:
        AwesomeDialog(
            context: context,
            dialogType: DialogType.INFO,
            animType: AnimType.BOTTOMSLIDE,
            tittle: S.current.alertError,
            desc: S.current.accountPasswordFail,
            btnOkText: S.current.resetAccountPassword,
            btnCancelText: S.current.cancel,
            useRootNavigator: true,
            btnCancelOnPress: () {},
            btnOkOnPress: () {
              Navigator.of(context).push(CustomRoute(LoginPage()));
            }).show();
        break;
      case NTUTConnectorStatus.ConnectTimeOutError:
        AwesomeDialog(
            context: context,
            dialogType: DialogType.ERROR,
            animType: AnimType.BOTTOMSLIDE,
            tittle: S.current.alertError,
            desc: S.current.connectTimeOut,
            btnOkText: S.current.restart,
            btnCancelText: S.current.cancel,
            useRootNavigator: true,
            btnCancelOnPress: () {},
            btnOkOnPress: () {
              _reLogin();
            }).show();
        break;
      case NTUTConnectorStatus.AuthCodeFailError:
        AwesomeDialog(
            context: context,
            dialogType: DialogType.ERROR,
            animType: AnimType.BOTTOMSLIDE,
            tittle: S.current.alertError,
            desc: S.current.authCodeFail,
            btnOkText: S.current.restart,
            btnCancelText: S.current.cancel,
            useRootNavigator: true,
            btnCancelOnPress: () {},
            btnOkOnPress: () {
              _reLogin();
            }).show();
        break;
      case NTUTConnectorStatus.NetworkError:
        AwesomeDialog(
            context: context,
            dialogType: DialogType.ERROR,
            animType: AnimType.BOTTOMSLIDE,
            tittle: S.current.alertError,
            desc: S.current.networkError,
            btnOkText: S.current.restart,
            btnCancelText: S.current.cancel,
            useRootNavigator: true,
            btnCancelOnPress: () {},
            btnOkOnPress: () {
              _reLogin();
            }).show();
        break;
      default:
        AwesomeDialog(
          context: context,
          dialogType: DialogType.ERROR,
          animType: AnimType.BOTTOMSLIDE,
          tittle: S.current.alertError,
          desc: S.current.unknownError,
          btnOkText: S.current.restart,
          btnCancelText: S.current.cancel,
          useRootNavigator: true,
          btnCancelOnPress: () {},
          btnOkOnPress: () {
            _reLogin();
          },
        ).show();
        Log.d(value.toString());
        break;
    }
  }

  void _reLogin() {
    reStartTask();
  }
}
