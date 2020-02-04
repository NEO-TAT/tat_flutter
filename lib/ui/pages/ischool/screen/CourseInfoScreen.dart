import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/CourseMainJson.dart';
import 'package:flutter_app/src/store/json/CoursePartJson.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/task/CourseExtraInfoTask.dart';
import 'package:flutter_app/ui/other/ListViewAnimator.dart';
import 'package:sprintf/sprintf.dart';

class CourseInfoScreen extends StatefulWidget {
  final CourseInfoJson courseInfo;
  CourseInfoScreen(this.courseInfo);

  @override
  _CourseInfoScreen createState() => _CourseInfoScreen();
}

class _CourseInfoScreen extends State<CourseInfoScreen>
    with AutomaticKeepAliveClientMixin {
  CourseMainInfoJson courseMainInfo;
  CourseExtraInfoJson courseExtraInfo;
  final List<String> courseData = List();

  @override
  void initState() {
    super.initState();
    _addTask();
  }

  void _addTask() async {
    courseMainInfo = widget.courseInfo.main;
    String courseId = courseMainInfo.course.id;
    TaskHandler.instance.addTask(CourseExtraInfoTask(context, courseId));
    await TaskHandler.instance.startTaskQueue(context);
    courseExtraInfo = Model.instance.tempData[CourseExtraInfoTask.tempDataKey];
    Log.d(courseExtraInfo.toString());

    courseData.add(sprintf("課號:%s"     , [courseMainInfo.course.id]));
    courseData.add(sprintf("課程名稱:%s" , [courseMainInfo.course.name]));
    courseData.add(sprintf("學分:%s"     , [courseMainInfo.course.credits]));
    courseData.add(sprintf("類別:%s"     , [courseExtraInfo.course.category]));
    courseData.add(sprintf("授課老師:%s" , [courseMainInfo.getTeacherName()]));
    courseData.add(sprintf("開課班級:%s" , [courseMainInfo.getOpenClassName()]));
    courseData.add(sprintf("教室:%s"     , [courseMainInfo.getClassroomName()]));
    courseData.add(sprintf("修課人數:%s" , [courseExtraInfo.course.selectNumber]));
    courseData.add(sprintf("撤選人數:%s" , [courseExtraInfo.course.withdrawNumber]));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); //如果使用AutomaticKeepAliveClientMixin需要呼叫
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Row(
                children: <Widget>[
                  Text(
                    "課程資料",
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),
            ),
            Container(
              child: Expanded(
                child: ListView.builder(
                  itemCount: courseData.length,
                  itemBuilder: (context, index) {
                    Widget widget;
                    widget = Container(
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.details),
                          Text(courseData[index]),
                        ],
                      ),
                    );
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque, //讓透明部分有反應
                      child: WidgetANimator(widget),
                      onTap: () {},
                    );
                  },

                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Row(
                children: <Widget>[
                  Text(
                    "學生名單",
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),
            ),
          ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
