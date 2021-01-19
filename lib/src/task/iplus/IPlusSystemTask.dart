import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/ISchoolPlusConnector.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/task/Task.dart';
import 'package:flutter_app/src/task/ntut/NTUTTask.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';

class IPlusSystemTask<T> extends NTUTTask<T> {
  IPlusSystemTask(String name) : super(name);
  static bool _isLogin = false;

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (_isLogin) return TaskStatus.Success;
    name = "IPlusSystemTask " + name;
    if (status == TaskStatus.Success) {
      _isLogin = true;
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
    _isLogin = false;
    return super.onError(message);
  }

  @override
  Future<TaskStatus> onErrorParameter(ErrorDialogParameter parameter) {
    _isLogin = false;
    return super.onErrorParameter(parameter);
  }
}
