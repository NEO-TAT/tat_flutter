import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/ISchoolPlusConnector.dart';
import 'package:flutter_app/src/model/ischoolplus/CourseFileJson.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';
import 'package:get/get.dart';

import '../Task.dart';
import 'IPlusSystemTask.dart';

class IPlusCourseFileTask extends IPlusSystemTask<List<CourseFileJson>> {
  final String id;

  IPlusCourseFileTask(this.id) : super("IPlusCourseFileTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.Success) {
      super.onStart(R.current.getISchoolPlusCourseFile);
      ReturnWithStatus<List<CourseFileJson>> value = await ISchoolPlusConnector.getCourseFile(id);
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
            btnOkText: R.current.sure,
            offCancelBtn: true,
          );
          return await super.onErrorParameter(parameter);
      }
    }
    return status;
  }
}
