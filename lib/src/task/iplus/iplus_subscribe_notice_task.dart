// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter_app/src/connector/ischool_plus_connector.dart';
import 'package:flutter_app/src/task/iplus/iplus_system_task.dart';

import '../task.dart';

class IPlusSubscribeNoticeTask extends IPlusSystemTask<List<String>> {
  IPlusSubscribeNoticeTask() : super("IPlusSubscribeNoticeTask");

  @override
  Future<TaskStatus> execute() async {
    final status = await super.execute();
    if (status == TaskStatus.success) {
      final value = await ISchoolPlusConnector.getSubscribeNotice() as List<String>?;
      if (value != null) {
        result = value;
        return TaskStatus.success;
      } else {
        return TaskStatus.shouldGiveUp;
      }
    }
    return status;
  }
}
