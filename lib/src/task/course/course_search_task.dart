import 'package:tat/src/R.dart';
import 'package:tat/src/connector/course_connector.dart';
import 'package:tat/src/connector/course_oad_connector.dart';
import 'package:tat/src/model/course/course_class_json.dart';
import 'package:tat/src/model/course/course_main_extra_json.dart';
import 'package:tat/ui/other/my_toast.dart';

import '../dialog_task.dart';
import '../task.dart';

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
        if (r != null && !r.error) {
          result = [r.info];
        } else {
          result = null;
        }
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
