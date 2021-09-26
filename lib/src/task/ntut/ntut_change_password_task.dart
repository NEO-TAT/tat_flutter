import 'package:tat/src/R.dart';
import 'package:tat/src/connector/ntut_connector.dart';
import 'package:tat/src/store/model.dart';

import '../task.dart';
import 'ntut_task.dart';

class NTUTChangePasswordTask extends NTUTTask {
  final String password;

  NTUTChangePasswordTask(this.password) : super("NTUTChangePasswordTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.Success) {
      super.onStart(R.current.changingPassword);
      String value = await NTUTConnector.changePassword(password);
      super.onEnd();
      if (value.isEmpty) {
        Model.instance.setPassword(password);
        await Model.instance.saveUserData();
        return TaskStatus.Success;
      } else {
        return await super.onError(value ?? R.current.changingPasswordError);
      }
    }
    return status;
  }
}
