// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'package:flutter_app/src/connector/ntut_connector.dart';
import 'package:flutter_app/src/model/ntut/ntut_calendar_json.dart';
import 'package:flutter_app/src/r.dart';

import '../task.dart';
import 'ntut_task.dart';

class NTUTCalendarTask extends NTUTTask<List<NTUTCalendarJson>> {
  final DateTime startTime;
  final DateTime endTime;

  NTUTCalendarTask(this.startTime, this.endTime) : super("NTUTCalendarTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.success) {
      List<NTUTCalendarJson> value;
      super.onStart(R.current.getCalendar);
      value = await NTUTConnector.getCalendar(startTime, endTime);
      super.onEnd();
      if (value != null) {
        result = value;
        return TaskStatus.success;
      } else {
        return await super.onError(R.current.getCalendarError);
      }
    }
    return status;
  }
}
