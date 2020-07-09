import 'dart:async';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/CourseClassJson.dart';
import 'package:flutter_app/src/store/json/CourseTableJson.dart';
import 'package:flutter_app/src/store/json/CourseMainExtraJson.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/task/course/CourseExtraInfoTask.dart';
import 'package:flutter_app/ui/other/MyPageTransition.dart';
import 'package:flutter_app/ui/pages/webview/WebViewPluginPage.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:sprintf/sprintf.dart';

class CourseInfoPage extends StatefulWidget {
  final CourseInfoJson courseInfo;
  final String studentId;

  CourseInfoPage(this.studentId, this.courseInfo);

  @override
  _CourseInfoPageState createState() => _CourseInfoPageState();
}

class _CourseInfoPageState extends State<CourseInfoPage>
    with AutomaticKeepAliveClientMixin {
  CourseMainInfoJson courseMainInfo;
  CourseExtraInfoJson courseExtraInfo;
  bool isLoading = true;
  final List<Widget> courseData = List();
  final List<Widget> listItem = List();
  bool canPop = true;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    BackButtonInterceptor.add(myInterceptor);
    Future.delayed(Duration.zero, () {
      _addTask();
    });
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent) {
    if (!canPop) {
      Navigator.of(context).pop();
    }
    return !canPop;
  }

  void _addTask() async {
    courseMainInfo = widget.courseInfo.main;
    String courseId = courseMainInfo.course.id;
    TaskHandler.instance.addTask(CourseExtraInfoTask(context, courseId));
    await TaskHandler.instance.startTaskQueue(context);
    courseExtraInfo =
        Model.instance.getTempData(CourseExtraInfoTask.tempDataKey);
    widget.courseInfo.extra = courseExtraInfo;
    courseData.add(_buildCourseInfo(
        sprintf("%s: %s", [R.current.courseId, courseMainInfo.course.id])));
    courseData.add(_buildCourseInfo(
        sprintf("%s: %s", [R.current.courseName, courseMainInfo.course.name])));
    courseData.add(_buildCourseInfo(sprintf(
        "%s: %s    ", [R.current.credit, courseMainInfo.course.credits])));
    courseData.add(_buildCourseInfo(sprintf(
        "%s: %s    ", [R.current.category, courseExtraInfo.course.category])));
    courseData.add(_buildCourseInfoWithButton(
        sprintf(
            "%s: %s", [R.current.instructor, courseMainInfo.getTeacherName()]),
        R.current.syllabus,
        courseMainInfo.course.scheduleHref));
    courseData.add(_buildCourseInfo(sprintf(
        "%s: %s", [R.current.startClass, courseMainInfo.getOpenClassName()])));
    courseData.add(_buildMultiButtonInfo(
      sprintf("%s: ", [R.current.classroom]),
      R.current.classroomUse,
      courseMainInfo.getClassroomNameList(),
      courseMainInfo.getClassroomHrefList(),
    ));

    courseData.add(_buildCourseInfo(sprintf("%s: %s",
        [R.current.numberOfStudent, courseExtraInfo.course.selectNumber])));
    courseData.add(_buildCourseInfo(sprintf("%s: %s",
        [R.current.numberOfWithdraw, courseExtraInfo.course.withdrawNumber])));

    listItem.removeRange(0, listItem.length);
    listItem.add(_buildInfoTitle(R.current.courseData));
    listItem.addAll(courseData);
    listItem.add(_buildInfoTitle(R.current.studentList));
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
    TextStyle textStyle = TextStyle(fontSize: 18);
    return Container(
      padding: EdgeInsets.only(bottom: 5),
      child: Row(
        children: <Widget>[
          Icon(Icons.details),
          Expanded(
            child: Text(
              text,
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }

  void _launchWebView(String title, String url) {
    canPop = false;
    Navigator.of(context)
        .push(MyPage.transition(WebViewPluginPage(title, url)))
        .then((_) {
      canPop = true;
    });
  }

  Widget _buildCourseInfoWithButton(
      String text, String buttonText, String url) {
    TextStyle textStyle = TextStyle(fontSize: 18);
    return Container(
      padding: EdgeInsets.only(bottom: 5),
      child: Row(
        children: <Widget>[
          Icon(Icons.details),
          Expanded(
            child: Text(
              text,
              style: textStyle,
            ),
          ),
          (url.isNotEmpty)
              ? RaisedButton(
                  child: Text(
                    buttonText,
                  ),
                  onPressed: () {
                    _launchWebView(buttonText, url);
                  },
                )
              : Container()
        ],
      ),
    );
  }

  Widget _buildInfoTitle(String title) {
    TextStyle textStyle = TextStyle(fontSize: 24);
    return Container(
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        children: <Widget>[
          Text(
            title,
            style: textStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildMultiButtonInfo(String title, String buttonText,
      List<String> textList, List<String> urlList) {
    TextStyle textStyle = TextStyle(fontSize: 18);
    List<Widget> classroomItemList = List();
    for (int i = 0; i < textList.length; i++) {
      String text = textList[i];
      classroomItemList.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            text,
            style: textStyle,
          ),
          urlList[i].isNotEmpty
              ? RaisedButton(
                  onPressed: () {
                    _launchWebView(buttonText, urlList[i]);
                  },
                  child: Text(buttonText),
                )
              : Container()
        ],
      ));
    }
    Widget classroomWidget = Column(
      children: classroomItemList,
    );
    return Container(
      padding: EdgeInsets.only(bottom: 5),
      child: Row(
        children: <Widget>[
          Icon(Icons.details),
          Text(
            title,
            style: textStyle,
          ),
          Expanded(
            child: classroomWidget,
          ),
        ],
      ),
    );
  }

  Widget _buildClassmateInfo(int index, ClassmateJson classmate) {
    Color color;
    color = (index % 2 == 1)
        ? Theme.of(context).backgroundColor
        : Theme.of(context).dividerColor;
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
              classmate.getName(),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: RaisedButton(
              child: Text(R.current.search),
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
