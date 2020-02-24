import 'package:flutter/material.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:flutter_app/src/file/MyDownloader.dart';
import 'package:flutter_app/src/util/LanguageUtil.dart';
import 'package:flutter_app/src/store/Model.dart';
import 'package:flutter_app/src/taskcontrol/TaskHandler.dart';
import 'package:flutter_app/src/taskcontrol/task/CheckCookiesTask.dart';
import 'package:flutter_app/ui/other/MyToast.dart';
import 'package:flutter_app/ui/pages/coursetable/CourseTablePage.dart';
import 'package:flutter_app/ui/pages/mail/NewAnnouncementPage.dart';
import 'package:flutter_app/ui/pages/other/OtherPage.dart';
import 'package:flutter_app/ui/pages/setting/SettingPage.dart';

import '../../debug/log/Log.dart';

class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _pageController = PageController();
  int _currentIndex = 0;
  int _closeAppCount = 0;
  List<Widget> _pageList = List<Widget>();

  @override
  void initState() {
    super.initState();

    //載入儲存資料
    Model.instance.init().then((value) {
      // 需重新初始化 list，PageController 才會清除 cache
      _pageList = List();

      _pageList.add(CourseTablePage());
      _pageList.add(NewAnnouncementPage());
      //bottomPageList.add(BottomPage(CalendarScreen()));
      _pageList.add(OtherPage());
      _pageList.add(SettingPage(_pageController));
      _setLang();
    });
    _flutterDownloaderInit();
    _addTask();
  }

  void _addTask() async {
    TaskHandler.instance.addTask(CheckCookiesTask(null)); //第一次登入要檢查
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
      home: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomPadding: false,
          body: _buildPageView(),
          bottomNavigationBar: _buildBottomNavigationBar(),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    var canPop = Navigator.of(context).canPop();
    //Log.d(canPop.toString());
    if (canPop) {
      Navigator.of(context).pop();
      _closeAppCount = 0;
    } else {
      _closeAppCount++;
      MyToast.show(S.current.closeOnce);
      Future.delayed(Duration(seconds: 2)).then((_) {
        _closeAppCount = 0;
      });
    }
    return (_closeAppCount >= 2);
  }

  Widget _buildPageView() {
    return PageView(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      children: _pageList,
      physics: NeverScrollableScrollPhysics(), // 禁止滑動
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: _onTap,
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.search,
          ),
          title: Text(
            'Search',
          ),
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.email,
          ),
          title: Text(
            'Email',
          ),
        ),
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
          ),
          title: Text(
            'Other',
          ),
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.settings,
          ),
          title: Text(
            'Setting',
          ),
        ),
      ],
    );
  }

  void _onTap(int index) {
    _pageController.jumpToPage(index);
  }
}
