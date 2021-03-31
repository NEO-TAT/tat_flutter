import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/ntut_connector.dart';

import '../task.dart';
import 'ntut_task.dart';

class NTUTGetPasswordExpiredTask extends NTUTTask {
  NTUTGetPasswordExpiredTask() : super("NTUTGetPasswordExpiredTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.Success) {
      super.onStart(R.current.changingPassword);
      DateTime expired = await NTUTConnector.getPasswordExpired();
      super.onEnd();
      if (expired != null) {
        result = (180 - DateTime.now().difference(expired).inDays).toInt();
        return TaskStatus.Success;
      } else {
        return TaskStatus.GiveUp;
      }
    }
    return status;
  }
}
