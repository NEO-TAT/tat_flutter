import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:sprintf/sprintf.dart';
import 'package:tat/src/R.dart';
import 'package:tat/src/config/app_config.dart';
import 'package:tat/src/model/course/course_class_json.dart';
import 'package:tat/src/model/course/course_main_extra_json.dart';
import 'package:tat/src/model/course_table/course_table_json.dart';
import 'package:tat/src/model/userdata/user_data_json.dart';
import 'package:tat/src/store/model.dart';
import 'package:tat/src/task/course/course_search_task.dart';
import 'package:tat/src/task/course/course_semester_task.dart';
import 'package:tat/src/task/course/course_table_task.dart';
import 'package:tat/src/task/course_oads/course_oad_add_course_task.dart';
import 'package:tat/src/task/iplus/iplus_subscribe_notice_task.dart';
import 'package:tat/src/task/ntut/ntut_orgtree_search_task.dart';
import 'package:tat/src/task/task.dart';
import 'package:tat/src/task/task_flow.dart';
import 'package:tat/src/util/route_utils.dart';
import 'package:tat/ui/other/my_toast.dart';

import 'course_table_control.dart';
import 'over_repaint_boundary.dart';

class CourseTablePage extends StatefulWidget {
  @override
  _CourseTablePageState createState() => _CourseTablePageState();
}

class _CourseTablePageState extends State<CourseTablePage> {
  final TextEditingController _studentIdControl = TextEditingController();
  final FocusNode _studentFocus = new FocusNode();
  final _key = GlobalKey();
  bool isLoading = true;
  late CourseTableJson? courseTableData;
  static double? dayHeight = 25;
  static double? studentIdHeight = 40;
  static double? courseHeight = 60;
  static double? sectionWidth = 20;
  static const courseTableWithAlpha = 0xDF;
  static const showCourseTableNum = 9;
  final courseTableControl = CourseTableControl();
  bool favorite = false;
  bool loadCourseNotice = true;

  @override
  void initState() {
    super.initState();
    _studentIdControl.text = " ";
    final userData = Model.instance.getUserData();
    Future.delayed(Duration(milliseconds: 200)).then((_) {
      if (userData.account.isEmpty || userData.password.isEmpty) {
        RouteUtils.toLoginScreen().then((value) {
          if (value != null && value) {
            _loadSetting();
          }
        });
      } else {
        _loadSetting();
      }
    });
  }

