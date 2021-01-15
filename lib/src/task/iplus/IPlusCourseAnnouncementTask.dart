import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/ISchoolPlusConnector.dart';
import 'package:flutter_app/src/model/ischoolplus/ISchoolPlusAnnouncementJson.dart';

import '../Task.dart';
import 'IPlusSystemTask.dart';

class IPlusCourseAnnouncementTask
    extends IPlusSystemTask<List<ISchoolPlusAnnouncementJson>> {
  final String id;

  IPlusCourseAnnouncementTask(this.id) : super("IPlusCourseAnnouncementTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.Success) {
      super.onStart(R.current.getISchoolPlusCourseAnnouncement);
      List<ISchoolPlusAnnouncementJson> value =
          await ISchoolPlusConnector.getCourseAnnouncement(id);
      super.onEnd();
      if (value != null) {
        result = value;
        return TaskStatus.Success;
      } else {
        return await super
            .onError(R.current.getISchoolPlusCourseAnnouncementError);
      }
    }
    return status;
  }
}
