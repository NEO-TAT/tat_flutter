import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/store/json/CourseClassJson.dart';
import 'package:flutter_app/src/store/json/CourseTableJson.dart';
import 'package:flutter_app/ui/pages/ischool/TabPage.dart';
import 'package:flutter_app/ui/pages/ischool/screen/CourseAnnouncementScreen.dart';
import 'package:flutter_app/ui/pages/ischool/screen/CourseFileScreen.dart';
import 'package:flutter_app/ui/pages/ischool/screen/CourseInfoScreen.dart';

class ISchoolScreen extends StatefulWidget {
  final CourseInfoJson courseInfo;

  ISchoolScreen(this.courseInfo);

  @override
  _ISchoolScreen createState() => _ISchoolScreen();
}

class _ISchoolScreen extends State<ISchoolScreen> {
  TabPageList tabPageList;
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    tabPageList = TabPageList();
    tabPageList.add(TabPage(  "課程", Icons.info         , CourseInfoScreen(widget.courseInfo) ));
    tabPageList.add(TabPage(  "公告", Icons.announcement , CourseAnnouncementScreen(widget.courseInfo) ));
    tabPageList.add(TabPage(  "檔案", Icons.file_download , CourseFileScreen(widget.courseInfo) ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: tabPageView(),
    );
  }

  Widget tabPageView() {

    CourseMainJson course = widget.courseInfo.main.course;

    return DefaultTabController(
      length: tabPageList.length,
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text( course.name ),
          bottom: TabBar(
            indicatorPadding: EdgeInsets.all(0),
            labelPadding: EdgeInsets.all(0),
            isScrollable: true,
            /*
            indicator: UnderlineTabIndicator(
            borderSide: BorderSide(style: BorderStyle.none)),
             */
            tabs: tabPageList.getTabList(context),
            controller: _tabController,
          ),
        ),
        body: TabBarView(
          children: tabPageList.getTabPageList,
        ),
      ),
    );
  }
}
