import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/ISchoolPlusConnector.dart';
import 'package:flutter_app/src/model/ischoolplus/ISchoolPlusAnnouncementJson.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:get/get.dart';

import '../Task.dart';
import 'IPlusSystemTask.dart';

class IPlusCourseAnnouncementTask extends IPlusSystemTask<List<ISchoolPlusAnnouncementJson>> {
  final String id;

  IPlusCourseAnnouncementTask(this.id) : super("IPlusCourseAnnouncementTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.Success) {
      super.onStart(R.current.getISchoolPlusCourseAnnouncement);
      ReturnWithStatus<List<ISchoolPlusAnnouncementJson>> value = await ISchoolPlusConnector.getCourseAnnouncement(id);
      super.onEnd();
      switch (value.status) {
        case IPlusReturnStatus.Success:
          result = value.result;
          return TaskStatus.Success;
        case IPlusReturnStatus.Fail:
          return await super.onError(R.current.getISchoolPlusCourseAnnouncementError);
        case IPlusReturnStatus.NoPermission:
          ErrorDialogParameter parameter = ErrorDialogParameter(
            title: R.current.warning,
            dialogType: DialogType.INFO,
            desc: R.current.iPlusNoThisClass,
            btnOkOnPress: () {
              Get.back<bool>(result: false);
            },
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
