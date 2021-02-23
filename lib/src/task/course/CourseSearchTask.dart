import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/CourseConnector.dart';
import 'package:flutter_app/src/model/course/CourseClassJson.dart';
import 'package:flutter_app/src/model/course/CourseMainExtraJson.dart';
import 'package:flutter_app/ui/other/MyToast.dart';

import '../DialogTask.dart';
import '../Task.dart';

class CourseSearchTask extends DialogTask<List<CourseMainInfoJson>> {
  String name;
  SemesterJson semester;

  CourseSearchTask(this.semester, this.name) : super("CourseSearchTask");

  @override
  Future<TaskStatus> execute() async {
    super.onStart(R.current.search + "...");
    result = await CourseConnector.searchCourse(semester, name);
    super.onEnd();
    if (result == null) {
      MyToast.show(R.current.unknownError);
      return TaskStatus.GiveUp;
    } else if (result.length == 0) {
      MyToast.show(R.current.notFindAnything);
      return TaskStatus.GiveUp;
    }
    return TaskStatus.Success;
  }
}