  void getCourseNotice() async {
    setState(() {
      loadCourseNotice = false;
    });
    if (!Model.instance.getOtherSetting()!.checkIPlusNew) {
      return;
    }
    if (!Model.instance.getFirstUse(Model.courseNotice, timeOut: 15 * 60)) {
      return;
    }
    if (Model.instance.getAccount() != Model.instance.getCourseSetting()!.info!.studentId) {
      return;
    }
    setState(() {
      loadCourseNotice = true;
    });

    final taskFlow = TaskFlow();
    final task = IPlusSubscribeNoticeTask();
    task.openLoadingDialog = false;
    taskFlow.addTask(task);
    if (await taskFlow.start()) {
      // FIXME remove unnecessary null check (the right operand)
      final List<String?> v = task.result;
      final List<String> value = [];
      for (int i = 0; i < v.length; i++) {
        final courseName = v[i];
        final courseInfo = courseTableData!.getCourseInfoByCourseName(courseName!);
        if (courseInfo != null) {
          value.add(courseName);
        }
      }
      if (value.length > 0) {
        Get.dialog(
          AlertDialog(
            title: Text(R.current.findNewMessage),
            content: Container(
              width: double.minPositive,
              child: ListView.builder(
                itemCount: value.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    child: TextButton(
                      child: Text(value[index]),
                      onPressed: () {
                        final courseName = value[index];
                        final courseInfo = courseTableData!.getCourseInfoByCourseName(courseName);
                        if (courseInfo != null) {
                          _showCourseDetail(courseInfo);
                        } else {
                          MyToast.show(R.current.noSupport);
                          Get.back();
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                child: Text(R.current.sure),
                onPressed: () {
                  Get.back();
                },
              ),
            ],
          ),
          barrierDismissible: true,
        );
      }
    }
    Model.instance.setAlreadyUse(Model.courseNotice);
    setState(() {
      loadCourseNotice = false;
    });
  }

  @override
  void setState(fn) {
    super.setState(fn);
  }

  @override
  void dispose() {
    _studentFocus.dispose();
    super.dispose();
  }

  void _loadSetting() {
    final renderObject = _key.currentContext!.findRenderObject();
    courseHeight =
        (renderObject!.semanticBounds.size.height - studentIdHeight! - dayHeight!) / showCourseTableNum; //計算高度
    final courseTable = Model.instance.getCourseSetting()!.info;
    if (courseTable == null || courseTable.isEmpty) {
      _getCourseTable();
    } else {
      _showCourseTable(courseTable);
    }
  }

  Future<void> _getSemesterList(String studentId) async {
    final taskFlow = TaskFlow();
    final task = CourseSemesterTask(studentId);
    taskFlow.addTask(task);
    if (await taskFlow.start()) {
      Model.instance.setSemesterJsonList(task.result);
    }
  }

  void _getCourseTable({SemesterJson? semesterSetting, String? studentId, bool refresh: false}) async {
    await Future.delayed(Duration(microseconds: 100));
    UserDataJson userData = Model.instance.getUserData();
    studentId ??= userData.account;
    studentId = studentId.replaceAll(" ", "");
    if (courseTableData?.studentId != studentId) {
      Model.instance.clearSemesterJsonList();
    }
    SemesterJson? semesterJson;
    if (semesterSetting == null) {
      await _getSemesterList(studentId);
      semesterJson = Model.instance.getSemesterJsonItem(0);
    } else {
      semesterJson = semesterSetting;
    }
    if (semesterJson == null) {
      return;
    }

    CourseTableJson? courseTable;
    if (!refresh) {
      courseTable = Model.instance.getCourseTable(studentId, semesterSetting);
    }
    if (courseTable == null) {
      final taskFlow = TaskFlow();
      final task = CourseTableTask(studentId, semesterJson);
      taskFlow.addTask(task);
      if (await taskFlow.start()) {
        courseTable = task.result;
      } else {
        final task = NTUTOrgtreeSearchTask(studentId);
        taskFlow.addTask(task);
        if (await taskFlow.start()) {
          _studentIdControl.text = task.result.id!;
          _getCourseTable(studentId: _studentIdControl.text);
        } else {
          MyToast.show(R.current.getCourseError);
        }
      }
    }
    Model.instance.getCourseSetting()!.info = courseTable;
    Model.instance.saveCourseSetting();
    _showCourseTable(courseTable!);
  }

  Widget _getSemesterItem(SemesterJson semester) {
    final semesterString = semester.year + "-" + semester.semester;
    return TextButton(
      child: Text(semesterString),
      onPressed: () {
        Get.back();
        _getCourseTable(semesterSetting: semester, studentId: _studentIdControl.text);
      },
    );
  }

  void _showSemesterList() async {
    _unFocusStudentInput();
    if (Model.instance.getSemesterList().length == 0) {
      final taskFlow = TaskFlow();
      final task = CourseSemesterTask(_studentIdControl.text);
      taskFlow.addTask(task);
      if (await taskFlow.start()) {
        Model.instance.setSemesterJsonList(task.result);
      }
    }
    final semesterList = Model.instance.getSemesterList();
    //Model.instance.saveSemesterJsonList();
    Get.dialog(
      AlertDialog(
        content: Container(
          width: double.minPositive,
          child: ListView.builder(
            itemCount: semesterList.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return _getSemesterItem(semesterList[index]);
            },
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  _onPopupMenuSelect(int value) async {
    switch (value) {
      case 0:
        MyToast.show(sprintf("%s:%s", [R.current.credit, courseTableData!.getTotalCredit().toString()]));
        break;
      case 1:
        _loadFavorite();
        break;
      case 2:
        _addCustomCourse();
        break;
      default:
        break;
    }
  }

  _addCustomCourse() {
    final control = TextEditingController();
    late Task<List<CourseMainInfoJson>>? task;
    Get.dialog(
      StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
        return AlertDialog(
          title: Text(R.current.importCourse),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(R.current.importCourseWarning),
                  TextField(
                    controller: control,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: R.current.inputCourseName,
                    ),
                    onEditingComplete: () async {
                      FocusScope.of(context).unfocus();
                      final taskFlow = TaskFlow();
                      task = CourseSearchTask(courseTableData!.courseSemester!, control.text);
                      taskFlow.addTask(task!);
                      if (await taskFlow.start()) {
                        setState(() {});
                      }
                    },
                  ),
                  if (task != null && task?.result != null)
                    Column(
                      children: task!.result
                          .map(
                            (info) => Container(
                              padding: EdgeInsets.only(top: 10, bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: AutoSizeText(
                                      sprintf("%s\n%s\n%s\n%s\n%s\n%s\n%s", [
                                        "${R.current.courseId}: ${info.course!.id}",
                                        "${R.current.courseName}: ${info.course!.name}",
                                        "${R.current.instructor}: ${info.getTeacherName()}",
                                        "${R.current.startClass}: ${info.getOpenClassName()}",
                                        "${R.current.classroom}: ${info.getClassroomName()}",
                                        "${R.current.time}: ${info.getTime()}",
                                        "${R.current.note}: ${info.course!.note}",
                                      ]),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      if (!courseTableData!.addCourseDetailByCourseInfo(info)) {
                                        MyToast.show(R.current.addCustomCourseError);
                                      }
                                      Get.back();
                                      Model.instance.getCourseSetting()!.info = courseTableData;
                                      Model.instance.saveCourseSetting();
                                      _loadSetting();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  void _setFavorite(bool like) {
    if (like) {
      Model.instance.addCourseTable(courseTableData!);
    } else {
      Model.instance.removeCourseTable(courseTableData!);
    }
    Model.instance.saveCourseTableList();
  }

  void _loadFavorite() async {
    List<CourseTableJson> value = Model.instance.getCourseTableList();
    if (value.length == 0) {
      MyToast.show(R.current.noAnyFavorite);
      return;
    }
    Get.dialog(
      StatefulBuilder(
        builder: (BuildContext context, void Function(void Function()) setState) {
          return AlertDialog(
            content: Container(
              width: double.minPositive,
              child: ListView.builder(
                itemCount: value.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return Slidable(
                    actionPane: SlidableDrawerActionPane(),
                    actionExtentRatio: 0.25,
                    child: Container(
                      height: 50,
                      child: TextButton(
                        child: Container(
                          child: Text(sprintf("%s %s %s-%s", [
                            value[index].studentId,
                            value[index].studentName,
                            value[index].courseSemester!.year,
                            value[index].courseSemester!.semester
                          ])),
                        ),
                        onPressed: () {
                          Model.instance.getCourseSetting()!.info = value[index];
                          Model.instance.saveCourseSetting();
                          _showCourseTable(value[index]);
                          Model.instance.clearSemesterJsonList();
                          Get.back();
                        },
                      ),
                    ),
                    secondaryActions: [
                      IconSlideAction(
                        caption: R.current.delete,
                        color: Colors.red,
                        icon: Icons.delete_forever,
                        onTap: () async {
                          Model.instance.removeCourseTable(value[index]);
                          value.remove(index);
                          await Model.instance.saveCourseTableList();
                          setState(() {});
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
      barrierDismissible: true,
    );
    setState(() {
      favorite = (Model.instance.getCourseTableList().contains(courseTableData));
    });
  }

  @override
  Widget build(BuildContext context) {
    final semesterSetting = courseTableData?.courseSemester ?? SemesterJson();
    final semesterString = semesterSetting.year + "-" + semesterSetting.semester;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(R.current.titleCourse),
        actions: [
          (!isLoading && loadCourseNotice)
              ? Padding(
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                    strokeWidth: 4,
                  ),
                )
              : Container(),
          (!isLoading && Model.instance.getAccount() != courseTableData!.studentId)
              ? Padding(
                  padding: EdgeInsets.only(
                    right: 20,
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        favorite = !favorite;
                      });
                      _setFavorite(favorite);
                    },
                    child: Icon(
                      Icons.favorite,
                      color: (favorite) ? Colors.pinkAccent : Colors.white,
                    ),
                  ),
                )
              : Container(),
          Padding(
            padding: EdgeInsets.only(
              right: 20,
            ),
            child: InkWell(
              onTap: () {
                _getCourseTable(
                  semesterSetting: courseTableData?.courseSemester,
                  studentId: _studentIdControl.text,
                  refresh: true,
                );
              },
              child: Icon(EvaIcons.refreshOutline),
            ),
          ),
          PopupMenuButton<int>(
            onSelected: (result) {
              setState(() {
                _onPopupMenuSelect(result);
              });
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 0,
                child: Text(R.current.searchCredit),
              ),
              PopupMenuItem(
                value: 1,
                child: Text(R.current.loadFavorite),
              ),
              if (_studentIdControl.text == Model.instance.getAccount())
                PopupMenuItem(
                  value: 2,
                  child: Text(R.current.importCourse),
                ),
              if (Platform.isAndroid)
                PopupMenuItem(
                  value: 3,
                  child: Text(R.current.setAsAndroidWeight),
                ),
            ],
          )
        ],
      ),
      body: Column(
        key: _key,
        children: <Widget>[
          Container(
            height: studentIdHeight,
            color: Theme.of(context).backgroundColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    scrollPadding: EdgeInsets.all(0),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(10),
                      hintText: R.current.pleaseEnterStudentId,
                    ),
                    onEditingComplete: () {
                      if (_studentIdControl.text.isEmpty) {
                        MyToast.show(R.current.pleaseEnterStudentId);
                      } else {
                        _getCourseTable(studentId: _studentIdControl.text);
                      }
                      _studentFocus.unfocus();
                    },
                    controller: _studentIdControl,
                    focusNode: _studentFocus,
                  ),
                ),
                TextButton(
                  child: Container(
                    child: Row(
                      children: <Widget>[
                        Text(
                          semesterString,
                          textAlign: TextAlign.center,
                        ),
                        Padding(
                          padding: EdgeInsets.all(5),
                        ),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                  onPressed: () {
                    _showSemesterList();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildListViewWithScreenshot(),
          ),
        ],
      ),
    );
  }

  final GlobalKey<OverRepaintBoundaryState> overRepaintKey = GlobalKey();

  Widget _buildListViewWithScreenshot() {
    return SingleChildScrollView(
      child: OverRepaintBoundary(
        key: overRepaintKey,
        child: RepaintBoundary(
          child: (isLoading)
              ? Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          //makes the red row full width
                          child: Container(
                            height: courseHeight! * showCourseTableNum,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Column(
                  children: List.generate(
                    1 + courseTableControl.getSectionIntList.length,
                    (index) {
                      final widget = (index == 0) ? _buildDay() : _buildCourseTable(index - 1);
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: ScaleAnimation(
                          child: FadeInAnimation(
                            child: widget,
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDay() {
    List<Widget> widgetList = [];
    widgetList.add(Container(
      width: sectionWidth,
    ));
    for (int i in courseTableControl.getDayIntList) {
      widgetList.add(
        Expanded(
          child: Text(
            courseTableControl.getDayString(i),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Container(
      color: Theme.of(context).backgroundColor.withAlpha(courseTableWithAlpha),
      height: dayHeight,
      child: Row(
        children: widgetList,
      ),
    );
  }

  Widget _buildCourseTable(int index) {
    int section = courseTableControl.getSectionIntList[index];
    Color color;
    color = (index % 2 == 1) ? Theme.of(context).backgroundColor : Theme.of(context).dividerColor;
    color = color.withAlpha(courseTableWithAlpha);
    List<Widget> widgetList = [];
    widgetList.add(
      Container(
        width: sectionWidth,
        alignment: Alignment.center,
        child: Text(
          courseTableControl.getSectionString(section),
          textAlign: TextAlign.center,
        ),
      ),
    );
    for (final day in courseTableControl.getDayIntList) {
      final color = courseTableControl.getCourseInfoColor(day, section);
      final courseInfo = CourseInfoJson();
      widgetList.add(
        Expanded(
          child: (courseInfo.isEmpty)
              ? Container()
              : Container(
                  padding: EdgeInsets.all(1),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(0),
                      primary: color,
                    ),
                    child: AutoSizeText(
                      courseInfo.main!.course!.name,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                      minFontSize: 10,
                      maxLines: 3,
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () {
                      showCourseDetailDialog(section, courseInfo);
                    },
                  ),
                ),
        ),
      );
    }
    return Container(
      color: color,
      height: courseHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widgetList,
      ),
    );
  }

  void showCourseDetailDialog(int section, CourseInfoJson courseInfo) {
    _unFocusStudentInput();
    final course = courseInfo.main!.course;
    final classroomName = courseInfo.main!.getClassroomName();
    final teacherName = courseInfo.main!.getTeacherName();
    final studentId = Model.instance.getCourseSetting()!.info!.studentId;
    setState(() {
      _studentIdControl.text = studentId;
    });
    Get.dialog(
      AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(24.0, 20.0, 10.0, 10.0),
        title: Text(course!.name),
        content: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                child: Text(sprintf("%s : %s", [R.current.courseId, course.id])),
                onLongPress: () async {
                  course.id = await _showEditDialog(course.id);
                  Model.instance.saveOtherSetting();
                  setState(() {});
                },
              ),
              Text(sprintf("%s : %s", [R.current.time, courseTableControl.getTimeString(section)])),
              Text(sprintf("%s : %s", [R.current.location, classroomName])),
              Text(sprintf("%s : %s", [R.current.instructor, teacherName])),
            ],
          ),
        ),
        actions: [
          if (!course.isSelect)
            TextButton(
              onPressed: () {
                courseTableData!.removeCourseByCourseId(course.id);
                Model.instance.getCourseSetting()!.info = courseTableData;
                Model.instance.saveCourseSetting();
                _loadSetting();
                Get.back();
              },
              child: new Text(R.current.delete),
            ),
          if (!course.isSelect)
            TextButton(
              onPressed: () async {
                final taskFlow = TaskFlow();
                taskFlow.addTask(CourseOadAddCourseTask(course.id));
                if (await taskFlow.start()) {
                  _getCourseTable(
                    semesterSetting: courseTableData?.courseSemester,
                    studentId: _studentIdControl.text,
                    refresh: true,
                  );
                }
                Get.back();
              },
              child: new Text(R.current.tryAddCourse),
            ),
          TextButton(
            onPressed: () {
              _showCourseDetail(courseInfo);
            },
            child: new Text(R.current.details),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  Future<String> _showEditDialog(String value) async {
    final TextEditingController controller = TextEditingController();
    controller.text = value;
    final v = await Get.dialog<String>(
      AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text('Edit'),
        content: Row(
          children: <Widget>[
            Expanded(
              child: new TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(hintText: value),
              ),
            )
          ],
        ),
        actions: [
          TextButton(
              child: Text(R.current.cancel),
              onPressed: () {
                Get.back(result: null);
              }),
          TextButton(
              child: Text(R.current.sure),
              onPressed: () {
                Get.back<String>(result: controller.text);
              })
        ],
      ),
      barrierDismissible: true,
    );
    return v ?? value;
  }

  void _showCourseDetail(CourseInfoJson courseInfo) {
    final course = courseInfo.main!.course;
    Get.back();
    final studentId = Model.instance.getCourseSetting()!.info!.studentId;
    if (course!.id.isEmpty) {
      MyToast.show(course.name + R.current.noSupport);
    } else {
      RouteUtils.toISchoolPage(studentId, courseInfo).then((value) {
        if (value != null) {
          final semesterSetting = Model.instance.getCourseSetting()!.info!.courseSemester;
          _getCourseTable(semesterSetting: semesterSetting, studentId: value);
        }
      });
    }
  }

  void _unFocusStudentInput() {
    FocusScope.of(context).requestFocus(FocusNode());
    _studentFocus.unfocus();
  }

  void _showCourseTable(CourseTableJson? courseTable) async {
    if (courseTable == null) {
      return;
    }
    getCourseNotice();
    courseTableData = courseTable;
    _studentIdControl.text = courseTable.studentId;
    _unFocusStudentInput();
    setState(() {
      isLoading = true;
    });
    courseTableControl.set(courseTable);
    await Future.delayed(Duration(milliseconds: 50));
    setState(() {
      isLoading = false;
    });
    favorite = (Model.instance.getCourseTable(courseTable.studentId, courseTable.courseSemester) != null);
    if (favorite) {
      Model.instance.addCourseTable(courseTableData!);
    }
  }

  static const platform = const MethodChannel(AppConfig.method_channel_widget_name);
}
