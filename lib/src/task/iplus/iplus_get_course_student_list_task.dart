// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_app/src/connector/ischool_plus_connector.dart';
import 'package:flutter_app/src/model/course/course_student.dart';
import 'package:flutter_app/src/model/ischoolplus/ischool_plus_announcement_json.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/ui/other/msg_dialog.dart';

import '../task.dart';
import 'iplus_system_task.dart';

class IPlusGetStudentListTask extends IPlusSystemTask<List<CourseStudent>> {
  String courseId;

  IPlusGetStudentListTask({required this.courseId}) : super("IPlusCourseAnnouncementTask");

  @override
  Future<TaskStatus> execute() async {
    final status = await super.execute();
    if (status == TaskStatus.success) {
      super.onStart(R.current.getISchoolPlusCourseAnnouncement);
      final value = await ISchoolPlusConnector.getCourseStudent(courseId);
      super.onEnd();
      switch (value.status) {
        case IPlusReturnStatus.success:
          result = value.result;
          return TaskStatus.success;
        case IPlusReturnStatus.fail:
          return super.onError(R.current.getISchoolPlusCourseAnnouncementError);
        case IPlusReturnStatus.noPermission:
          final parameter = MsgDialogParameter(
            title: R.current.warning,
            dialogType: DialogType.info,
            desc: R.current.iPlusNoThisClass,
            okButtonText: R.current.sure,
            removeCancelButton: true,
          );
          return super.onErrorParameter(parameter);
      }
    }
    return status;
  }
}
