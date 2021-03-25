import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/CourseConnector.dart';
import 'package:flutter_app/src/connector/CourseOadConnector.dart';
import 'package:flutter_app/src/model/course/CourseClassJson.dart';
import 'package:flutter_app/src/model/course/CourseMainExtraJson.dart';
import 'package:flutter_app/ui/other/MyToast.dart';

import '../DialogTask.dart';
import '../Task.dart';

class CourseSearchTask extends DialogTask<List<CourseMainInfoJson>> {
  String searchName;
  SemesterJson semester;

  CourseSearchTask(this.semester, this.searchName) : super("CourseSearchTask");

  @override
  Future<TaskStatus> execute() async {
    super.onStart(R.current.search + "...");
    result = await CourseConnector.searchCourse(semester, searchName, true);
    if (result == null || result.length == 0) {
      result = await CourseConnector.searchCourse(semester, searchName, false);
    }
    if ((result == null || result.length == 0) && searchName.length == 6) {
      try {
        await CourseOadConnector.login();
        QueryCourseResult r = await CourseOadConnector.queryCourse(searchName);
        result = [r.info];
      } catch (e) {
        result = null;
      }
    }
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
