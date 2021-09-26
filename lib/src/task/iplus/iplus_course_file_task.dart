import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:tat/src/R.dart';
import 'package:tat/src/connector/ischool_plus_connector.dart';
import 'package:tat/src/model/ischool_plus/course_file_json.dart';
import 'package:tat/ui/other/error_dialog.dart';
import 'package:get/get.dart';

import '../task.dart';
import 'iplus_system_task.dart';

class IPlusCourseFileTask extends IPlusSystemTask<List<CourseFileJson>> {
  final String id;

  IPlusCourseFileTask(this.id) : super("IPlusCourseFileTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.Success) {
      super.onStart(R.current.getISchoolPlusCourseFile);
      ReturnWithStatus<List<CourseFileJson>> value =
          await ISchoolPlusConnector.getCourseFile(id);
      super.onEnd();
      switch (value.status) {
        case IPlusReturnStatus.Success:
          result = value.result;
          return TaskStatus.Success;
        case IPlusReturnStatus.Fail:
          return await super.onError(R.current.getISchoolPlusCourseFileError);
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
