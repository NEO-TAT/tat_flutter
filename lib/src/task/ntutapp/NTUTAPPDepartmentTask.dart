import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/NTUTAppConnector.dart';

import '../Task.dart';
import 'NTUTAppTask.dart';

class NTUTAPPDepartmentTask extends NTUTAppTask<Map<String, String>> {
  NTUTAPPDepartmentTask() : super("NTUTAPPDepartmentTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.Success) {
      Map<String, String> value;
      super.onStart(R.current.searching);
      value = await NTUTAppConnector.getDepartment();
      super.onEnd();
      if (value != null) {
        result = value;
        return TaskStatus.Success;
      } else {
        return await super.onError(R.current.getCalendarError);
      }
    }
    return status;
  }
}
