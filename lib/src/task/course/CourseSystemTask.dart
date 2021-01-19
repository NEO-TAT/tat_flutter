import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/CourseConnector.dart';
import 'package:flutter_app/src/task/Task.dart';
import 'package:flutter_app/src/task/ntut/NTUTTask.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';

class CourseSystemTask<T> extends NTUTTask<T> {
  CourseSystemTask(String name) : super(name);
  static bool _isLogin = false;

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (_isLogin) return TaskStatus.Success;
    name = "CourseSystemTask " + name;
    if (status == TaskStatus.Success) {
      _isLogin = true;
      super.onStart(R.current.loginCourse);
      CourseConnectorStatus value = await CourseConnector.login();
      super.onEnd();
      if (value != CourseConnectorStatus.LoginSuccess) {
        return await onError(R.current.loginCourseError);
      }
    }
    return status;
  }

  @override
  Future<TaskStatus> onError(String message) {
    _isLogin = false;
    return super.onError(message);
  }

  @override
  Future<TaskStatus> onErrorParameter(ErrorDialogParameter parameter) {
    _isLogin = false;
    return super.onErrorParameter(parameter);
  }
}
