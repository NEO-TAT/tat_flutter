import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/NTUTConnector.dart';
import 'package:flutter_app/src/store/Model.dart';

import '../Task.dart';
import 'NTUTTask.dart';

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
