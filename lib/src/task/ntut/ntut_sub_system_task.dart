// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter_app/src/connector/ntut_connector.dart';
import 'package:flutter_app/src/model/ntut/ap_tree_json.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/task/ntut/ntut_task.dart';

import '../task.dart';

class NTUTSubSystemTask extends NTUTTask<APTreeJson> {
  final String arg;

  NTUTSubSystemTask(this.arg) : super("NTUTSubSystemTask");

  @override
  Future<TaskStatus> execute() async {
    final status = await super.execute();
    if (status == TaskStatus.success) {
      final value = await NTUTConnector.getTree(arg) as APTreeJson?;
      if (value != null) {
        result = value;
        return TaskStatus.success;
      } else {
        return super.onError(R.current.error);
      }
    }
    return status;
  }
}
