// ignore_for_file: import_of_legacy_library_into_null_safe

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
    final status = await super.execute();
    if (status == TaskStatus.success) {
      super.onStart(R.current.getCalendar);
      final value = await NTUTConnector.getCalendar(startTime, endTime);
      super.onEnd();
      if (value != null) {
        result = value;
        return TaskStatus.success;
      } else {
        return super.onError(R.current.getCalendarError);
      }
    }
    return status;
  }
}
