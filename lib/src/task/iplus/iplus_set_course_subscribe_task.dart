import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/connector/ischool_plus_connector.dart';

import '../task.dart';
import 'iplus_system_task.dart';

class IPlusSetCourseSubscribeTask extends IPlusSystemTask<bool> {
  final String bid;
  final bool open;

  IPlusSetCourseSubscribeTask(this.bid, this.open) : super("IPlusSetCourseSubscribeTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.success) {
      super.onStart((open) ? R.current.closeSubscribe : R.current.openSubscribe);
      bool value = await ISchoolPlusConnector.courseSubscribe(bid, open);
      super.onEnd();
      if (value) {
        result = value;
        return TaskStatus.success;
      } else {
        return TaskStatus.giveUp;
      }
    }
    return status;
  }
}