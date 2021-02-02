import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/NTUTConnector.dart';
import 'package:flutter_app/src/model/ntut/APTreeJson.dart';
import 'package:flutter_app/src/task/ntut/NTUTTask.dart';

import '../Task.dart';

class NTUTSubSystemTask extends NTUTTask<APTreeJson> {
  final String arg;

  NTUTSubSystemTask(this.arg) : super("NTUTSubSystemTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.Success) {
      APTreeJson value = await NTUTConnector.getTree(arg);
      if (value != null) {
        result = value;
        return TaskStatus.Success;
      } else {
        return await super.onError(R.current.error);
      }
    }
    return status;
  }
}
