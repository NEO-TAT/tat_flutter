import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/CourseConnector.dart';
import 'package:flutter_app/src/model/course/CourseClassJson.dart';

import '../Task.dart';
import 'CourseSystemTask.dart';

class CourseSemesterTask extends CourseSystemTask<List<SemesterJson>> {
  final id;

  CourseSemesterTask(this.id) : super("CourseSemesterTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.Success) {
      List<SemesterJson> value;
      if (id.length == 5) {
        value = List();
        DateTime dateTime = DateTime.now();
        int year = dateTime.year - 1911;
        int semester = (dateTime.month <= 8 && dateTime.month >= 1) ? 2 : 1;
        value.add(
            SemesterJson(semester: semester.toString(), year: year.toString()));
      } else {
        super.onStart(R.current.getCourseSemester);
        value = await CourseConnector.getCourseSemester(id);
        super.onEnd();
      }
      if (value != null) {
        result = value;
        return TaskStatus.Success;
      } else {
        return await super.onError(R.current.getCourseError);
      }
    }
    return status;
  }
}
