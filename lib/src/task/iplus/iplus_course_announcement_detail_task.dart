// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'package:flutter_app/src/connector/ischool_plus_connector.dart';
import 'package:flutter_app/src/model/ischoolplus/ischool_plus_announcement_json.dart';
import 'package:flutter_app/src/r.dart';

import '../task.dart';
import 'iplus_system_task.dart';

class IPlusCourseAnnouncementDetailTask extends IPlusSystemTask<Map> {
  final ISchoolPlusAnnouncementJson data;

  IPlusCourseAnnouncementDetailTask(this.data) : super("lPlusCourseAnnouncementDetailTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.success) {
      super.onStart(R.current.getISchoolPlusCourseAnnouncementDetail);
      Map value = await ISchoolPlusConnector.getCourseAnnouncementDetail(data);
      super.onEnd();
      if (value != null) {
        result = value;
        return TaskStatus.success;
      } else {
        return await super.onError(R.current.getISchoolPlusCourseAnnouncementDetailError);
      }
    }
    return status;
  }
}
