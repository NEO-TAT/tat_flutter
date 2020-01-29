import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/store/json/CourseDetailJson.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/task/NTUTLoginTask.dart';
import 'package:flutter_app/ui/other/CustomRoute.dart';
import 'package:flutter_app/ui/pages/login/LoginPage.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
        courseTable = Model.instance.getCourseTable( CourseSemesterJson( year:"106" , semester: "1" ) );
        if( courseTable == null ){
          _login();
        }else{
          _countRowAndColumn();
        }
      }
    });
  }

  void _login() async{
    TaskHandler.instance.startTask( context );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: gradView(),
    );
  }

  Widget gradView(){
    return Scaffold(
      body: Container(
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
                      child: gradViewItem(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      )
    );
  }

  Widget gradViewItem(int index){
    int mod = columnCount;
    CourseDetailJson courseDetail;
    if( courseTable != null){
      courseDetail = courseTable.getCourseDetailByTime( (index % mod ).floor().toString() , sectionNumber[ (index / mod).floor() ] );
    }
    String name = (courseDetail != null) ? courseDetail.courseName : "No";
    return Text( name , textAlign: TextAlign.center );
  }

  _countRowAndColumn(){
    columnCount = 5;
    rowCount = sectionNumber.length;
    setState(() {

    });
  }




}

