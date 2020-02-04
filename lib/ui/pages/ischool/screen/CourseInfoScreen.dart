import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/CourseDetailJson.dart';
import 'package:flutter_app/src/store/json/CourseInfoJson.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/task/CourseByCourseIdTask.dart';


class CourseInfoScreen extends StatefulWidget {
  final CourseTableDetailJson courseTableDetail;
  CourseInfoScreen( this.courseTableDetail );

  @override
  _CourseInfoScreen createState( ) => _CourseInfoScreen();
}

class _CourseInfoScreen extends State<CourseInfoScreen> with AutomaticKeepAliveClientMixin {
  CourseInfoJson courseInfo;

  @override
  void initState() {
    _addTask();
    super.initState();
  }

  void _addTask() async {
    String courseId = widget.courseTableDetail.course.id;
    TaskHandler.instance.addTask( CourseByCourseIdTask( context , courseId ) );
    await TaskHandler.instance.startTaskQueue(context);
    courseInfo = Model.instance.tempData[ CourseByCourseIdTask.tempDataKey ];
    Log.d( courseInfo.toString() );
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);  //如果使用AutomaticKeepAliveClientMixin需要呼叫
    return Container(
      child: Text("app"),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
