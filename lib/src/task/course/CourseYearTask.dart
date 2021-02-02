import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/CourseConnector.dart';

import '../Task.dart';
import 'CourseSystemTask.dart';

class CourseYearTask extends CourseSystemTask<List<String>> {
  CourseYearTask() : super("CourseYearTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.Success) {
      super.onStart(R.current.searchingYear);
      List<String> value = await CourseConnector.getYearList();
      super.onEnd();
      if (value != null) {
        result = value;
        return TaskStatus.Success;
      } else {
        return TaskStatus.GiveUp;
      }
    }
    return status;
  }
}
