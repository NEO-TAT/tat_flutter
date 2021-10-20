import 'dart:async';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:sprintf/sprintf.dart';
import 'package:tat/src/R.dart';
import 'package:tat/src/model/course/course_class_json.dart';
import 'package:tat/src/model/course/course_main_extra_json.dart';
import 'package:tat/src/model/course_table/course_table_json.dart';
import 'package:tat/src/task/course/course_extra_info_task.dart';
import 'package:tat/src/task/task_flow.dart';
import 'package:tat/src/util/route_utils.dart';

class CourseInfoPage extends StatefulWidget {
  final CourseInfoJson courseInfo;
  final String studentId;

  CourseInfoPage(this.studentId, this.courseInfo);

  @override
  _CourseInfoPageState createState() => _CourseInfoPageState();
}

class _CourseInfoPageState extends State<CourseInfoPage>
    with AutomaticKeepAliveClientMixin {
  late CourseMainInfoJson courseMainInfo;
  late CourseExtraInfoJson courseExtraInfo;
  bool isLoading = true;
  final List<Widget> courseData = [];
  final List<Widget> listItem = [];
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

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo routeInfo) {
    if (!canPop) {
      Get.back();
    }
    return !canPop;
  }

  void _addTask() async {
    courseMainInfo = widget.courseInfo.main!;
    final taskFlow = TaskFlow();
    final courseId = courseMainInfo.course!.id;
    final task = CourseExtraInfoTask(courseId);
    taskFlow.addTask(task);
    if (await taskFlow.start()) {
      courseExtraInfo = task.result;
    }
    widget.courseInfo.extra = courseExtraInfo;
    courseData.add(
      _buildCourseInfo(
        sprintf(
          "%s: %s",
          [
            R.current.courseId,
            courseMainInfo.course!.id,
          ],
        ),
      ),
    );
    courseData.add(
      _buildCourseInfo(
        sprintf(
          "%s: %s",
          [
            R.current.courseName,
            courseMainInfo.course!.name,
          ],
        ),
      ),
    );
    courseData.add(
      _buildCourseInfo(
        sprintf(
          "%s: %s    ",
          [
            R.current.credit,
            courseMainInfo.course!.credits,
          ],
        ),
      ),
    );
    courseData.add(
      _buildCourseInfo(
        sprintf(
          "%s: %s    ",
          [
            R.current.category,
            courseExtraInfo.course!.category,
          ],
        ),
      ),
    );
    courseData.add(
      _buildCourseInfoWithButton(
        sprintf(
          "%s: %s",
          [
            R.current.instructor,
            courseMainInfo.getTeacherName(),
          ],
        ),
        R.current.syllabus,
        courseMainInfo.course!.scheduleHref,
      ),
    );
    courseData.add(
      _buildCourseInfo(
        sprintf(
          "%s: %s",
          [
            R.current.startClass,
            courseMainInfo.getOpenClassName(),
          ],
        ),
      ),
    );
    courseData.add(
      _buildMultiButtonInfo(
        sprintf(
          "%s: ",
          [
            R.current.classroom,
          ],
        ),
        R.current.classroomUse,
        courseMainInfo.getClassroomNameList(),
        courseMainInfo.getClassroomHrefList(),
      ),
    );

    courseData.add(
      _buildCourseInfo(
        sprintf(
          "%s: %s",
          [
            R.current.numberOfStudent,
            courseExtraInfo.course!.selectNumber,
          ],
        ),
      ),
    );
    courseData.add(
      _buildCourseInfo(
        sprintf(
          "%s: %s",
          [
            R.current.numberOfWithdraw,
            courseExtraInfo.course!.withdrawNumber,
          ],
        ),
      ),
    );

    listItem.removeRange(0, listItem.length);
    listItem.add(
      _buildInfoTitle(
        R.current.courseData,
      ),
    );
    listItem.addAll(courseData);
    listItem.add(
      _buildInfoTitle(
        R.current.studentList,
      ),
    );
    for (int i = 0; i < courseExtraInfo.classmate!.length; i++) {
      listItem.add(
        _buildClassmateInfo(
          i,
          widget.courseInfo.extra!.classmate![i],
        ),
      );
    }
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      padding: EdgeInsets.only(top: 20),
      child: Column(
        children: [
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
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: listItem[index],
                  ),
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
    final textStyle = TextStyle(fontSize: 18);
    return Container(
      padding: EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
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
    RouteUtils.toWebViewPluginPage(title, url).then((value) => canPop = true);
  }

  Widget _buildCourseInfoWithButton(
    String text,
    String buttonText,
    String url,
  ) {
    final textStyle = TextStyle(fontSize: 18);
    return Container(
      padding: EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(Icons.details),
          Expanded(
            child: Text(
              text,
              style: textStyle,
            ),
          ),
          (url.isNotEmpty)
              ? ElevatedButton(
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
    final textStyle = TextStyle(fontSize: 24);
    return Container(
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        children: [
          Text(
            title,
            style: textStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildMultiButtonInfo(
    String title,
    String buttonText,
    List<String> textList,
    List<String> urlList,
  ) {
    final textStyle = TextStyle(fontSize: 18);
    final List<Widget> classroomItemList = [];
    for (int i = 0; i < textList.length; i++) {
      final text = textList[i];
      classroomItemList.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: textStyle,
          ),
          urlList[i].isNotEmpty
              ? ElevatedButton(
                  onPressed: () {
                    _launchWebView(buttonText, urlList[i]);
                  },
                  child: Text(buttonText),
                )
              : Container()
        ],
      ));
    }
    final Widget classroomWidget = Column(
      children: classroomItemList,
    );
    return Container(
      padding: EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
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
    final color = (index % 2 == 1)
        ? Theme.of(context).backgroundColor
        : Theme.of(context).dividerColor;
    return Container(
      color: color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
            child: ElevatedButton(
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
