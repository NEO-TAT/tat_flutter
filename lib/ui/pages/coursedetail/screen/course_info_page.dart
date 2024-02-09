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

  const CourseInfoPage(this.studentId, this.course, {required Key key}) : super(key: key);

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

  Widget _buildCourseApplyCard(Course course) {
    return SizedBox(
        height: MediaQuery.of(context).size.width * 0.35,
        child: Row(children: [
          Expanded(
              flex: 5,
              child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.blueAccent),
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
                  child: Column(children: <Widget>[
                    Container(
                        padding: const EdgeInsets.all(2), child: const Text("修課人數", style: TextStyle(fontSize: 14))),
                    Expanded(child: Center(child: Text("150", style: const TextStyle(fontSize: 36))))
                  ]))),
          Container(padding: const EdgeInsets.all(10)),
          Expanded(
              flex: 5,
              child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey),
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
                  child: Column(children: <Widget>[
                    Container(
                        padding: const EdgeInsets.all(2), child: const Text("撤選人數", style: TextStyle(fontSize: 14))),
                    Expanded(child: Center(child: Text("5", style: const TextStyle(fontSize: 36))))
                  ])))
        ]));
  }

  Widget _buildCourseCard(Course course) {
    return SizedBox(
        height: MediaQuery.of(context).size.width * 0.65,
        child: Row(children: [
          Expanded(
              flex: 8,
              child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.yellow[900]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FractionallySizedBox(
                        child: Container(
                            padding: const EdgeInsets.all(10),
                            alignment: const Align(alignment: Alignment.topLeft).alignment,
                            child: Text(course.id.toString(), style: const TextStyle(fontSize: 16))),
                      ),
                      FractionallySizedBox(
                        child: Container(
                            padding: const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
                            alignment: const Align(alignment: Alignment.centerLeft).alignment,
                            child: Container(
                              alignment: const Align(alignment: Alignment.topLeft).alignment,
                              child: Text(course.name, style: const TextStyle(fontSize: 18)),
                            )),
                      ),
                      FractionallySizedBox(
                          child: Container(
                              padding: const EdgeInsets.all(10),
                              alignment: const Align(alignment: Alignment.topLeft).alignment,
                              child: Column(
                                children: [
                                  Container(
                                      alignment: const Align(alignment: Alignment.topLeft).alignment,
                                      child: Text(
                                        course.classNames.join(" "),
                                        style: const TextStyle(fontSize: 14),
                                      )),
                                  Container(
                                      alignment: const Align(alignment: Alignment.topLeft).alignment,
                                      child: Text(
                                        course.teachers.join(" "),
                                        style: const TextStyle(fontSize: 14),
                                      )),
                                  Container(
                                      alignment: const Align(alignment: Alignment.topLeft).alignment,
                                      child: Text(
                                        course.classrooms.join(" "),
                                        style: const TextStyle(fontSize: 14),
                                      ))
                                ],
                              )))
                    ],
                  ))),
          Container(padding: const EdgeInsets.all(10)),
          Expanded(
            flex: 3,
            child: Column(children: [
              Expanded(
                  flex: 5,
                  child: Container(
                      alignment: const Align(alignment: Alignment.topCenter).alignment,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.deepOrange),
                      child: Column(children: <Widget>[
                        Container(
                            padding: const EdgeInsets.all(10), child: const Text("類別", style: TextStyle(fontSize: 14))),
                        Container(
                            padding: const EdgeInsets.all(10),
                            child: Center(
                                child:
                                    Text(course.category == "選" ? "選修" : "必修", style: const TextStyle(fontSize: 18))))
                      ]))),
              Container(padding: const EdgeInsets.all(10)),
              Expanded(
                flex: 5,
                child: Container(
                    padding: const EdgeInsets.all(10),
                    alignment: const Align(alignment: Alignment.topCenter).alignment,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.deepOrangeAccent),
                    child: Column(children: <Widget>[
                      Container(
                          padding: const EdgeInsets.all(10), child: const Text("學分數", style: TextStyle(fontSize: 14))),
                      Container(
                          padding: const EdgeInsets.all(10),
                          child: Center(child: Text(course.credit.toString(), style: const TextStyle(fontSize: 18))))
                    ])),
              )
            ]),
          )
        ]));
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
