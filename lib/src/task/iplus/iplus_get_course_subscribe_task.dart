// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter_app/src/connector/ischool_plus_connector.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/task/iplus/iplus_system_task.dart';
import 'package:flutter_app/src/task/task.dart';

class IPlusGetCourseSubscribeTask extends IPlusSystemTask<Map<String, dynamic>> {
  final int id;

  IPlusGetCourseSubscribeTask(this.id) : super("IPlusGetCourseSubscribeTask");

  @override
  Future<TaskStatus> execute() async {
    final status = await super.execute();
    if (status == TaskStatus.success) {
      super.onStart(R.current.searchSubscribe);
      final courseBid = await ISchoolPlusConnector.getBid();
      final openNotifications = await ISchoolPlusConnector.getCourseSubscribe(courseBid);
      super.onEnd();
      result = {
        "courseBid": courseBid,
        "openNotifications": openNotifications,
      };
      return TaskStatus.success;
    }
    return status;
  }
}
