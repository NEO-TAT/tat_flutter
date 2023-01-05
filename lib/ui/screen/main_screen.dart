// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/log.dart';
import 'package:flutter_app/src/config/app_colors.dart';
import 'package:flutter_app/src/file/my_downloader.dart';
import 'package:flutter_app/src/notifications/notifications.dart';
import 'package:flutter_app/src/providers/app_provider.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/task/ntut/ntut_task.dart';
import 'package:flutter_app/src/task/task.dart';
import 'package:flutter_app/src/util/analytics_utils.dart';
import 'package:flutter_app/src/util/language_util.dart';
import 'package:flutter_app/src/version/app_version.dart';
import 'package:flutter_app/ui/other/my_toast.dart';
import 'package:flutter_app/ui/pages/calendar/calendar_page.dart';
import 'package:flutter_app/ui/pages/coursetable/course_table_page.dart';
import 'package:flutter_app/ui/pages/notification/notification_page.dart';
import 'package:flutter_app/ui/pages/other/other_page.dart';
import 'package:flutter_app/ui/pages/score/score_page.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with RouteAware {
  final _pageController = PageController();
  int _currentIndex = 0;
  int _closeAppCount = 0;
  List<Widget> _pageList = [];

  @override
  void initState() {
    appInit();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null) {
      AnalyticsUtils.observer.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    AnalyticsUtils.observer.unsubscribe(this);
    super.dispose();
  }

  void appInit() async {
    R.set(context);

    try {
      await initLanguage();
      APPVersion.initAndCheck();
      initFlutterDownloader();
      initNotifications();
    } catch (e, stack) {
      Log.eWithStack(e.toString(), stack);
    }

    // Request login status check and also do the initial login.
    // We will ignore all failed cases of this step, since we should allow offline mode.
    // But some cases (like Wrong Password) will move user to the login screen and wipe data.
    final checkLoginTaskResult = await checkIfLogin();
    if (checkLoginTaskResult == TaskStatus.shouldGiveUp) {
      return;
    }

    setState(() {
      _pageList = [];
      _pageList.add(const CourseTablePage());
      _pageList.add(const NotificationPage());
      _pageList.add(const CalendarPage());
      _pageList.add(const ScoreViewerPage());
      _pageList.add(OtherPage(_pageController));
    });
  }

  Future<TaskStatus> checkIfLogin() {
    final loginTask = NTUTTask('AutoLoginOnMainScreen');
    return loginTask.execute();
  }

  void initFlutterDownloader() async {
    await MyDownloader.init();
  }

  void initNotifications() async {
    await Notifications.instance.init();
  }

  Future<void> initLanguage() async {
    await LanguageUtil.init(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          appProvider.navigatorKey = Get.key;
          return WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
              backgroundColor: Theme.of(context).backgroundColor,
              body: _buildPageView(),
              bottomNavigationBar: _buildBottomNavigationBar(),
            ),
          );
        },
      );

  Future<bool> _onWillPop() async {
    final canPop = Navigator.of(context).canPop();
    if (canPop) {
      Navigator.of(context).pop();
      _closeAppCount = 0;
    } else {
      _closeAppCount++;
      MyToast.show(R.current.closeOnce);
      Future.delayed(const Duration(seconds: 2)).then((_) {
        _closeAppCount = 0;
      });
    }
    return (_closeAppCount >= 2);
  }

  Widget _buildPageView() => PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: _pageList,
      );

  Widget _buildBottomNavigationBar() {
    final isDarkMode = Get.isDarkMode;
    final selectedItemColor = isDarkMode ? AppColors.lightAccent : AppColors.mainColor;
    final unSelectedItemColor = isDarkMode ? AppColors.lightBG : AppColors.darkFontColor;
    final barBgColor = isDarkMode ? Colors.black12 : Colors.grey[200];

    return BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: _onTap,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unSelectedItemColor,
      items: [
        BottomNavigationBarItem(
          backgroundColor: barBgColor,
          icon: const Icon(
            EvaIcons.clockOutline,
          ),
          label: R.current.titleCourse,
        ),
        BottomNavigationBarItem(
          icon: const Icon(
            EvaIcons.emailOutline,
          ),
          label: R.current.titleNotification,
        ),
        BottomNavigationBarItem(
          icon: const Icon(
            EvaIcons.calendarOutline,
          ),
          label: R.current.calendar,
        ),
        BottomNavigationBarItem(
            icon: const Icon(
              EvaIcons.bookOpenOutline,
            ),
            label: R.current.titleScore),
        BottomNavigationBarItem(
          icon: const Icon(
            EvaIcons.menu,
          ),
          label: R.current.titleOther,
        ),
      ],
    );
  }

  void _onPageChange(int index) {
    final screenName = _pageList[index].toString();
    AnalyticsUtils.setScreenName(screenName);
  }

  void _onTap(int index) {
    _pageController.jumpToPage(index);
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      _onPageChange(_currentIndex);
    });
  }
}
