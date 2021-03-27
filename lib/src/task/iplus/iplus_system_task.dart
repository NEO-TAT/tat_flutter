import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/ischool_plus_connector.dart';
import 'package:flutter_app/src/store/model.dart';
import 'package:flutter_app/src/task/ntut/ntut_task.dart';
import 'package:flutter_app/src/task/task.dart';
import 'package:flutter_app/ui/other/error_dialog.dart';

class IPlusSystemTask<T> extends NTUTTask<T> {
  IPlusSystemTask(String name) : super(name);
  static bool isLogin = false;

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (isLogin) return TaskStatus.Success;
    name = "IPlusSystemTask " + name;
    if (status == TaskStatus.Success) {
      isLogin = true;
      super.onStart(R.current.loginISchoolPlus);
      String studentId = Model.instance.getAccount();
      ISchoolPlusConnectorStatus value =
          await ISchoolPlusConnector.login(studentId);
      super.onEnd();
      if (value != ISchoolPlusConnectorStatus.LoginSuccess) {
        return await onError(R.current.loginISchoolPlusError);
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
  Future<TaskStatus> onErrorParameter(ErrorDialogParameter parameter) {
    isLogin = false;
    return super.onErrorParameter(parameter);
  }
}
