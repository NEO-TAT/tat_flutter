import 'package:tat/src/connector/course_oad_connector.dart';
import 'package:tat/src/task/ntut/ntut_task.dart';
import 'package:tat/ui/other/error_dialog.dart';

import '../../R.dart';
import '../task.dart';

class CourseOadSystemTask<T> extends NTUTTask<T> {
  CourseOadSystemTask(String name) : super(name);
  static bool isLogin = false;

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (isLogin) return TaskStatus.Success;
    name = "CourseOadSystemTask " + name;
    if (status == TaskStatus.Success) {
      isLogin = true;
      super.onStart(R.current.loginCourseOad);
      bool value = await CourseOadConnector.login();
      if (!value) {
        return await onError(R.current.loginCourseOadError);
      }
      super.onEnd();
    }
    return status;
  }

  @override
  Future<TaskStatus> onError(String message) {
    isLogin = false;
    return super.onError(message);
  }

  @override
  Future<TaskStatus> onErrorParameter(ErrorDialogParameter parameter) {
    isLogin = false;
    return super.onErrorParameter(parameter);
  }
}
