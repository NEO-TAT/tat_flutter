import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/store/json/CourseDetailJson.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/task/CheckCookiesTask.dart';
import 'package:flutter_app/src/taskcontrol/task/CourseByStudentIdTask.dart';
import 'package:flutter_app/src/taskcontrol/task/ISchoolNewAnnouncementTask.dart';
import 'package:flutter_app/src/taskcontrol/task/SemesterByStudentIdTask.dart';
import 'package:flutter_app/ui/other/CustomRoute.dart';
import 'package:flutter_app/ui/pages/ischool/ISchoolScreen.dart';
import 'package:flutter_app/ui/pages/login/LoginPage.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import '../../../../../src/store/Model.dart';
import '../../../../../src/store/json/UserDataJson.dart';

class CourseTableScreen extends StatefulWidget {
  @override
  _CourseTableScreen createState() => _CourseTableScreen();
}

class _CourseTableScreen extends State<CourseTableScreen> {
  final TextEditingController _studentIdControl = TextEditingController();
  CourseTableJson courseTable;
  int columnCount = 7;
  int rowCount = 14;
  List<String> sectionNumber = [
    "1",
    "2",
    "3",
    "4",
    "N",
    "5",
    "6",
    "7",
    "8",
    "9",
    "A",
    "B",
    "C",
    "D"
  ];

  @override
  void initState() {
    super.initState();
    UserDataJson userData = Model.instance.userData;
    if (userData.account.isEmpty || userData.password.isEmpty) {
      Future.delayed(Duration(seconds: 1)).then((_) {
        Navigator.of(context, rootNavigator: true)
            .push(
          PageTransition(type: PageTransitionType.downToUp, child: LoginPage()),
        )
            .then((value) {
          if (value) {
            _loadSemester();
          }
        }); //尚未登入
      });
    } else {
      _loadSemester();
    }
  }

  void _loadSemester() {
    SemesterJson setting = Model.instance.setting.course.semester;
    Log.d(setting.toString());
    courseTable = Model.instance.getCourseTable(setting);
    if (courseTable == null) {
      _getCourseTable();
    } else {
      _showCourseTable(setting);
    }
  }

  void _getCourseTable() async {
    UserDataJson userData = Model.instance.userData;
    TaskHandler.instance
        .addTask(SemesterByStudentIdTask(context, userData.account));
    await TaskHandler.instance.startTaskQueue(context);
    SemesterJson semesterJson = Model.instance.courseSemesterList[0]; // 取得最新
    Log.d(semesterJson.toString());
    TaskHandler.instance.addTask(
        CourseByStudentIdTask(context, userData.account, semesterJson));
    await TaskHandler.instance.startTaskQueue(context);
    Model.instance.setting.course.semester = semesterJson;
    Model.instance.setting.course.studentId = userData.account;
    await Model.instance.save(Model.settingJsonKey);
    _showCourseTable(semesterJson);
  }

  @override
  Widget build(BuildContext context) {
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
                    controller: _studentIdControl,
                  ),
                ),
                RaisedButton(
                  child: Text("click"),
                  onPressed: () => {},
                )
              ],
            ),
          ),
          Expanded(
            child: gradView(context),
          )
        ],
      ),
    );
  }

  Widget gradView(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: AnimationLimiter(
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

    CourseTableDetailJson courseDetail;
    if (courseTable != null) {
      courseDetail = courseTable.getCourseDetailByTime(
          Day.values[dayIndex], SectionNumber.values[sectionNumberIndex]);
    }
    String name = (courseDetail != null) ? courseDetail.course.name : "";

    Color color;
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
          if (courseDetail != null) {
            showMyMaterialDialog(context, courseDetail);
          }
        },
        color: Colors.blue,
      ),
    );
  }

  //顯示課程對話框
  void showMyMaterialDialog(
      BuildContext context, CourseTableDetailJson courseDetail) {
    CourseJson course = courseDetail.course;
    ClassroomJson classroom = courseDetail.classroom;
    String teacherName = courseDetail.getTeacherName();
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
                children: <Widget>[Text("地點:"), Text(classroom.name)],
              ),
              Row(
                children: <Widget>[Text("授課老師:"), Text(teacherName)],
              )
            ],
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
                if( courseDetail.course.id.isEmpty ){
                  Fluttertoast.showToast(
                      msg: courseDetail.course.name + "不支持",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIos: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                }else {
                  Navigator.of(context, rootNavigator: true).push(
                      PageTransition(
                          type: PageTransitionType.leftToRight,
                          child: ISchoolScreen(courseDetail)));
                }
              },
              child: new Text("詳細內容"),
            ),
          ],
        );
      },
    );
  }

  _showCourseTable(SemesterJson setting) {
    courseTable = Model.instance.getCourseTable(setting);
    columnCount = 5;
    rowCount = sectionNumber.length;
    _studentIdControl.text = Model.instance.setting.course.studentId;
    setState(() {});
  }
}
