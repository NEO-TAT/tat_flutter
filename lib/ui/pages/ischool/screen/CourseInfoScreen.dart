import 'dart:async';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/CourseClassJson.dart';
import 'package:flutter_app/src/store/json/CourseTableJson.dart';
import 'package:flutter_app/src/store/json/CourseMainExtraJson.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/task/CourseExtraInfoTask.dart';
import 'package:flutter_app/ui/pages/BottomNavigationBar/screen/internet/WebViewPluginScreen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:page_transition/page_transition.dart';
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
    courseExtraInfo = Model.instance.tempData[CourseExtraInfoTask.tempDataKey];
    widget.courseInfo.extra = courseExtraInfo;
    courseData.add(_buildCourseInfo(
        sprintf("%s: %s", [S.current.courseId, courseMainInfo.course.id])));
    courseData.add(_buildCourseInfo(
        sprintf("%s: %s", [S.current.courseName, courseMainInfo.course.name])));
    courseData.add(_buildCourseInfo(sprintf(
        "%s: %s    ", [S.current.credit, courseMainInfo.course.credits])));
    courseData.add(_buildCourseInfo(sprintf(
        "%s: %s    ", [S.current.category, courseExtraInfo.course.category])));
    courseData.add(_buildCourseInfoWithButton(
        sprintf(
            "%s: %s", [S.current.instructor, courseMainInfo.getTeacherName()]),
        S.current.syllabus,
        courseMainInfo.course.scheduleHref));
    courseData.add(_buildCourseInfo(sprintf(
        "%s: %s", [S.current.startClass, courseMainInfo.getOpenClassName()])));
    courseData.add(_buildMultiButtonInfo(
      sprintf("%s: ", [S.current.classroom, courseMainInfo.getTeacherName()]),
      S.current.classroomUse,
      courseMainInfo.getClassroomNameList(),
      courseMainInfo.getClassroomHrefList(),
    ));

    courseData.add(_buildCourseInfo(
        sprintf("%s: %s", [ S.current.numberOfStudent , courseExtraInfo.course.selectNumber])));
    courseData.add(_buildCourseInfo(
        sprintf("%s: %s", [S.current.numberOfWithdraw , courseExtraInfo.course.withdrawNumber])));

    listItem.removeRange(0, listItem.length);
    listItem.add(_buildInfoTitle(S.current.courseData));
    listItem.addAll(courseData);
    listItem.add(_buildInfoTitle(S.current.studentList));
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
        .push(
      PageTransition(
        type: PageTransitionType.downToUp,
        child: WebViewPluginScreen(title, url),
      ),
    )
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
          RaisedButton(
            onPressed: () {
              _launchWebView(buttonText, urlList[i]);
            },
            child: Text(buttonText),
          )
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
