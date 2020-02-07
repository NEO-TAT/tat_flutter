import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/store/json/CourseClassJson.dart';
import 'package:flutter_app/src/store/json/CourseTableJson.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/task/CheckCookiesTask.dart';
import 'package:flutter_app/src/taskcontrol/task/CourseTableTask.dart';
import 'package:flutter_app/src/taskcontrol/task/ISchoolNewAnnouncementTask.dart';
import 'package:flutter_app/src/taskcontrol/task/CourseSemesterTask.dart';
import 'package:flutter_app/src/taskcontrol/task/ScoreRankTask.dart';
import 'package:flutter_app/ui/other/CustomRoute.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:flutter_app/ui/pages/ischool/ISchoolScreen.dart';
import 'package:flutter_app/ui/pages/login/LoginPage.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:page_transition/page_transition.dart';
import '../../../../../src/store/Model.dart';
import '../../../../../src/store/json/UserDataJson.dart';

class CourseTableScreen extends StatefulWidget {
  @override
  _CourseTableScreen createState() => _CourseTableScreen();
}

class _CourseTableScreen extends State<CourseTableScreen> {
  final TextEditingController _studentIdControl = TextEditingController();
  final FocusNode _studentFocus = new FocusNode();
  bool isLoading = true;
  CourseTableJson courseTableData;
  int columnCount = 14;
  int rowCount = 7;

  @override
  void initState() {
    super.initState();
    UserDataJson userData = Model.instance.userData;
    if (userData.account.isEmpty || userData.password.isEmpty) {
      Future.delayed(Duration(seconds: 1)).then((_) {
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
      });
    } else {
      _loadSetting();
    }
  }

  void _loadSetting() {
    CourseTableJson courseTable = Model.instance.setting.course.info;
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

  void _getCourseTable({SemesterJson semesterSetting, String studentId}) async {
    Log.d("_getCourseTable");
    await Future.delayed(Duration(microseconds: 100));  //等待頁面刷新
    UserDataJson userData = Model.instance.userData;
    studentId = studentId ?? userData.account;
    if (courseTableData?.studentId != studentId) {
      Model.instance.courseSemesterList = List(); //需重設因為更換了studentId
    }
    SemesterJson semesterJson;
    if (semesterSetting == null) {
      await _getSemesterList(studentId);
      semesterJson = Model.instance.courseSemesterList[0];
    } else {
      semesterJson = semesterSetting;
    }

    CourseTableJson courseTable;
    courseTable =
        Model.instance.getCourseTable(studentId, semesterSetting); //去取找是否已經暫存
    if (courseTable == null) {
      TaskHandler.instance
          .addTask(CourseTableTask(context, studentId, semesterJson));
      await TaskHandler.instance.startTaskQueue(context);
      courseTable = Model.instance.tempData[CourseTableTask.courseTableTempKey];
    }
    Model.instance.setting.course.info = courseTable; //儲存課表
    Model.instance.save(Model.settingJsonKey);
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
    if (Model.instance.courseSemesterList.length == 0) {
      TaskHandler.instance
          .addTask(CourseSemesterTask(context, _studentIdControl.text));
      await TaskHandler.instance.startTaskQueue(context);
    }
    List<SemesterJson> semesterList = Model.instance.courseSemesterList;
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

  @override
  Widget build(BuildContext context) {
    SemesterJson semesterSetting =
        courseTableData?.courseSemester ?? SemesterJson();
    String semesterString =
        semesterSetting.year + "-" + semesterSetting.semester;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    onEditingComplete: () {
                      _getCourseTable(studentId: _studentIdControl.text);
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
            child: gradView(),
          )
        ],
      ),
    );
  }

  Widget gradView() {
    return Container(
      alignment: Alignment.center,
      child: (isLoading)
          ? Center(
              child: CircularProgressIndicator(),
            )
          : AnimationLimiter(
              child: GridView.count(
                //shrinkWrap: true,
                childAspectRatio: 1.2, //控制長寬比
                crossAxisCount: columnCount,
                children: List.generate(
                  rowCount * columnCount,
                  (int index) {
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      columnCount: columnCount,
                      child: ScaleAnimation(
                        child: FadeInAnimation(
                          child: gradViewItem(context, index),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  Widget gradViewItem(BuildContext context, int index) {
    int mod = columnCount;
    int dayIndex = (index % mod).floor() + 1;
    int sectionNumberIndex = (index / mod).floor();
    if (index < columnCount) {
      return Container(
        color: Colors.white,
      );
    }
    String name;
    CourseInfoJson courseInfo;
    Color color;
    if (courseTableData != null) {
      courseInfo = courseTableData.getCourseDetailByTime(
          Day.values[dayIndex], SectionNumber.values[sectionNumberIndex]);
    }
    name = (courseInfo != null) ? courseInfo.main.course.name : "";
    if (name.isEmpty) {
      color = (sectionNumberIndex % 2 == 1) ? Colors.white : Color(0xFFF8F8F8);
      return Container(
        color: color,
      );
    }

    return Container(
      color: color,
      height: 100,
      padding: EdgeInsets.fromLTRB(1, 1, 1, 1),
      child: RaisedButton(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Text(
          name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
          ),
        ),
        onPressed: () {
          if (courseInfo != null) {
            showCourseDetailDialog(courseInfo);
          }
        },
        color: Colors.blue,
      ),
    );
  }

  //顯示課程對話框
  void showCourseDetailDialog(CourseInfoJson courseInfo) {
    CourseMainJson course = courseInfo.main.course;
    String classroomName = courseInfo.main.getClassroomName();
    String teacherName = courseInfo.main.getTeacherName();
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) {
        return new AlertDialog(
          title: Text(course.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[Text("課號:"), Text(course.id)],
              ),
              Row(
                children: <Widget>[Text("地點:"), Text(classroomName)],
              ),
              Row(
                children: <Widget>[Text("授課老師:"), Text(teacherName)],
              )
            ],
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                _showCourseDetail(courseInfo);
              },
              child: new Text("詳細內容"),
            ),
          ],
        );
      },
    );
  }

  void _showCourseDetail(CourseInfoJson courseInfo) {
    CourseMainJson course = courseInfo.main.course;
    Navigator.of(context).pop();
    if (course.id.isEmpty) {
      MyToast.show( course.name + "不支持" );
    } else {
      Navigator.of(context, rootNavigator: true)
          .push(
        PageTransition(
          type: PageTransitionType.leftToRight,
          child: ISchoolScreen(courseInfo),
        ),
      )
          .then((value) {
        if (value != null) {
          SemesterJson semesterSetting =
              Model.instance.setting.course.info.courseSemester;
          _getCourseTable(semesterSetting: semesterSetting, studentId: value);
        }
      });
    }
  }

  void _showCourseTable(CourseTableJson courseTable) async {
    courseTableData = courseTable;
    columnCount = 5;
    rowCount = SectionNumber.values.length - 1;
    _studentIdControl.text = courseTable.studentId;
    setState(() {
      isLoading = true;
    });
    await Future.delayed(Duration(microseconds: 500));
    setState(() {
      isLoading = false;
    });
  }
}
