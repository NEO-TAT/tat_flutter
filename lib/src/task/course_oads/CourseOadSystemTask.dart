import 'package:flutter_app/src/connector/CourseOadConnector.dart';
import 'package:flutter_app/src/task/ntut/NTUTTask.dart';
import 'package:flutter_app/ui/other/ErrorDialog.dart';

import '../../R.dart';
import '../Task.dart';

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