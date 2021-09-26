import 'package:tat/src/R.dart';
import 'package:tat/src/connector/ischool_plus_connector.dart';
import 'package:tat/src/model/ischool_plus/ischool_plus_announcement_json.dart';

import '../task.dart';
import 'iplus_system_task.dart';

class IPlusCourseAnnouncementDetailTask extends IPlusSystemTask<Map> {
  final ISchoolPlusAnnouncementJson data;

  IPlusCourseAnnouncementDetailTask(this.data)
      : super("lPlusCourseAnnouncementDetailTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.Success) {
      super.onStart(R.current.getISchoolPlusCourseAnnouncementDetail);
      Map value = await ISchoolPlusConnector.getCourseAnnouncementDetail(data);
      super.onEnd();
      if (value != null) {
        result = value;
        return TaskStatus.Success;
      } else {
        return await super
            .onError(R.current.getISchoolPlusCourseAnnouncementDetailError);
      }
    }
    return status;
  }
}
