import 'package:tat/src/connector/ischool_plus_connector.dart';
import 'package:tat/src/task/iplus/iplus_system_task.dart';

import '../task.dart';

class IPlusSubscribeNoticeTask extends IPlusSystemTask<List<String>> {
  IPlusSubscribeNoticeTask() : super("IPlusSubscribeNoticeTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.Success) {
      List<String> value = await ISchoolPlusConnector.getSubscribeNotice();
      if (value != null) {
        result = value;
        return TaskStatus.Success;
      } else {
        return TaskStatus.GiveUp;
      }
    }
    return status;
  }
}
