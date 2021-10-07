import 'package:tat/src/R.dart';
import 'package:tat/src/connector/course_connector.dart';
import 'package:tat/src/task/ntut/ntut_task.dart';
import 'package:tat/src/task/task.dart';
import 'package:tat/ui/other/error_dialog.dart';

class CourseSystemTask<T> extends NTUTTask<T> {
  CourseSystemTask(String name) : super(name);
  static bool isLogin = false;

  @override
  Future<TaskStatus> execute() async {
    final status = await super.execute();
    if (isLogin) return TaskStatus.Success;
    name = "CourseSystemTask " + name;

    if (status == TaskStatus.Success) {
      isLogin = true;
      super.onStart(R.current.loginCourse);
      final value = await CourseConnector.login();
      super.onEnd();

      if (value != CourseConnectorStatus.LoginSuccess) {
        return await onError(R.current.loginCourseError);
      }
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
