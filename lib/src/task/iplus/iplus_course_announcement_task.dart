// ignore_for_file: import_of_legacy_library_into_null_safe

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
    final status = await super.execute();
    if (status == TaskStatus.success) {
      super.onStart(R.current.getISchoolPlusCourseAnnouncement);
      final value = await ISchoolPlusConnector.getCourseAnnouncement(id);
      super.onEnd();
      switch (value.status) {
        case IPlusReturnStatus.success:
          result = value.result;
          return TaskStatus.success;
        case IPlusReturnStatus.fail:
          return super.onError(R.current.getISchoolPlusCourseAnnouncementError);
        case IPlusReturnStatus.noPermission:
          final parameter = ErrorDialogParameter(
            title: R.current.warning,
            dialogType: DialogType.info,
            desc: R.current.iPlusNoThisClass,
            btnOkText: R.current.sure,
            offCancelBtn: true,
          );
          return super.onErrorParameter(parameter);
      }
    }
    return status;
  }
}
