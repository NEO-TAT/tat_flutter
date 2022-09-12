// ignore_for_file: import_of_legacy_library_into_null_safe

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
    final status = await super.execute();
    if (status == TaskStatus.success) {
      super.onStart(R.current.getISchoolPlusCourseAnnouncementDetail);
      final value = await ISchoolPlusConnector.getCourseAnnouncementDetail(data) as Map<dynamic, dynamic>?;
      super.onEnd();
      if (value != null) {
        result = value;
        return TaskStatus.success;
      } else {
        return super.onError(R.current.getISchoolPlusCourseAnnouncementDetailError);
      }
    }
    return status;
  }
}
