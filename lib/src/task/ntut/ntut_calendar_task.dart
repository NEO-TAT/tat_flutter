import 'package:tat/src/R.dart';
import 'package:tat/src/connector/ntut_connector.dart';
import 'package:tat/src/model/ntut/ntut_calendar_json.dart';

import '../task.dart';
import 'ntut_task.dart';

class NTUTCalendarTask extends NTUTTask<List<NTUTCalendarJson>> {
  final DateTime startTime;
  final DateTime endTime;

  NTUTCalendarTask(this.startTime, this.endTime) : super("NTUTCalendarTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.Success) {
      List<NTUTCalendarJson> value;
      super.onStart(R.current.getCalendar);
      value = await NTUTConnector.getCalendar(startTime, endTime);
      super.onEnd();
      if (value != null) {
        result = value;
        return TaskStatus.Success;
      } else {
        return await super.onError(R.current.getCalendarError);
      }
    }
    return status;
  }
}
