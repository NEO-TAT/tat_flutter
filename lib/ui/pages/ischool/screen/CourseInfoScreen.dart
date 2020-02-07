import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/CourseClassJson.dart';
import 'package:flutter_app/src/store/json/CourseTableJson.dart';
import 'package:flutter_app/src/store/json/CourseMainExtraJson.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/task/CourseExtraInfoTask.dart';
import 'package:flutter_app/ui/other/ListViewAnimator.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
  bool isLoading = true;
  final List<Widget> courseData = List();
  final List<Widget> listItem = List();

  @override
  void initState() {
    super.initState();
    isLoading = true;
    Future.delayed(Duration.zero, () {
      _addTask();
    });
  }

  void _addTask() async {
    courseMainInfo = widget.courseInfo.main;
    String courseId = courseMainInfo.course.id;
    TaskHandler.instance.addTask(CourseExtraInfoTask(context, courseId));
    await TaskHandler.instance.startTaskQueue(context);
    courseExtraInfo = Model.instance.tempData[CourseExtraInfoTask.tempDataKey];
    widget.courseInfo.extra = courseExtraInfo;
    courseData.add(
        _buildCourseInfo(sprintf("課號:%s    ", [courseMainInfo.course.id])));
    courseData.add(
        _buildCourseInfo(sprintf("課程名稱:%s", [courseMainInfo.course.name])));
    courseData.add(_buildCourseInfo(
        sprintf("學分:%s    ", [courseMainInfo.course.credits])));
    courseData.add(_buildCourseInfo(
        sprintf("類別:%s    ", [courseExtraInfo.course.category])));
    courseData.add(_buildCourseInfo(
        sprintf("授課老師:%s", [courseMainInfo.getTeacherName()])));
    courseData.add(_buildCourseInfo(
        sprintf("開課班級:%s", [courseMainInfo.getOpenClassName()])));
    courseData.add(_buildCourseInfo(
        sprintf("教室:%s    ", [courseMainInfo.getClassroomName()])));
    courseData.add(_buildCourseInfo(
        sprintf("修課人數:%s", [courseExtraInfo.course.selectNumber])));
    courseData.add(_buildCourseInfo(
        sprintf("撤選人數:%s", [courseExtraInfo.course.withdrawNumber])));

    listItem.removeRange(0, listItem.length);
    listItem.add(_buildInfoTitle("課程資料"));
    listItem.addAll(courseData);
    listItem.add(_buildInfoTitle("學生清單"));
    for (int i = 0; i < courseExtraInfo.classmate.length; i++) {
      listItem
          .add(_buildClassmateInfo(i, widget.courseInfo.extra.classmate[i]));
    }
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); //如果使用AutomaticKeepAliveClientMixin需要呼叫
    return Container(
      padding: EdgeInsets.only(top: 20),
      child: Column(
        children: <Widget>[
          (isLoading)
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Expanded(
                  child: getAnimationList(),
                ),
        ],
      ),
    );
  }

  Widget getAnimationList() {
    return AnimationLimiter(
        child: ListView.builder(
          itemCount: listItem.length,
          itemBuilder: (BuildContext context, int index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque, //讓透明部分有反應
                    child: Container(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: listItem[index]),
                    onTap: () {},
                  ),
                ),
              ),
            );
          },
        ),
      );
  }

  Widget _buildCourseInfo(String text) {
    return Container(
      padding: EdgeInsets.only(bottom: 5),
      child: Row(
        children: <Widget>[
          Icon(Icons.details),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTitle(String title) {
    return Container(
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildClassmateInfo(int index, ClassmateJson classmate) {
    Color color = (index % 2 == 1) ? Colors.white : Color(0xFFF8F8F8);
    return Container(
      color: color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
              child: Text(
            classmate.className,
            textAlign: TextAlign.center,
          )),
          Expanded(
            child: Text(
              classmate.studentId,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              classmate.studentName,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: RaisedButton(
              child: Text("查詢"),
              onPressed: () {
                Navigator.of(context, rootNavigator: true)
                    .pop(classmate.studentId);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
