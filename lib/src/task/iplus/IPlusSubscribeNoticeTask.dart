import 'package:flutter_app/src/connector/ISchoolPlusConnector.dart';
import 'package:flutter_app/src/task/iplus/IPlusSystemTask.dart';
import 'package:flutter_app/src/task/ntut/NTUTTask.dart';

import '../Task.dart';

class IPlusSubscribeNoticeTask extends IPlusSystemTask<List<String>> {
  IPlusSubscribeNoticeTask() : super("IPlusSubscribeNoticeTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.Success) {
      List<String> value = await ISchoolPlusConnector.getSubscribeNotice();
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
