import 'package:flutter/material.dart';
import 'package:flutter_app/src/connector/course_connector.dart';
import 'package:flutter_app/src/model/course/course_class_json.dart';
import 'package:flutter_app/src/r.dart';
import 'package:get/get.dart';
import 'package:numberpicker/numberpicker.dart';

import '../task.dart';
import 'course_system_task.dart';

class CourseSemesterTask extends CourseSystemTask<List<SemesterJson>> {
  final String id;

  CourseSemesterTask(this.id) : super("CourseSemesterTask");

  @override
  Future<TaskStatus> execute() async {
    TaskStatus status = await super.execute();
    if (status == TaskStatus.success) {
      List<SemesterJson> value;
      if (id.length == 5) {
        value = await _selectSemesterDialog();
      } else {
        super.onStart(R.current.getCourseSemester);
        value = await CourseConnector.getCourseSemester(id);
        super.onEnd();
      }
      if (value != null) {
        result = value;
        return TaskStatus.success;
      } else {
        return await super.onError(R.current.getCourseSemesterError);
      }
    }
    return status;
  }

  Future<List<SemesterJson>> _selectSemesterDialog() async {
    List<SemesterJson> value = [];
    DateTime dateTime = DateTime.now();
    int year = dateTime.year - 1911;
    int semester = (dateTime.month <= 8 && dateTime.month >= 1) ? 2 : 1;
    if (dateTime.month <= 1) {
      year--;
    }
    SemesterJson before = SemesterJson(semester: semester.toString(), year: year.toString());
    SemesterJson select = await Get.dialog<SemesterJson>(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: Text(R.current.selectSemester),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: NumberPicker(
                            value: year,
                            minValue: 100,
                            maxValue: 120,
                            onChanged: (value) => setState(() => year = value),
                          ),
                        ),
                        Expanded(
                          child: NumberPicker(
                            value: semester,
                            minValue: 1,
                            maxValue: 2,
                            onChanged: (value) => setState(() => semester = value),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                actions: [
                  TextButton(
                      child: Text(R.current.sure),
                      onPressed: () {
                        Get.back<SemesterJson>(
                          result: SemesterJson(
                            semester: semester.toString(),
                            year: year.toString(),
                          ),
                        );
                      })
                ],
              );
            },
          ),
        ) ??
        before;
    value.add(select);
    return value;
  }
}
