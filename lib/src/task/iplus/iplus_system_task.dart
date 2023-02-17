// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter_app/src/connector/ischool_plus_connector.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:flutter_app/src/task/ntut/ntut_task.dart';
import 'package:flutter_app/src/task/task.dart';
import 'package:flutter_app/ui/other/msg_dialog.dart';

class IPlusSystemTask<T> extends NTUTTask<T> {
  IPlusSystemTask(String name) : super("IPlusSystemTask $name");
  static bool isLogin = false;

  @override
  Future<TaskStatus> execute() async {
    final status = await super.execute();
    if (isLogin) return TaskStatus.success;

    if (status == TaskStatus.success) {
      isLogin = true;

      super.onStart(R.current.loginISchoolPlus);
      final studentId = LocalStorage.instance.getAccount();
      final value = await ISchoolPlusConnector.login(studentId);
      super.onEnd();

      if (value != ISchoolPlusConnectorStatus.loginSuccess) {
        return onError(R.current.loginISchoolPlusError);
      }
    }
    return status;
  }

  @override
  Future<TaskStatus> onError(String message) {
    isLogin = false;
    return super.onError(message);
  }

  @override
  Future<TaskStatus> onErrorParameter(MsgDialogParameter parameter) {
    isLogin = false;
    return super.onErrorParameter(parameter);
  }
}
