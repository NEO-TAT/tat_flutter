
import 'package:dio/dio.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:flutter_app/src/task/ntpu/ntpu_task.dart';

import '../../../connector/NTPU/course_connector.dart';
import '../../../r.dart';
import '../../task.dart';

class CourseSystemTask<T> extends NTPU_Task<T> {
  CourseSystemTask(String name) : super("CourseSystemTask $name");

  @override
  Future<TaskStatus> execute() async {
    final status = await super.execute();
    if(status == TaskStatus.success) {
      super.onStart(R.current.loginCourse);
      // final value = await CourseConnector.login();

      super.onEnd();
      return TaskStatus.success;
    }
    return status;
  }

  // @override
  // Future<TaskStatus> onError(String message) {
  //   return super.onError(message);
  // }
}
