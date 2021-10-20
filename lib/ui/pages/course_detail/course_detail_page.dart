import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:tat/src/R.dart';
import 'package:tat/src/config/app_config.dart';
import 'package:tat/src/config/app_themes.dart';
import 'package:tat/src/model/course_table/course_table_json.dart';
import 'package:tat/src/providers/app_provider.dart';
import 'package:tat/src/store/model.dart';
import 'package:tat/ui/pages/course_detail/screen/course_info_page.dart';
import 'package:tat/ui/pages/course_detail/screen/ischool_plus/iplus_announcement_page.dart';
import 'package:tat/ui/pages/course_detail/screen/ischool_plus/iplus_file_page.dart';
import 'package:tat/ui/pages/course_detail/tab_page.dart';

class ISchoolPage extends StatefulWidget {
  final CourseInfoJson courseInfo;
  final String studentId;

  ISchoolPage(this.studentId, this.courseInfo);

  @override
  _ISchoolPageState createState() => _ISchoolPageState();
}

class _ISchoolPageState extends State<ISchoolPage>
    with SingleTickerProviderStateMixin {
  late final TabPageList tabPageList;
  late final TabController _tabController;
  final _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    tabPageList = TabPageList();
    tabPageList.add(
      TabPage(
        R.current.course,
        Icons.info,
        CourseInfoPage(
          widget.studentId,
          widget.courseInfo,
        ),
      ),
    );
    if (widget.studentId == Model.instance.getAccount()) {
      tabPageList.add(
        TabPage(
          R.current.announcement,
          Icons.announcement,
          IPlusAnnouncementPage(
            widget.studentId,
            widget.courseInfo,
          ),
        ),
      );
      tabPageList.add(
        TabPage(
          R.current.fileAndVideo,
          Icons.file_download,
          IPlusFilePage(
            widget.studentId,
            widget.courseInfo,
          ),
        ),
      );
    }

    _tabController = TabController(vsync: this, length: tabPageList.length);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (BuildContext context, AppProvider appProvider, Widget? child) {
        return WillPopScope(
          onWillPop: () async {
            final currentState = tabPageList.getKey(_currentIndex).currentState;
            return (currentState == null) ? true : currentState.canPop();
          },
          child: MaterialApp(
            title: AppConfig.appName,
            theme: appProvider.theme,
            darkTheme: AppThemes.darkTheme,
            home: tabPageView(),
          ),
        );
      },
    );
  }

  Widget tabPageView() {
    final course = widget.courseInfo.main!.course;

    return DefaultTabController(
      length: tabPageList.length,
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => Get.back(),
          ),
          title: Text(course!.name),
          bottom: TabBar(
            indicatorPadding: EdgeInsets.all(0),
            labelPadding: EdgeInsets.all(0),
            isScrollable: true,
            controller: _tabController,
            tabs: tabPageList.getTabList(context),
            onTap: (index) {
              _pageController.jumpToPage(index);
              _currentIndex = index;
            },
          ),
        ),
        body: PageView(
          //控制滑動
          controller: _pageController,
          children: tabPageList.getTabPageList,
          onPageChanged: (index) {
            _tabController.animateTo(index);
            _currentIndex = index;
          },
        ),
      ),
    );
  }
}
