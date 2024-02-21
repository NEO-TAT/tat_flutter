// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'dart:async';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/model/course/course_main_extra_json.dart';
import 'package:flutter_app/src/model/course/course_student.dart';
import 'package:flutter_app/src/model/coursetable/course_table_json.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/task/course/course_department_map_task.dart';
import 'package:flutter_app/src/task/course/course_extra_info_task.dart';
import 'package:flutter_app/src/task/task_flow.dart';
import 'package:flutter_app/ui/other/route_utils.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:sprintf/sprintf.dart';
import 'package:flutter_app/src/task/iplus/iplus_get_course_student_list_task.dart';

class CourseInfoPage extends StatefulWidget {
  final CourseInfoJson courseInfo;
  final String studentId;

  const CourseInfoPage(this.studentId, this.courseInfo, {Key key}) : super(key: key);

  final int courseInfoWithAlpha = 0x44;

  @override
  State<CourseInfoPage> createState() => _CourseInfoPageState();
}

class _CourseInfoPageState extends State<CourseInfoPage> with AutomaticKeepAliveClientMixin {
  CourseMainInfoJson courseMainInfo;
  CourseExtraInfoJson courseExtraInfo;
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
    courseMainInfo = widget.courseInfo.main;
    final courseId = courseMainInfo.course.id;
    final taskFlow = TaskFlow();
    final task = CourseExtraInfoTask(courseId);
    taskFlow.addTask(task);
    if (await taskFlow.start()) {
      courseExtraInfo = task.result;
    }
    widget.courseInfo.extra = courseExtraInfo;
    courseData.add(_buildCourseInfo(sprintf("%s: %s", [R.current.courseId, courseMainInfo.course.id])));
    courseData.add(_buildCourseInfo(sprintf("%s: %s", [R.current.courseName, courseMainInfo.course.name])));
    courseData.add(_buildCourseInfo(sprintf("%s: %s    ", [R.current.credit, courseMainInfo.course.credits])));
    courseData.add(_buildCourseInfo(sprintf("%s: %s    ", [R.current.category, courseExtraInfo.course.category])));
    courseData.add(
      _buildCourseInfoWithButton(
        sprintf("%s: %s", [R.current.instructor, courseMainInfo.getTeacherName()]),
        R.current.syllabus,
        courseMainInfo.course.scheduleHref,
      ),
    );
    courseData.add(_buildCourseInfo(sprintf("%s: %s", [R.current.startClass, courseMainInfo.getOpenClassName()])));
    courseData.add(_buildMultiButtonInfo(
      sprintf("%s: ", [R.current.classroom]),
      R.current.classroomUse,
      courseMainInfo.getClassroomNameList(),
      courseMainInfo.getClassroomHrefList(),
    ));

    listItem.removeRange(0, listItem.length);
    listItem.add(_buildInfoTitle(R.current.courseData));
    listItem.addAll(courseData);

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

  Future<List<CourseStudent>> _getCourseStudent() async {
    TaskFlow taskFlow = TaskFlow();
    final task = IPlusGetStudentListTask(courseId: courseMainInfo.course.id);
    taskFlow.addTask(task);
    if (await taskFlow.start()) {
      List<CourseStudent> students = task.result;
      if(students != null){
        return students;
      }
    }
    return <CourseStudent>[];
  }

  Future<Map<String, String>> _getCourseDepartmentMap() async {
    final semester = widget.courseInfo.extra.courseSemester;
    TaskFlow taskFlow = TaskFlow();
    final task = CourseDepartmentMapTask(year: semester.year, semester: semester.semester);
    taskFlow.addTask(task);
    if (await taskFlow.start()) {
      Map<String, String> departmentMap = task.result;
      if(departmentMap != null){
        return departmentMap;
      }
    }
    return <String, String>{};
  }

  String getDepartment(Map<String, String> departmentMap, String studentId){
    /*
      * Since we don't have official data to describe the following hard-coded rule is correct.
      * It may need to confirm or just leave it.
      */
    if(studentId.substring(0, 1) == "4"){
      return R.current.nationalTaipeiUniversity;
    }

    if(studentId.substring(0, 1) == "B"){
      return R.current.taipeiMedicineUniversity;
    }

    if(studentId.substring(3, 6) == "054"){
      return R.current.aduit;
    }

    String department = departmentMap[studentId.substring(3, 5)];

    if(department.isEmpty){
      return department;
    }

    department = departmentMap[studentId.substring(3, 6)];

    if(department != null){
      return department;
    }

    return R.current.unknownDepartment;
  }

  Widget _buildClassmateInfo(int index, String departmentName, String studentId, String studentName, { bool isHeader = false }) {
    double height = isHeader ? 25 : 50;

    final color = (index % 2 == 1)
        ? Theme.of(context).colorScheme.surface
        : Theme.of(context).colorScheme.surfaceVariant.withAlpha(widget.courseInfoWithAlpha);
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(width: 4, height: height),
          Expanded(
            child: Text(
              departmentName,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 4, height: height),
          Expanded(
            child: Text(
              studentId,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 4, height: height),
          Expanded(
            child: Text(
              studentName,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
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
      padding: const EdgeInsets.only(top: 5, bottom: 5),
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
