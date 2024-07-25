// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/ui/other/msg_dialog.dart';
import 'package:flutter_app/ui/other/my_progress_dialog.dart';
import 'package:get/get.dart';

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

  Future<void> onErrorButCached() async {
    final parameter = MsgDialogParameter(
      // TODO: generate string for this
      desc: "failed but cached",
      dialogType: DialogType.warning,
    );
    MsgDialog(parameter).show();
    // eventually it should return as success as it use result from the previous success fetch
  }

  Future<TaskStatus> onError(String message) async {
    final parameter = MsgDialogParameter(
      desc: message,
      dialogType: DialogType.warning,
    );
    return await onErrorParameter(parameter);
  }

  Future<TaskStatus> onErrorParameter(MsgDialogParameter parameter) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      parameter = MsgDialogParameter(
        desc: R.current.networkError,
      );
    }
    MsgDialog(parameter).show();

    // Return GiveUp here instead of Restart to prevent the Un-terminated error stack.
    return TaskStatus.shouldGiveUp;
  }

  /// Helps to show an [MsgDialog] before the current [Context] is popped.
  /// This is useful when we have to show some dialogs after the route is changed.
  Future<TaskStatus> msgDialogShownResult({
    required MsgDialogParameter msgDialogParam,
    required TaskStatus result,
  }) async {
    await Get.asap(() => MsgDialog(msgDialogParam).show());
    return result;
  }
}
