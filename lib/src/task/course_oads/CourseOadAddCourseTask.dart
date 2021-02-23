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
      String value = await CourseOadConnector.queryCourse(id);
      super.onEnd();
      if (value != null) {
        result = value;
        ErrorDialogParameter parameter = ErrorDialogParameter(
          desc: result,
          btnCancelOnPress: null,
          btnOkText: R.current.sure,
          dialogType: DialogType.SUCCES,
          offCancelBtn: true,
        );
        await super.onErrorParameter(parameter);
        return TaskStatus.Success;
      } else {
        ErrorDialogParameter parameter = ErrorDialogParameter(
          desc: R.current.error,
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
