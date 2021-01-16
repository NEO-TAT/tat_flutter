import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/config/AppConfig.dart';
import 'package:flutter_app/src/model/course/CourseClassJson.dart';
import 'package:flutter_app/src/model/coursetable/CourseTableJson.dart';
import 'package:flutter_app/src/model/userdata/UserDataJson.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/task/TaskFlow.dart';
import 'package:flutter_app/src/task/course/CourseSemesterTask.dart';
import 'package:flutter_app/src/task/course/CourseTableTask.dart';
import 'package:flutter_app/src/task/iplus/IPlusSubscribeNoticeTask.dart';
import 'package:flutter_app/src/task/ntut/NTUTTask.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:flutter_app/ui/other/RouteUtils.dart';
import 'package:flutter_app/ui/pages/coursetable/CourseTableControl.dart';
import 'package:flutter_app/ui/pages/coursetable/OverRepaintBoundary.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sprintf/sprintf.dart';

class CourseTablePage extends StatefulWidget {
  @override
  _CourseTablePageState createState() => _CourseTablePageState();
}

class _CourseTablePageState extends State<CourseTablePage> {
  final TextEditingController _studentIdControl = TextEditingController();
  final FocusNode _studentFocus = new FocusNode();
  GlobalKey _key = GlobalKey();
  bool isLoading = true;
  CourseTableJson courseTableData;
  static double dayHeight = 25;
  static double studentIdHeight = 40;
  static double courseHeight = 60;
  static double sectionWidth = 20;
  static int courseTableWithAlpha = 0xDF;
  static int showCourseTableNum = 9;
  CourseTableControl courseTableControl = CourseTableControl();
  bool favorite = false;
  bool loadCourseNotice = true;

  @override
  void initState() {
    super.initState();
    _studentIdControl.text = " ";
    UserDataJson userData = Model.instance.getUserData();
    Future.delayed(Duration(milliseconds: 200)).then((_) {
      if (userData.account.isEmpty || userData.password.isEmpty) {
        if (Platform.isAndroid) {
          RouteUtils.toLoginScreen().then((value) {
            if (value != null && value) {
              _loadSetting();
            }
          }); //尚未登入
        }
      } else {
        _loadSetting();
      }
    });
  }

