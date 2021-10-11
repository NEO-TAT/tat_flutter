import 'package:connectivity/connectivity.dart';
import 'package:tat/src/R.dart';
import 'package:tat/ui/other/error_dialog.dart';
import 'package:tat/ui/other/my_progress_dialog.dart';

import 'task.dart';

class DialogTask<T> extends Task<T> {
  DialogTask(String name) : super(name);
  final bool openLoadingDialog = true;

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
    final parameter = ErrorDialogParameter(
      desc: message,
    );
    return await onErrorParameter(parameter);
  }

  Future<TaskStatus> onErrorParameter(ErrorDialogParameter parameter) async {
    try {
      final connectivityResult = await (new Connectivity().checkConnectivity());

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
