import 'package:connectivity/connectivity.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:flutter_app/ui/other/MyProgressDialog.dart';

import 'Task.dart';

class DialogTask<T> extends Task<T> {
  DialogTask(String name) : super(name);
  bool openLoadingDialog = true;

  @override
  Future<TaskStatus> execute() async {
    return TaskStatus.Success;
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
    try {
      var connectivityResult = await (new Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        parameter = ErrorDialogParameter(
          desc: R.current.networkError,
        );
      }
      ErrorDialog(parameter).show();
      return TaskStatus.Restart;
    } catch (e) {
      return TaskStatus.GiveUp;
    }
  }
}
