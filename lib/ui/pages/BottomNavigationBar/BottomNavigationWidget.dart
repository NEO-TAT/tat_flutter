import 'package:flutter/material.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/src/connector/ISchoolPlusConnector.dart';
import 'package:flutter_app/src/file/MyDownloader.dart';
import 'package:flutter_app/src/util/LanguageUtil.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/task/CheckCookiesTask.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:flutter_app/ui/pages/coursetable/CourseTableScreen.dart';
import 'package:flutter_app/ui/pages/mail/NewAnnouncementScreen.dart';
import 'package:flutter_app/ui/pages/other/OtherScreen.dart';
import 'package:flutter_app/ui/pages/setting/SettingScreen.dart';
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
      //載入儲存資料
      bottomPageList.add(BottomPage(CourseTableScreen()));
      bottomPageList
          .add(BottomPage(NewAnnouncementScreen(), useNavigatorKey: true));
      //bottomPageList.add(BottomPage(CalendarScreen()));
      bottomPageList.add(BottomPage(OtherScreen()));
      bottomPageList.add(BottomPage(SettingScreen(pageController)));
      _setLang();
      //_test();
    });
    _flutterDownloaderInit();
    _addTask();
  }

  void _addTask() async {
    TaskHandler.instance.addTask(CheckCookiesTask(null)); //第一次登入要檢查
  }

  void _test() async{
    String account = Model.instance.getAccount();
    String password = Model.instance.getPassword();
    await ISchoolPlusConnector.login(account ,password );
    await ISchoolPlusConnector.getCourseFile("261046");

  }

  void _flutterDownloaderInit() async {
    await MyDownloader.init();
  }

  void _setLang() async {
    Locale myLocale = Localizations.localeOf(context);
    LanguageUtil.load(myLocale);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: willPop(),
    );
  }

  Widget willPop() {
    return WillPopScope(
      onWillPop: () async {
        var currentState = bottomPageList.getKey(_currentIndex).currentState;
        bool pop = (currentState == null) ? true : !currentState.canPop();
        //Log.d(pop.toString());
        if (pop) {
          _closeAppTime++;
          MyToast.show(S.current.closeOnce);
          Future.delayed(Duration(seconds: 2)).then((_) {
            _closeAppTime = 0;
          });
        } else {
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

  Widget getIndexStack() {
    //第一次會全部載入
    return IndexedStack(
      index: _currentIndex,
      children: bottomPageList.pageList,
    );
  }

  Widget getPageView() {
    return PageView(
      controller: pageController,
      onPageChanged: onPageChanged,
      children: bottomPageList.pageList,
      physics: NeverScrollableScrollPhysics(), // 禁止滑動
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
              Icons.search,
              color: _bottomNavigationColor,
            ),
            title: Text(
              'Search',
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
        /*
        BottomNavigationBarItem(
            icon: Icon(
              Icons.calendar_today,
              color: _bottomNavigationColor,
            ),
            title: Text(
              'Calendar',
              style: TextStyle(color: _bottomNavigationColor),
            )),

         */
        BottomNavigationBarItem(
            icon: Icon(
              Icons.pages,
              color: _bottomNavigationColor,
            ),
            title: Text(
              'Other',
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
