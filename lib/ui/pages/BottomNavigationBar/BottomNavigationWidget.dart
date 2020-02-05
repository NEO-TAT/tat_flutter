import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/Log.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/task/CheckCookiesTask.dart';
import 'package:flutter_app/ui/pages/BottomNavigationBar/screen/mail/NewAnnouncementScreen.dart';
import 'package:flutter_app/ui/pages/bottomnavigationbar/screen/course/CourseTableScreen.dart';
import 'package:flutter_app/ui/pages/bottomnavigationbar/screen/internet/InternetScreen.dart';
import 'package:flutter_app/ui/pages/bottomnavigationbar/screen/internet/InternetScreen2.dart';
import 'package:flutter_app/ui/pages/bottomnavigationbar/screen/setting/SettingScreen.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'BottomPage.dart';

class BottomNavigationWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BottomNavigationWidgetState();
}


class BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  final _bottomNavigationColor = Colors.blue;
  final pageController = PageController();
  int _currentIndex = 0;
  int _closeAppTime = 0;
  BottomPageList bottomPageList = BottomPageList();

  @override
  void initState() {
    super.initState();
    Model.instance.init().then((value) {
      bottomPageList.add(BottomPage(CourseTableScreen()      ));
      bottomPageList.add(BottomPage(NewAnnouncementScreen()  ));
      bottomPageList.add(BottomPage(InternetScreen2()        ));
      bottomPageList.add(BottomPage(SettingScreen()          ));
      setState(() {
      });
    });
    _addTask();
  }

  void _addTask(){
    TaskHandler.instance.addTask( CheckCookiesTask(context));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: willPop(),
    );
  }

  Widget willPop(){
    return WillPopScope(
      onWillPop: () async{
        bool pop =  !bottomPageList.getKey(_currentIndex).currentState.canPop();  //子分頁是否可以返回
        if( pop ){
          _closeAppTime++;
          Fluttertoast.showToast(
              msg: "在按一次關閉",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
          Future.delayed(Duration(seconds: 2)).then( (_){
            _closeAppTime = 0;
          });
        }else{
          bottomPageList.getKey(_currentIndex).currentState.pop();
          _closeAppTime = 0;
        }
        return (_closeAppTime >= 2);
      },
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: getPageView(),
        bottomNavigationBar: bottomNavigationBar(),
      ),
    );
  }

  Widget getIndexStack(){  //第一次會全部載入
    return IndexedStack(
      index: _currentIndex,
      children: bottomPageList.pageList,
    );
  }

  Widget getPageView(){
    return PageView(
      controller: pageController,
      onPageChanged: onPageChanged,
      children: bottomPageList.pageList,
      physics: NeverScrollableScrollPhysics(), // 禁止滑动
    );
  }

  void onTap(int index) {
    pageController.jumpToPage(index);
  }

  void onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }



  Widget bottomNavigationBar() {
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
        onTap(index);
      },
      type: BottomNavigationBarType.shifting,
    );
  }


}
