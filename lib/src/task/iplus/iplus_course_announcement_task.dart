// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_app/src/connector/ischool_plus_connector.dart';
import 'package:flutter_app/src/model/ischoolplus/ischool_plus_announcement_json.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/ui/other/error_dialog.dart';

import '../task.dart';
import 'iplus_system_task.dart';

class IPlusCourseAnnouncementTask extends IPlusSystemTask<List<ISchoolPlusAnnouncementJson>> {
  final String id;

  IPlusCourseAnnouncementTask(this.id) : super("IPlusCourseAnnouncementTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.success) {
      super.onStart(R.current.getISchoolPlusCourseAnnouncement);
      ReturnWithStatus<List<ISchoolPlusAnnouncementJson>> value = await ISchoolPlusConnector.getCourseAnnouncement(id);
      super.onEnd();
      switch (value.status) {
        case IPlusReturnStatus.success:
          result = value.result;
          return TaskStatus.success;
        case IPlusReturnStatus.fail:
          return await super.onError(R.current.getISchoolPlusCourseAnnouncementError);
        case IPlusReturnStatus.noPermission:
          ErrorDialogParameter parameter = ErrorDialogParameter(
            title: R.current.warning,
            dialogType: DialogType.INFO,
            desc: R.current.iPlusNoThisClass,
            btnOkText: R.current.sure,
            offCancelBtn: true,
          );
          return await super.onErrorParameter(parameter);
          break;
      }
    }
    return status;
  }
}