import 'dart:async';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/ui/other/route_utils.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:sprintf/sprintf.dart';

import '../../../../src/model/coursetable/course.dart';

class CourseInfoPage extends StatefulWidget {
  final Course course;
  final String studentId;

  const CourseInfoPage(this.studentId, this.course, {Key? key}) : super(key: key);

  final int courseInfoWithAlpha = 0x44;

  @override
  State<CourseInfoPage> createState() => _CourseInfoPageState();
}

class _CourseInfoPageState extends State<CourseInfoPage> with AutomaticKeepAliveClientMixin {
  late Course course;
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
    course = widget.course;
    courseData.add(_buildCourseInfo(sprintf("%s: %s", [R.current.courseId, course.id])));
    courseData.add(_buildCourseInfo(sprintf("%s: %s", [R.current.courseName, course.name])));
    courseData.add(_buildCourseInfo(sprintf("%s: %s", [R.current.credit, course.credit])));
    courseData.add(_buildCourseInfo(sprintf("%s: %s", [R.current.category, course.category])));
    courseData.add(
      _buildCourseInfoWithButton(
        sprintf("%04s: %s", [R.current.instructor, course.teachers.join(" ")]),
        R.current.syllabus,
        course.syllabusLink,
      ),
    );
    courseData.add(_buildCourseInfo(sprintf("%s: %s", [R.current.startClass, course.classNames.join(" ")])));
    courseData.add(_buildMultiButtonInfo(
      sprintf("%s: ", [R.current.classroom]),
      R.current.classroomUse,
      course.classrooms,
      course.classrooms,
    ));

    listItem.removeRange(0, listItem.length);
    listItem.add(_buildInfoTitle(R.current.courseData));
    listItem.addAll(courseData);
    // listItem.add(_buildCourseCard(course));
    // listItem.add(_buildInfoTitle("課程修課資訊"));
    // listItem.add(_buildCourseApplyCard(course));
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); //如果使用AutomaticKeepAliveClientMixin需要呼叫
    return Container(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: <Widget>[
          (isLoading)
              ? const Center(
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
                    padding: const EdgeInsets.only(left: 20, right: 20),
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
    TextStyle textStyle = const TextStyle(fontSize: 18);
    return Container(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: <Widget>[
          const Icon(Icons.details),
          Container(
            alignment: const Align(alignment: Alignment.topCenter).alignment,
            child: Text(
              text,
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }

  void _launchWebView(String title, String urlString) {
    canPop = false;

    final url = Uri.tryParse(urlString);

    if (url != null) {
      RouteUtils.toWebViewPage(initialUrl: url, title: title);
      canPop = true;
    } else {
      // TODO: handle exceptions when the url is null. (null means it may caused by the parse process error.)
    }
  }

  Widget _buildCourseInfoWithButton(String text, String buttonText, String url) {
    return Container(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          const Icon(Icons.details),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          (url.isNotEmpty)
              ? ElevatedButton(
                  child: Text(buttonText),
                  onPressed: () => _launchWebView(buttonText, url),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildInfoTitle(String title) {
    TextStyle textStyle = const TextStyle(fontSize: 24);
    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
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

  Widget _buildMultiButtonInfo(String title, String buttonText, List<String> textList, List<String> urlList) {
    const textStyle = TextStyle(fontSize: 18);
    final classroomItemList = <Widget>[];

    for (int i = 0; i < textList.length; i++) {
      final text = textList[i];
      classroomItemList.add(
        FittedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: textStyle,
              ),
              const SizedBox(width: 4),
              urlList[i].isNotEmpty
                  ? FittedBox(
                      child: ElevatedButton(
                        onPressed: () => _launchWebView(buttonText, urlList[i]),
                        child: Text(buttonText),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.details),
              Text(
                title,
                style: textStyle,
              ),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: classroomItemList,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
