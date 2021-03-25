import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/NTUTConnector.dart';
import 'package:get/get.dart';

import '../Task.dart';
import 'NTUTTask.dart';

class NTUTOrgtreeSearchTask extends NTUTTask<OrgtreeSearchResult> {
  final String keyword;

  NTUTOrgtreeSearchTask(this.keyword) : super("NTUTOrgtreeSearchTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.Success) {
      super.onStart(R.current.search);
      List<OrgtreeSearchResult> value =
          await NTUTConnector.orgtreeSearch(keyword);
      super.onEnd();
      if (value != null && value.length != 0) {
        result = await Get.dialog(
          AlertDialog(
            title: Text("請選澤"),
            content: SingleChildScrollView(
              child: Column(
                children: value
                    .map(
                      (e) => InkWell(
                        child: Container(
                          padding: EdgeInsets.only(top: 5, bottom: 5),
                          child: Text(e.msg),
                        ),
                        onTap: () {
                          Get.back(result: e);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        );
        if (result != null) {
          return TaskStatus.Success;
        } else {
          return TaskStatus.GiveUp;
        }
      }
    }
    return TaskStatus.GiveUp;
  }
}
