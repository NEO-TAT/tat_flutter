import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/task/CheckCookiesTask.dart';
import 'package:flutter_app/ui/pages/bottomnavigationbar/screen/announcement/NewAnnouncementScreen.dart';
import 'package:flutter_app/ui/pages/bottomnavigationbar/screen/course/CourseTableScreen.dart';
import 'package:flutter_app/ui/pages/bottomnavigationbar/screen/internet/InternetScreen.dart';
import 'package:flutter_app/ui/pages/bottomnavigationbar/screen/setting/SettingScreen.dart';

class BottomNavigationWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BottomNavigationWidgetState();
}

class BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  final _bottomNavigationColor = Colors.blue;
  int _currentIndex = 0;
  List<Widget> list = List();
  @override
  void initState() {
    list
      ..add(CourseTableScreen())
      ..add(NewAnnouncementScreen())
      ..add(InternetScreen())
      ..add(SettingScreen());
    super.initState();
    _addTask();
  }

 void _addTask() async{
    TaskHandler.instance.addTask( CheckCookiesTask(context) );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          resizeToAvoidBottomPadding : false ,
          body: list[_currentIndex],
          bottomNavigationBar: bottomNavigationBar(),
        ),
    );
  }



  Widget bottomNavigationBar(){
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
            icon: Icon(
              Icons.announcement,
              color: _bottomNavigationColor,
            ),
            title: Text(
              'New',
              style: TextStyle(color: _bottomNavigationColor),
            )),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.email,
              color: _bottomNavigationColor,
            ),
            title: Text(
              'Email',
              style: TextStyle(color: _bottomNavigationColor),
            )),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.pages,
              color: _bottomNavigationColor,
            ),
            title: Text(
              'PAGES',
              style: TextStyle(color: _bottomNavigationColor),
            )),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
              color: _bottomNavigationColor,
            ),
            title: Text(
              'Setting',
              style: TextStyle(color: _bottomNavigationColor),
            )),
      ],
      currentIndex: _currentIndex,
      onTap: (int index) {
        setState(() {
          _currentIndex = index;
        });
      },
      type: BottomNavigationBarType.shifting,
    );
  }


}
