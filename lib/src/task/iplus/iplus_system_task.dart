import 'package:tat/src/R.dart';
import 'package:tat/src/connector/ischool_plus_connector.dart';
import 'package:tat/src/store/model.dart';
import 'package:tat/src/task/ntut/ntut_task.dart';
import 'package:tat/src/task/task.dart';
import 'package:tat/ui/other/error_dialog.dart';

class IPlusSystemTask<T> extends NTUTTask<T> {
  IPlusSystemTask(String name) : super(name);
  static bool isLogin = false;

  @override
  Future<TaskStatus> execute() async {
    final status = await super.execute();
    if (isLogin) return TaskStatus.Success;
    name = "IPlusSystemTask " + name;

    if (status == TaskStatus.Success) {
      isLogin = true;
      super.onStart(R.current.loginISchoolPlus);
      final studentId = Model.instance.getAccount();
      final value = await ISchoolPlusConnector.login(studentId);
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
