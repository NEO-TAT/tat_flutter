// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter_app/src/connector/ischool_plus_connector.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/task/iplus/iplus_system_task.dart';
import 'package:flutter_app/src/task/task.dart';

class IPlusSetCourseSubscribeTask extends IPlusSystemTask<bool> {
  final String bid;
  final bool open;

  IPlusSetCourseSubscribeTask(this.bid, this.open) : super("IPlusSetCourseSubscribeTask");

  @override
  Future<TaskStatus> execute() async {
    final status = await super.execute();
    if (status == TaskStatus.success) {
      super.onStart((open) ? R.current.closeSubscribe : R.current.openSubscribe);
      final value = await ISchoolPlusConnector.courseSubscribe(bid, open);
      super.onEnd();
      if (value) {
        result = value;
        return TaskStatus.success;
      } else {
        return TaskStatus.shouldGiveUp;
      }
    }
    return status;
  }
}
