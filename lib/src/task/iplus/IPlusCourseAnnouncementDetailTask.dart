import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/ISchoolPlusConnector.dart';
import 'package:flutter_app/src/model/ischoolplus/ISchoolPlusAnnouncementJson.dart';

import '../Task.dart';
import 'IPlusSystemTask.dart';

class IPlusCourseAnnouncementDetailTask extends IPlusSystemTask<Map> {
  final ISchoolPlusAnnouncementJson data;

  IPlusCourseAnnouncementDetailTask(this.data) : super("lPlusCourseAnnouncementDetailTask");

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
        return await super.onError(R.current.getISchoolPlusCourseAnnouncementDetailError);
      }
    }
    return status;
  }
}
