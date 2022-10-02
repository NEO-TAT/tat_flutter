// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:connectivity/connectivity.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/ui/other/error_dialog.dart';
import 'package:flutter_app/ui/other/my_progress_dialog.dart';

import 'task.dart';

class DialogTask<T> extends Task<T> {
  DialogTask(String name) : super(name);
  bool openLoadingDialog = true;

  @override
  Future<TaskStatus> execute() async {
    return TaskStatus.success;
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
    final parameter = ErrorDialogParameter(
      desc: message,
    );
    return await onErrorParameter(parameter);
  }

  Future<TaskStatus> onErrorParameter(ErrorDialogParameter parameter) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      parameter = ErrorDialogParameter(
        desc: R.current.networkError,
      );
    }
    ErrorDialog(parameter).show();

    // Return GiveUp here instead of Restart to prevent the Un-terminated error stack.
    return TaskStatus.shouldGiveUp;
  }
}
