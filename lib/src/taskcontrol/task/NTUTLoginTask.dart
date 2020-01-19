import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/src/connector/NTUTConnector.dart';
import 'package:flutter_app/src/store/DataModel.dart';
import 'package:flutter_app/src/store/dataformat/UserData.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/task/TaskModel.dart';
import 'package:flutter_app/ui/other/CustomRoute.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';
import 'package:flutter_app/ui/pages/login/LoginPage.dart';

class NTUTLoginTask extends TaskModel{
  static final String taskName = "NTUTLoginTask";
  NTUTLoginTask(BuildContext context) : super(context , taskName);


  @override
  Future<TaskStatus> taskStart() async{
    UserData user = DataModel.instance.user;
    String account = user.account;
    String password = user.password;
    MyProgressDialog.showProgressDialog(context, S.current.loggingNTUT);
    try{
      NTUTLoginStatus value = await NTUTConnector.login(account, password);
      MyProgressDialog.hideProgressDialog();
      if( value != NTUTLoginStatus.LoginSuccess){
        _handleLoginError(value);
        return TaskStatus.TaskFail;
      }else{
        return TaskStatus.TaskSuccess;
      }
    }on Exception catch(e) {
      MyProgressDialog.hideProgressDialog();
      Log.e(e.toString());
      return TaskStatus.TaskFail;
    }
  }

  void _handleLoginError( NTUTLoginStatus value){
    switch (value) {
      case NTUTLoginStatus.PasswordExpiredWarning:
        AwesomeDialog(
            context: context,
            dialogType: DialogType.INFO,
            animType: AnimType.BOTTOMSLIDE,
            tittle: S.current.alertError,
            desc: S.current.passwordExpiredWarning,
            btnOkText: S.current.updatePassword ,
            btnCancelText: S.current.cancel,
            useRootNavigator : true,
            btnCancelOnPress: () {},
            btnOkOnPress: () {
              _reLogin();
            }
        ).show();
        break;
      case NTUTLoginStatus.AccountLockWarning:
        AwesomeDialog(
            context: context,
            dialogType: DialogType.INFO,
            animType: AnimType.BOTTOMSLIDE,
            tittle: S.current.alertError,
            desc: S.current.accountLock,
            btnOkText: S.current.restart ,
            btnCancelText: S.current.cancel,
            useRootNavigator : true,
            btnCancelOnPress: () {},
            btnOkOnPress: () {
              _reLogin();
            }
        ).show();
        break;
      case NTUTLoginStatus.AccountPasswordIncorrect:
        AwesomeDialog(
            context: context,
            dialogType: DialogType.INFO,
            animType: AnimType.BOTTOMSLIDE,
            tittle: S.current.alertError,
            desc: S.current.accountPasswordFail,
            btnOkText: S.current.resetAccountPassword ,
            btnCancelText: S.current.cancel,
            useRootNavigator : true,
            btnCancelOnPress: () {},
            btnOkOnPress: () {
              Navigator.of(context).push( CustomRoute(LoginPage() ));
            }
        ).show();
        break;
      case NTUTLoginStatus.ConnectTimeOutError:
        AwesomeDialog(
            context: context,
            dialogType: DialogType.ERROR,
            animType: AnimType.BOTTOMSLIDE,
            tittle: S.current.alertError,
            desc: S.current.connectTimeOut,
            btnOkText: S.current.restart ,
            btnCancelText: S.current.cancel,
            useRootNavigator : true,
            btnCancelOnPress: () {},
            btnOkOnPress: () {
              _reLogin();
            }
        ).show();
        break;
      case NTUTLoginStatus.AuthCodeFailError:
        AwesomeDialog(
            context: context,
            dialogType: DialogType.ERROR,
            animType: AnimType.BOTTOMSLIDE,
            tittle: S.current.alertError,
            desc: S.current.authCodeFail,
            btnOkText: S.current.restart ,
            btnCancelText: S.current.cancel,
            useRootNavigator : true,
            btnCancelOnPress: () {},
            btnOkOnPress: () {
              _reLogin();
            }
        ).show();
        break;
      case NTUTLoginStatus.NetworkError:
        AwesomeDialog(
            context: context,
            dialogType: DialogType.ERROR,
            animType: AnimType.BOTTOMSLIDE,
            tittle: S.current.alertError,
            desc: S.current.networkError,
            btnOkText: S.current.restart ,
            btnCancelText: S.current.cancel,
            useRootNavigator : true,
            btnCancelOnPress: () {},
            btnOkOnPress: () {
              _reLogin();
            }
        ).show();
        break;
      default:
        AwesomeDialog(
            context: context,
            dialogType: DialogType.ERROR,
            animType: AnimType.BOTTOMSLIDE,
            tittle: S.current.alertError,
            desc: S.current.unknownError,
            btnOkText: S.current.restart ,
            btnCancelText: S.current.cancel,
            useRootNavigator : true,
            btnCancelOnPress: () {},
            btnOkOnPress: () {
              _reLogin();
            },
        ).show();
        Log.d(value.toString());
        break;
    }
  }

  void _reLogin(){
    TaskHandler.instance.startTask();
  }




}