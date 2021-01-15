import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/ISchoolPlusConnector.dart';
import 'package:flutter_app/src/model/ischoolplus/CourseFileJson.dart';

import '../Task.dart';
import 'IPlusSystemTask.dart';

class IPlusCourseFileTask extends IPlusSystemTask<List<CourseFileJson>> {
  final String id;

  IPlusCourseFileTask(this.id) : super("IPlusCourseFileTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.Success) {
      super.onStart(R.current.getISchoolPlusCourseFile);
      List<CourseFileJson> value = await ISchoolPlusConnector.getCourseFile(id);
      super.onEnd();
      if (value != null) {
        result = value;
        return TaskStatus.Success;
      } else {
        return await super.onError(R.current.getISchoolPlusCourseFileError);
      }
    }
    return status;
  }
}
