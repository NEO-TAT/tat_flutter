import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_app/src/connector/ischool_plus_connector.dart';
import 'package:flutter_app/src/model/ischoolplus/course_file_json.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/ui/other/error_dialog.dart';

import '../task.dart';
import 'iplus_system_task.dart';

class IPlusCourseFileTask extends IPlusSystemTask<List<CourseFileJson>> {
  final String id;

  IPlusCourseFileTask(this.id) : super("IPlusCourseFileTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.success) {
      super.onStart(R.current.getISchoolPlusCourseFile);
      ReturnWithStatus<List<CourseFileJson>> value = await ISchoolPlusConnector.getCourseFile(id);
      super.onEnd();
      switch (value.status) {
        case IPlusReturnStatus.success:
          result = value.result;
          return TaskStatus.success;
        case IPlusReturnStatus.fail:
          return await super.onError(R.current.getISchoolPlusCourseFileError);
        case IPlusReturnStatus.noPermission:
          ErrorDialogParameter parameter = ErrorDialogParameter(
            title: R.current.warning,
            dialogType: DialogType.INFO,
            desc: R.current.iPlusNoThisClass,
            btnOkText: R.current.sure,
            offCancelBtn: true,
          );
          return await super.onErrorParameter(parameter);
      }
    }
    return status;
  }
}
