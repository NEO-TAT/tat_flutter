import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/CourseConnector.dart';
import 'package:flutter_app/src/model/course/CourseMainExtraJson.dart';

import '../Task.dart';
import 'CourseSystemTask.dart';

class CourseExtraInfoTask extends CourseSystemTask<CourseExtraInfoJson> {
  final id;

  CourseExtraInfoTask(this.id) : super("CourseExtraInfoTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.Success) {
      super.onStart(R.current.getCourseDetail);
      CourseExtraInfoJson value = await CourseConnector.getCourseExtraInfo(id);
      super.onEnd();
      if (value != null) {
        result = value;
        return TaskStatus.Success;
      } else {
        return await super.onError(R.current.getCourseDetailError);
      }
    }
    return status;
  }
}