  void getCourseNotice() async {
    setState(() {
      loadCourseNotice = false;
    });
    if (!Model.instance.getOtherSetting().checkIPlusNew) {
      return;
    }
    if (!Model.instance.getFirstUse(Model.courseNotice)) {
      return;
    }
    if (Model.instance.getAccount() !=
        Model.instance.getCourseSetting().info.studentId) {
      //只有顯示自己的課表時才會檢查新公告
      return;
    }
    setState(() {
      loadCourseNotice = true;
    });

    TaskFlow taskFlow = TaskFlow();
    var task = IPlusSubscribeNoticeTask();
    taskFlow.addTask(task);
    if (await taskFlow.start()) {
      List<String> v = task.result;
      List<String> value = List();
      v = v ?? List();
      for (int i = 0; i < v.length; i++) {
        String courseName = v[i];
        CourseInfoJson courseInfo =
            courseTableData.getCourseInfoByCourseName(courseName);
        if (courseInfo != null) {
          value.add(courseName);
        }
      }
      if (value != null && value.length > 0) {
        Get.dialog(
          AlertDialog(
            title: Text(R.current.findNewMessage),
            content: Container(
              width: double.minPositive,
              child: ListView.builder(
                itemCount: value.length,
                shrinkWrap: true, //使清單最小化
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    child: FlatButton(
                      child: Text(value[index]),
                      onPressed: () {
                        String courseName = value[index];
                        CourseInfoJson courseInfo = courseTableData
                            .getCourseInfoByCourseName(courseName);
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
            actions: <Widget>[
              FlatButton(
                child: Text(R.current.sure),
                onPressed: () {
                  Get.back();
                },
              ),
            ],
          ),
          barrierDismissible: true,
          useRootNavigator: false,
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
    if (context != null) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _studentFocus.dispose();
    super.dispose();
  }

  void _loadSetting() {
    //Log.d(MediaQuery.of(context).size.height.toString());
    RenderObject renderObject = _key.currentContext.findRenderObject();
    courseHeight = (renderObject.semanticBounds.size.height -
            studentIdHeight -
            dayHeight) /
        showCourseTableNum; //計算高度
    CourseTableJson courseTable = Model.instance.getCourseSetting().info;
    if (courseTable.isEmpty) {
      _getCourseTable();
    } else {
      _showCourseTable(courseTable);
    }
  }

  Future<void> _getSemesterList(String studentId) async {
    TaskFlow taskFlow = TaskFlow();
    var task = CourseSemesterTask(studentId);
    taskFlow.addTask(task);
    if (await taskFlow.start()) {
      Model.instance.setSemesterJsonList(task.result);
    }
  }

  void _getCourseTable(
      {SemesterJson semesterSetting,
      String studentId,
      bool refresh: false}) async {
    await Future.delayed(Duration(microseconds: 100)); //等待頁面刷新
    UserDataJson userData = Model.instance.getUserData();
    studentId = studentId ?? userData.account;
    studentId = studentId.replaceAll(" ", "");
    if (courseTableData?.studentId != studentId) {
      Model.instance.clearSemesterJsonList(); //需重設因為更換了studentId
    }
    SemesterJson semesterJson;
    if (semesterSetting == null) {
      await _getSemesterList(studentId);
      semesterJson = Model.instance.getSemesterJsonItem(0);
    } else {
      semesterJson = semesterSetting;
    }
    if (semesterJson == null) {
      return;
    }

    CourseTableJson courseTable;
    if (!refresh) {
      //是否要去找暫存的
      courseTable =
          Model.instance.getCourseTable(studentId, semesterSetting); //去取找是否已經暫存
    }
    if (courseTable == null) {
      //代表沒有暫存的需要爬蟲
      TaskFlow taskFlow = TaskFlow();
      var task = CourseTableTask(studentId, semesterJson);
      taskFlow.addTask(task);
      if (await taskFlow.start()) {
        courseTable = task.result;
      }
    }
    Model.instance.getCourseSetting().info = courseTable; //儲存課表
    Model.instance.saveCourseSetting();
    _showCourseTable(courseTable);
  }

  Widget _getSemesterItem(SemesterJson semester) {
    String semesterString = semester.year + "-" + semester.semester;
    return FlatButton(
      child: Text(semesterString),
      onPressed: () {
        Get.back();
        _getCourseTable(
            semesterSetting: semester,
            studentId: _studentIdControl.text); //取得課表
      },
    );
  }

  void _showSemesterList() async {
    //顯示選擇學期
    _unFocusStudentInput();
    if (Model.instance.getSemesterList().length == 0) {
      TaskFlow taskFlow = TaskFlow();
      var task = CourseSemesterTask(_studentIdControl.text);
      taskFlow.addTask(task);
      if (await taskFlow.start()) {
        Model.instance.setSemesterJsonList(task.result);
      }
    }
    List<SemesterJson> semesterList = Model.instance.getSemesterList();
    //Model.instance.saveSemesterJsonList();
    Get.dialog(
        AlertDialog(
          content: Container(
            width: double.minPositive,
            child: ListView.builder(
              itemCount: semesterList.length,
              shrinkWrap: true, //使清單最小化
              itemBuilder: (BuildContext context, int index) {
                return _getSemesterItem(semesterList[index]);
              },
            ),
          ),
        ),
        useRootNavigator: false,
        barrierDismissible: true);
  }

  _onPopupMenuSelect(int value) async {
    switch (value) {
      case 0:
        MyToast.show(sprintf("%s:%s",
            [R.current.credit, courseTableData.getTotalCredit().toString()]));
        break;
      case 1:
        _loadFavorite();
        break;
      case 2:
        await screenshot();
        break;
      default:
        break;
    }
  }

  void _setFavorite(bool like) {
    if (like) {
      Model.instance.addCourseTable(courseTableData);
    } else {
      Model.instance.removeCourseTable(courseTableData);
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
        builder:
            (BuildContext context, void Function(void Function()) setState) {
          return AlertDialog(
            content: Container(
              width: double.minPositive,
              child: ListView.builder(
                itemCount: value.length,
                shrinkWrap: true, //使清單最小化
                itemBuilder: (BuildContext context, int index) {
                  return Slidable(
                    actionPane: SlidableDrawerActionPane(),
                    actionExtentRatio: 0.25,
                    child: Container(
                      height: 50,
                      child: FlatButton(
                        child: Container(
                          child: Text(sprintf("%s %s %s-%s", [
                            value[index].studentId,
                            value[index].studentName,
                            value[index].courseSemester.year,
                            value[index].courseSemester.semester
                          ])),
                        ),
                        onPressed: () {
                          Model.instance.getCourseSetting().info =
                              value[index]; //儲存課表
                          Model.instance.saveCourseSetting();
                          _showCourseTable(value[index]);
                          Model.instance.clearSemesterJsonList(); //須清除已儲存學期
                          Get.back();
                        },
                      ),
                    ),
                    secondaryActions: <Widget>[
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
      useRootNavigator: false,
      barrierDismissible: true,
    );
    setState(() {
      favorite =
          (Model.instance.getCourseTableList().contains(courseTableData));
    });
  }

  @override
  Widget build(BuildContext context) {
    SemesterJson semesterSetting =
        courseTableData?.courseSemester ?? SemesterJson();
    String semesterString =
        semesterSetting.year + "-" + semesterSetting.semester;
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
          (!isLoading &&
                  Model.instance.getAccount() != courseTableData.studentId)
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
                    child: Icon(Icons.favorite,
                        color: (favorite) ? Colors.pinkAccent : Colors.white),
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
              if (Platform.isAndroid)
                PopupMenuItem(
                  value: 2,
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
                      // 關閉框線
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
                    /*
                    toolbarOptions: ToolbarOptions(
                      copy: true,
                      paste: true,
                    ),
                     */
                  ),
                ),
                FlatButton(
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
                            height: courseHeight * showCourseTableNum,
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
                      Widget widget;
                      widget = (index == 0)
                          ? _buildDay()
                          : _buildCourseTable(index - 1);
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
    List<Widget> widgetList = List();
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
    color = (index % 2 == 1)
        ? Theme.of(context).backgroundColor
        : Theme.of(context).dividerColor;
    color = color.withAlpha(courseTableWithAlpha);
    List<Widget> widgetList = List();
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
    for (int day in courseTableControl.getDayIntList) {
      CourseInfoJson courseInfo =
          courseTableControl.getCourseInfo(day, section);
      Color color = courseTableControl.getCourseInfoColor(day, section);
      courseInfo = courseInfo ?? CourseInfoJson();
      widgetList.add(
        Expanded(
          child: (courseInfo.isEmpty)
              ? Container()
              : Container(
                  padding: EdgeInsets.all(1),
                  child: RaisedButton(
                    padding: EdgeInsets.all(0),
                    child: AutoSizeText(
                      courseInfo.main.course.name,
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
                    color: color,
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

  //顯示課程對話框
  void showCourseDetailDialog(int section, CourseInfoJson courseInfo) {
    _unFocusStudentInput();
    CourseMainJson course = courseInfo.main.course;
    String classroomName = courseInfo.main.getClassroomName();
    String teacherName = courseInfo.main.getTeacherName();
    String studentId = Model.instance.getCourseSetting().info.studentId;
    setState(() {
      _studentIdControl.text = studentId;
    });
    Get.dialog(
      AlertDialog(
        contentPadding: EdgeInsets.fromLTRB(24.0, 20.0, 10.0, 10.0),
        title: Text(course.name),
        content: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              GestureDetector(
                child:
                    Text(sprintf("%s : %s", [R.current.courseId, course.id])),
                onLongPress: () async {
                  course.id = await _showEditDialog(course.id);
                  Model.instance.saveOtherSetting();
                  setState(() {});
                },
              ),
              Text(sprintf("%s : %s",
                  [R.current.time, courseTableControl.getTimeString(section)])),
              Text(sprintf("%s : %s", [R.current.location, classroomName])),
              Text(sprintf("%s : %s", [R.current.instructor, teacherName])),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              _showCourseDetail(courseInfo);
            },
            child: new Text(R.current.details),
          ),
        ],
      ),
      useRootNavigator: false,
      barrierDismissible: true,
    );
  }

  Future<String> _showEditDialog(String value) async {
    final TextEditingController controller = TextEditingController();
    controller.text = value;
    String v = await Get.dialog<String>(
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
        actions: <Widget>[
          FlatButton(
              child: Text(R.current.cancel),
              onPressed: () {
                Get.back(result: null);
              }),
          FlatButton(
              child: Text(R.current.sure),
              onPressed: () {
                Get.back<String>(result: controller.text);
              })
        ],
      ),
      useRootNavigator: false,
      barrierDismissible: true,
    );
    return v ?? value;
  }

  void _showCourseDetail(CourseInfoJson courseInfo) {
    CourseMainJson course = courseInfo.main.course;
    Get.back();
    String studentId = Model.instance.getCourseSetting().info.studentId;
    if (course.id.isEmpty) {
      MyToast.show(course.name + R.current.noSupport);
    } else {
      RouteUtils.toISchoolPage(studentId, courseInfo).then((value) {
        if (value != null) {
          SemesterJson semesterSetting =
              Model.instance.getCourseSetting().info.courseSemester;
          _getCourseTable(semesterSetting: semesterSetting, studentId: value);
        }
      });
    }
  }

  void _unFocusStudentInput() {
    FocusScope.of(context).requestFocus(FocusNode()); //失焦使鍵盤關閉
    _studentFocus.unfocus();
  }

  void _showCourseTable(CourseTableJson courseTable) async {
    if (courseTable == null) {
      return;
    }
    getCourseNotice(); //查詢訂閱的課程是否有公告
    courseTableData = courseTable;
    _studentIdControl.text = courseTable.studentId;
    _unFocusStudentInput();
    setState(() {
      isLoading = true;
    });
    courseTableControl.set(courseTable); //設定課表顯示狀態
    await Future.delayed(Duration(milliseconds: 50));
    setState(() {
      isLoading = false;
    });
    favorite = (Model.instance.getCourseTable(
            courseTable.studentId, courseTable.courseSemester) !=
        null);
    if (favorite) {
      Model.instance.addCourseTable(courseTableData);
    }
  }

  static const platform = const MethodChannel(AppConfig.methodChannelName);

  Future screenshot() async {
    double originHeight = courseHeight;
    RenderObject renderObject = _key.currentContext.findRenderObject();
    double height =
        renderObject.semanticBounds.size.height - studentIdHeight - dayHeight;
    Directory directory = await getApplicationSupportDirectory();
    String path = directory.path;
    setState(() {
      courseHeight = height / courseTableControl.getSectionIntList.length;
    });
    await Future.delayed(Duration(milliseconds: 100));
    setState(() {
      isLoading = true;
    });
    Log.d(path);
    RenderRepaintBoundary boundary =
        overRepaintKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage(pixelRatio: 2);
    setState(() {
      courseHeight = originHeight;
      isLoading = false;
    });
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    File imgFile = new File('$path/course_widget.png');
    await imgFile.writeAsBytes(pngBytes);
    final bool result = await platform.invokeMethod('update_weight');
    Log.d("complete $result");
    if (result) {
      MyToast.show(R.current.settingComplete);
    } else {
      MyToast.show(R.current.settingCompleteWithError);
    }
  }
}
