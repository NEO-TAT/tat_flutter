import 'package:tat/src/R.dart';
import 'package:tat/src/connector/ischool_plus_connector.dart';

import '../task.dart';
import 'iplus_system_task.dart';

class IPlusSetCourseSubscribeTask extends IPlusSystemTask<bool> {
  final bid;
  final open;

  IPlusSetCourseSubscribeTask(this.bid, this.open)
      : super("IPlusSetCourseSubscribeTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.Success) {
      super
          .onStart((open) ? R.current.closeSubscribe : R.current.openSubscribe);
      bool value = await ISchoolPlusConnector.courseSubscribe(bid, open);
      super.onEnd();
      if (value) {
        result = value;
        return TaskStatus.Success;
      } else {
        return TaskStatus.GiveUp;
      }
    }
    return status;
  }
}
