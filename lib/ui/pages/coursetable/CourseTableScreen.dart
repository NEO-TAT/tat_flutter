import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/store/json/CourseClassJson.dart';
import 'package:flutter_app/src/store/json/CourseTableJson.dart';
import 'package:flutter_app/src/store/json/UserDataJson.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/task/CourseTableTask.dart';
import 'package:flutter_app/src/taskcontrol/task/CourseSemesterTask.dart';
import 'package:flutter_app/src/update/AppUpdate.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:flutter_app/ui/pages/ischool/ISchoolScreen.dart';
import 'package:flutter_app/ui/pages/login/LoginPage.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:page_transition/page_transition.dart';
import 'package:sprintf/sprintf.dart';
import 'CourseTableControl.dart';

class CourseTableScreen extends StatefulWidget {
  @override
  _CourseTableScreen createState() => _CourseTableScreen();
}

class _CourseTableScreen extends State<CourseTableScreen> {
  final TextEditingController _studentIdControl = TextEditingController();
  final FocusNode _studentFocus = new FocusNode();
  GlobalKey _key = GlobalKey();
  bool isLoading = true;
  CourseTableJson courseTableData;
  static double dayHeight = 25;
  static double studentIdHeight = 40;
  static double courseHeight = 60;
  static double sectionWidth = 20;
  CourseTableControl courseTableControl = CourseTableControl();

  @override
  void initState() {
    super.initState();
    _studentIdControl.text = " ";
    UserDataJson userData = Model.instance.getUserData();
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        if (!visible) {
          _studentFocus.unfocus();
        }
      },
    );
    Future.delayed(Duration(milliseconds: 200)).then((_) {
      if (userData.account.isEmpty || userData.password.isEmpty) {
        Navigator.of(context)
            .push(
          PageTransition(
            type: PageTransitionType.downToUp,
            child: LoginPage(),
          ),
        )
            .then((value) {
          if (value) {
            _loadSetting();
          }
        }); //尚未登入
      } else {
        _loadSetting();
        _checkAppVersion();
      }
    });
  }

  void _checkAppVersion() {
    AppUpdate.checkUpdate().then((value) {
      if (value != null) {
        AppUpdate.showUpdateDialog(context, value);
      }
    });
  }

  @override
  void dispose() {
    KeyboardVisibilityNotification().dispose();
    super.dispose();
  }

  void _loadSetting() {
    //Log.d(MediaQuery.of(context).size.height.toString());
    RenderObject renderObject = _key.currentContext.findRenderObject();
    courseHeight = (renderObject.semanticBounds.size.height -
            studentIdHeight -
            dayHeight) /
        9; //計算高度
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
    if (courseTableData?.studentId != studentId) {
      Model.instance.clearSemesterJsonList(); //需重設因為更換了studentId
    }
    SemesterJson semesterJson;
    if (semesterSetting == null) {
      await _getSemesterList(studentId);
      semesterJson = Model.instance.setSemesterJsonItem(0);
    } else {
      semesterJson = semesterSetting;
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
      courseTable = Model.instance.getTempData(CourseTableTask.courseTableTempKey);
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
    if (Model.instance.getSemesterList().length == 0) {
      TaskHandler.instance
          .addTask(CourseSemesterTask(context, _studentIdControl.text));
      await TaskHandler.instance.startTaskQueue(context);
    }
    List<SemesterJson> semesterList = Model.instance.getSemesterList();
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

  _onPopupMenuSelect(int value) {
    switch (value) {
      case 1:
        _getCourseTable(
            semesterSetting: courseTableData?.courseSemester,
            studentId: _studentIdControl.text,
            refresh: true);
        break;
      default:
        break;
    }
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
        title: Text(S.current.titleCourse),
        actions: [
          PopupMenuButton<int>(
            // overflow menu
            onSelected: (value) {
              _onPopupMenuSelect(value);
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 1,
                  child: Text(S.current.refresh),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        key: _key,
        children: <Widget>[
          Container(
            height: studentIdHeight,
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
                      hintText: S.current.pleaseEnterStudentId,
                    ),
                    onEditingComplete: () {
                      if (_studentIdControl.text.isEmpty) {
                        MyToast.show(S.current.pleaseEnterStudentId);
                      } else {
                        _getCourseTable(studentId: _studentIdControl.text);
                      }
                      _studentFocus.unfocus();
                    },
                    controller: _studentIdControl,
                    focusNode: _studentFocus,
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
            child: _buildListView(),
          ),
        ],
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
      height: dayHeight,
      child: Row(
        children: widgetList,
      ),
    );
  }

  Widget _buildCourseTable(int index) {
    int section = courseTableControl.getSectionIntList[index];
    Color color = (index % 2 == 1) ? Colors.white : Color(0xFFF8F8F8);
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
                      style: TextStyle(fontSize: 14),
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
    CourseMainJson course = courseInfo.main.course;
    String classroomName = courseInfo.main.getClassroomName();
    String teacherName = courseInfo.main.getTeacherName();
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
                Text(sprintf("%s : %s", [S.current.courseId, course.id])),
                Text(sprintf("%s : %s", [
                  S.current.time,
                  courseTableControl.getTimeString(section)
                ])),
                Text(sprintf("%s : %s", [S.current.location, classroomName])),
                Text(sprintf("%s : %s", [S.current.instructor, teacherName])),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                _showCourseDetail(courseInfo);
              },
              child: new Text(S.current.details),
            ),
          ],
        );
      },
    );
  }

  void _showCourseDetail(CourseInfoJson courseInfo) {
    CourseMainJson course = courseInfo.main.course;
    Navigator.of(context).pop();
    String studentId = _studentIdControl.text;
    if (course.id.isEmpty) {
      MyToast.show(course.name + S.current.noSupport);
    } else {
      Navigator.of(context, rootNavigator: true)
          .push(
        PageTransition(
          type: PageTransitionType.leftToRight,
          child: ISchoolScreen(studentId,  courseInfo),
        ),
      )
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

  void _showCourseTable(CourseTableJson courseTable) async {
    courseTableData = courseTable;
    _studentIdControl.text = courseTable.studentId;
    setState(() {
      isLoading = true;
    });
    courseTableControl.set(courseTable); //設定課表顯示狀態
    await Future.delayed(Duration(milliseconds: 50));
    setState(() {
      isLoading = false;
    });
  }
}
