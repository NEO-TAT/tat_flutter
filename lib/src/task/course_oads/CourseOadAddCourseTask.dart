import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/CourseOadConnector.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';

import '../Task.dart';
import 'CourseOadSystemTask.dart';

class CourseOadAddCourseTask extends CourseOadSystemTask<String> {
  final id;

  CourseOadAddCourseTask(this.id) : super("CourseOadAddCourseTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.Success) {
      super.onStart(R.current.addCourse);
      AddCourseStatus value = await CourseOadConnector.queryCourse(id);
      super.onEnd();
      if (value != null && value.success) {
        result = value.msg;
        ErrorDialogParameter parameter = ErrorDialogParameter(
          title: R.current.success,
          desc: result,
          btnCancelOnPress: null,
          btnOkText: R.current.sure,
          dialogType: DialogType.SUCCES,
          offCancelBtn: true,
        );
        await super.onErrorParameter(parameter);
        return TaskStatus.Success;
      } else {
        String msg =
            (value == null || value.msg == null) ? R.current.error : value.msg;
        ErrorDialogParameter parameter = ErrorDialogParameter(
          desc: msg,
          btnOkText: R.current.sure,
          offCancelBtn: true,
        );
        await super.onErrorParameter(parameter);
        return TaskStatus.GiveUp;
      }
    }
    return status;
  }
}
