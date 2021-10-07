import 'package:tat/src/R.dart';
import 'package:tat/src/connector/ischool_plus_connector.dart';

import '../task.dart';
import 'iplus_system_task.dart';

class IPlusGetCourseSubscribeTask
    extends IPlusSystemTask<Map<String, dynamic>> {
  IPlusGetCourseSubscribeTask() : super("IPlusGetCourseSubscribeTask");

  @override
  Future<TaskStatus> execute() async {
    final status = await super.execute();

    if (status == TaskStatus.Success) {
      super.onStart(R.current.searchSubscribe);
      final courseBid = await ISchoolPlusConnector.getBid();
      final openNotifications =
          await ISchoolPlusConnector.getCourseSubscribe(courseBid);
      super.onEnd();
      result = {"courseBid": courseBid, "openNotifications": openNotifications};
      return TaskStatus.Success;
    }
    return status;
  }
}
