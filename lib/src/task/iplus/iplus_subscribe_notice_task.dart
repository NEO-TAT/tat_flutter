// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'package:flutter_app/src/connector/ischool_plus_connector.dart';
import 'package:flutter_app/src/task/iplus/iplus_system_task.dart';

import '../task.dart';

class IPlusSubscribeNoticeTask extends IPlusSystemTask<List<String>> {
  IPlusSubscribeNoticeTask() : super("IPlusSubscribeNoticeTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.success) {
      List<String> value = await ISchoolPlusConnector.getSubscribeNotice();
      if (value != null) {
        result = value;
        return TaskStatus.success;
      } else {
        return TaskStatus.giveUp;
      }
    }
    return status;
  }
}