import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/ISchoolPlusConnector.dart';

import '../Task.dart';
import 'IPlusSystemTask.dart';

class IPlusSetCourseSubscribeTask extends IPlusSystemTask<bool> {
  final bid;
  final open;

  IPlusSetCourseSubscribeTask(this.bid, this.open) : super("IPlusSetCourseSubscribeTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.Success) {
      super.onStart((open) ? R.current.closeSubscribe : R.current.openSubscribe);
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
