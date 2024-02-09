// TODO: remove sdk version selector after migrating to null-safety.
// @dart=2.10
import 'package:flutter/material.dart';
import 'package:flutter_app/src/providers/app_provider.dart';
import 'package:flutter_app/src/r.dart';
import 'package:flutter_app/src/store/local_storage.dart';
import 'package:flutter_app/ui/pages/coursedetail/screen/course_info_page.dart';
import 'package:flutter_app/ui/pages/coursedetail/screen/ischoolplus/iplus_announcement_page.dart';
import 'package:flutter_app/ui/pages/coursedetail/screen/ischoolplus/iplus_file_page.dart';
import 'package:flutter_app/ui/pages/coursedetail/tab_page.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../src/model/coursetable/course.dart';

class ISchoolPage extends StatefulWidget {
  final Course course;
  final String studentId;

  const ISchoolPage(this.studentId, this.course, {Key key}) : super(key: key);

  @override
  State<ISchoolPage> createState() => _ISchoolPageState();
}

class _ISchoolPageState extends State<ISchoolPage> with SingleTickerProviderStateMixin {
  TabPageList tabPageList;
  TabController _tabController;
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    tabPageList = TabPageList();
    tabPageList.add(TabPage(
        R.current.course,
        Icons.info,
        CourseInfoPage(
          widget.studentId,
          widget.course,
          key: null,
        )));
    if (widget.studentId == LocalStorage.instance.getAccount()) {
      tabPageList.add(
          TabPage(R.current.announcement, Icons.announcement, IPlusAnnouncementPage(widget.studentId, widget.course)));
      tabPageList
          .add(TabPage(R.current.fileAndVideo, Icons.file_download, IPlusFilePage(widget.studentId, widget.course)));
    }

    _tabController = TabController(vsync: this, length: tabPageList.length);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (BuildContext context, AppProvider appProvider, Widget child) {
        return WillPopScope(
          onWillPop: () async {
            var currentState = tabPageList.getKey(_currentIndex).currentState;
            bool pop = (currentState == null) ? true : currentState.canPop();
            return pop;
          },
          child: Container(
            child: tabPageView(),
          ),
        );
      },
    );
  }

  Widget tabPageView() {
    Course course = widget.course;
    return DefaultTabController(
      length: tabPageList.length,
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => Get.back(),
          ),
          title: FittedBox(child: Text(course.name)),
          bottom: TabBar(
            indicatorPadding: const EdgeInsets.all(0),
            labelPadding: const EdgeInsets.all(0),
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
            _tabController.animateTo(index); //與上面tab同步
            _currentIndex = index;
          },
        ),
      ),
    );
  }
}
