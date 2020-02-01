import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/store/json/CourseDetailJson.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/task/CourseByStudentIdTask.dart';
import 'package:flutter_app/src/taskcontrol/task/ISchoolNewAnnouncementTask.dart';
import 'package:flutter_app/src/taskcontrol/task/SemesterByStudentIdTask.dart';
import 'package:flutter_app/ui/other/CustomRoute.dart';
import 'package:flutter_app/ui/pages/login/LoginPage.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
    Model.instance.init().then((value) {
      UserDataJson userData = Model.instance.userData;
      if (userData.account.isEmpty || userData.password.isEmpty) {
        Navigator.of(context).push( CustomRoute( LoginPage() ) );        //尚未登入
      } else {
        SemesterJson setting = Model.instance.setting.course.semester;
        courseTable = Model.instance.getCourseTable( setting );
        if (courseTable == null) {
          _getCourseTable();
        } else {
          _showCourseTable();
        }
      }
    });
  }

  void _getCourseTable() async {
    UserDataJson userData = Model.instance.userData;
    TaskHandler.instance.addTask( SemesterByStudentIdTask( context , userData.account ) );
    await TaskHandler.instance.startTask(context);
    SemesterJson semesterJson = Model.instance.courseSemesterList[0];  // 取得最新
    courseTable = Model.instance.getCourseTable( semesterJson );
    Log.d( semesterJson.toString() );
    TaskHandler.instance
        .addTask(CourseByStudentIdTask(context, userData.account , semesterJson ));
    await TaskHandler.instance.startTask(context);
    _showCourseTable();
    Model.instance.setting.course.semester = semesterJson;
    Model.instance.setting.course.studentId = userData.account;
    Model.instance.save( Model.settingJsonKey );
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
          childAspectRatio : 1.2 ,  //控制長寬比
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
    if( index < columnCount){
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

  void showMyMaterialDialog(
      BuildContext context, CourseTableDetailJson courseDetail) {
    CourseJson course = courseDetail.course;
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
                  children: <Widget>[Text("地點:"), Text(course.id)],
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
                },
                child: Text("課程公告"),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: new Text("詳細內容"),
              ),
            ],
          );
        });
  }

  _showCourseTable() {
    columnCount = 5;
    rowCount = sectionNumber.length;
    _studentIdControl.text = Model.instance.setting.course.studentId;
    setState(() {});
  }
}
