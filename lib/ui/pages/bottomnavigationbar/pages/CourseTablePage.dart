import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/store/json/CourseDetailJson.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/task/CourseByCourseIdTask.dart';
import 'package:flutter_app/src/taskcontrol/task/CourseByStudentIdTask.dart';
import 'package:flutter_app/src/taskcontrol/task/ISchoolNewAnnouncementTask.dart';
import 'package:flutter_app/src/taskcontrol/task/NTUTLoginTask.dart';
import 'package:flutter_app/ui/other/CustomRoute.dart';
import 'package:flutter_app/ui/pages/login/LoginPage.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:random_color/random_color.dart';
import '../../../../src/store/Model.dart';
import '../../../../src/store/json/UserDataJson.dart';

class CourseTablePage extends StatefulWidget {
  @override
  _CourseTablePage createState() => _CourseTablePage();
}

class _CourseTablePage extends State<CourseTablePage> {

  CourseTableJson courseTable;
  int columnCount = 7;
  int rowCount = 14;
  List<String> sectionNumber = ["1","2","3","4","N","5","6","7","8","9","A","B","C","D"];
  @override
  void initState() {
    super.initState();
    Model.instance.init().then( (value) {
      UserDataJson userData = Model.instance.userData;
      if (userData.account.isEmpty || userData.password.isEmpty) {
        //尚未登入
        Navigator.of(context).push(CustomRoute(LoginPage()));
      } else {
        courseTable = Model.instance.getCourseTable( SemesterJson( year:"108" , semester: "2" ) );
        if( courseTable == null || true){
          _login();
        }else{
          TaskHandler.instance.startTask( context );
          _showCourseTable();
        }
      }
    });
  }

  void _login() async{
    //TaskHandler.instance.addTask( CourseByCourseIdTask(context , "264615" ) );
    TaskHandler.instance.addTask( CourseByStudentIdTask(context , "106360113" , "108" , "1" ) );
    TaskHandler.instance.addTask( ISchoolNewAnnouncementTask(context) );

    TaskHandler.instance.startTask( context );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Home'),
        ),
        body: gradView(context),
    );
  }

  Widget gradView(BuildContext context){
    return Container(
        alignment: Alignment.center,
        child: AnimationLimiter(
          child: GridView.count(
            crossAxisCount: columnCount,
            children: List.generate(
              rowCount * columnCount , (int index) {
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  columnCount: columnCount,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: gradViewItem(context , index),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
    );
  }


  Widget gradViewItem(BuildContext context ,int index){

    int mod = columnCount;
    int dayIndex = (index % mod ).floor() + 1;
    int sectionNumberIndex = (index / mod).floor();

    CourseTableDetailJson courseDetail;
    if(courseTable != null){
      courseDetail = courseTable.getCourseDetailByTime( Day.values[dayIndex] , SectionNumber.values[sectionNumberIndex]  );
    }
    String name = (courseDetail != null) ? courseDetail.course.name : "";

    Color color;
    if( name.isEmpty ){
      color = (sectionNumberIndex % 2 == 1)?Colors.white : Color(0xFFF8F8F8);
    }else{
      color = Colors.cyanAccent;
    }


    return RaisedButton(
      padding: EdgeInsets.fromLTRB(10 , 10 , 10 , 10),
      child: Text(
          name ,
          textAlign: TextAlign.center ,

          style: TextStyle(
              fontSize: 12,
          ),
      ),
      onPressed: () {
        if( courseDetail != null){
            showMyMaterialDialog(context , courseDetail );
        }
      },
      color: color,
    );


  }


  void showMyMaterialDialog(BuildContext context ,CourseTableDetailJson courseDetail) {
      CourseJson course = courseDetail.course;
      String teacherName = courseDetail.getTeacherName();
      showDialog(
        context: context,
        useRootNavigator: false,
        builder: (context) {
          return new AlertDialog(
            title: Text( course.name ),
            content: Column(
              mainAxisSize : MainAxisSize.min ,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text("課號:"),
                    Text( course.id )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text("地點:"),
                    Text( course.id )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text("授課老師:"),
                    Text( teacherName )
                  ],
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



  _showCourseTable(){
    columnCount = 5;
    rowCount = sectionNumber.length;
    setState(() {

    });
  }



}

