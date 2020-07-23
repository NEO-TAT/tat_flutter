import 'dart:io';
import 'dart:typed_data';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/R.dart';
import 'package:flutter_app/src/connector/ISchoolPlusConnector.dart';
import 'package:flutter_app/src/costants/Constants.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/CourseClassJson.dart';
import 'package:flutter_app/src/store/json/CourseTableJson.dart';
import 'package:flutter_app/src/store/json/UserDataJson.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/task/course/CourseSemesterTask.dart';
import 'package:flutter_app/src/taskcontrol/task/course/CourseTableTask.dart';
import 'package:flutter_app/ui/other/MyPageTransition.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:flutter_app/ui/pages/coursedetail/CourseDetailPage.dart';
import 'package:flutter_app/ui/screen/LoginScreen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sprintf/sprintf.dart';
import '../../../src/taskcontrol/TaskHandler.dart';
import '../../../src/taskcontrol/TaskModelFunction.dart';
import '../../../src/taskcontrol/task/CheckCookiesTask.dart';
import 'CourseTableControl.dart';
import 'OverRepaintBoundary.dart';
import 'dart:ui' as ui;

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
          Navigator.of(context)
              .push(MyPage.transition(LoginScreen()))
              .then((value) {
            if (value) {
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
    TaskHandler.instance.addTask(TaskModelFunction(null, require: [
      CheckCookiesTask.checkNTUT,
      CheckCookiesTask.checkPlusISchool
    ], taskFunction: () async {
      List<String> v = await ISchoolPlusConnector.getSubscribeNotice();
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
        showDialog<void>(
          useRootNavigator: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
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
                            Navigator.of(context).pop();
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
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
      return true;
    }, errorFunction: () {}, successFunction: () {}));
    await TaskHandler.instance.startTaskQueue(null);
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
    TaskHandler.instance.addTask(CourseSemesterTask(context, studentId));
    await TaskHandler.instance.startTaskQueue(context);
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
      TaskHandler.instance
          .addTask(CourseTableTask(context, studentId, semesterJson));
      await TaskHandler.instance.startTaskQueue(context);
      courseTable = Model.instance.getTempData(CourseTableTask.tempDataKey);
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
        Navigator.of(context).pop();
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
      TaskHandler.instance
          .addTask(CourseSemesterTask(context, _studentIdControl.text));
      await TaskHandler.instance.startTaskQueue(context);
    }
    List<SemesterJson> semesterList = Model.instance.getSemesterList();
    //Model.instance.saveSemesterJsonList();
    showDialog(
      useRootNavigator: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
        );
      },
    );
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

  void _loadFavorite() {
    List<CourseTableJson> value = Model.instance.getCourseTableList();
    if (value.length == 0) {
      MyToast.show(R.current.noAnyFavorite);
      return;
    }
    showDialog(
      useRootNavigator: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: double.minPositive,
            child: ListView.builder(
              itemCount: value.length,
              shrinkWrap: true, //使清單最小化
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  child: FlatButton(
                    child: Text(sprintf("%s %s %s-%s", [
                      value[index].studentId,
                      value[index].studentName,
                      value[index].courseSemester.year,
                      value[index].courseSemester.semester
                    ])),
                    onPressed: () {
                      Model.instance.getCourseSetting().info =
                          value[index]; //儲存課表
                      Model.instance.saveCourseSetting();
                      _showCourseTable(value[index]);
                      Model.instance.clearSemesterJsonList(); //須清除已儲存學期
                      Navigator.of(context).pop();
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
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

  Widget _buildListView() {
    return Container(
      child: (isLoading)
          ? Center(
              child: CircularProgressIndicator(),
            )
          : AnimationLimiter(
              child: ListView.builder(
                itemCount: 1 + courseTableControl.getSectionIntList.length,
                itemBuilder: (context, index) {
                  Widget widget;
                  widget =
                      (index == 0) ? _buildDay() : _buildCourseTable(index - 1);
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
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.fromLTRB(24.0, 20.0, 10.0, 10.0),
          title: Text(course.name),
          content: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(sprintf("%s : %s", [R.current.courseId, course.id])),
                Text(sprintf("%s : %s", [
                  R.current.time,
                  courseTableControl.getTimeString(section)
                ])),
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
        );
      },
    );
  }

  void _showCourseDetail(CourseInfoJson courseInfo) {
    CourseMainJson course = courseInfo.main.course;
    Navigator.of(context).pop();
    String studentId = Model.instance.getCourseSetting().info.studentId;
    if (course.id.isEmpty) {
      MyToast.show(course.name + R.current.noSupport);
    } else {
      Navigator.of(context, rootNavigator: true)
          .push(MyPage.transition(ISchoolPage(studentId, courseInfo)))
          .then(
        (value) {
          if (value != null) {
            SemesterJson semesterSetting =
                Model.instance.getCourseSetting().info.courseSemester;
            _getCourseTable(semesterSetting: semesterSetting, studentId: value);
          }
        },
      );
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

  static const platform = const MethodChannel(Constants.methodChannelName);

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
